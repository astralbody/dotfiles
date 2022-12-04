use std::error::Error;
use std::fs::{self};
use std::os::unix;
use std::path::{Path, PathBuf};
use std::io;
use std::vec;
use toml;
use serde_derive::{Deserialize,Serialize};

// TODO:
// [x] - Integration tests
// [x] - Save state
// [x] - Remove previous links before installing new ones
// [ ] - Add support dotlets
// [ ] - Add support profiles and profile_name, link selected dotlets
// [ ] - Handle arguments (https://docs.rs/clap/latest/clap/)
// [ ] - Handle environment variables
// [ ] - Handle config files
// [ ] - Handle errors
// [ ] - Write docs

//struct Profile {
//   name: String,
//   dotlets: Vec<String>
//}

struct DotletConfig {
   from: String,
   to: String,
}

struct DotletV2 {
   name: String,
   path: String,
   configs: Vec<DotletConfig>
}

pub struct ConfigV2 {
    // profile_name: String,
    dotfiles_dir: String,
    home_dir: String,
    backup_dir: String,
    state_file: String,
    // profiles: Vec<Profile>,
    dotlets: Vec<DotletV2>,
}
struct StateV2 {
    linked_configs: Vec<String>,
    backup_configs: Vec<String>,
}

#[derive(Deserialize, Serialize, Debug)]
pub struct Config {
    dotfiles_dir: String,
    home_dir: String,
    ignore_dirs: Vec<String>,
    backup_dir: String,
    state_file: String
}

impl Config {
    pub fn build(
        dotfiles_dir: String,
        home_dir: String,
        backup_dir: String,
        state_file: String
    ) -> Result<Self, io::Error> {
        let ignore_dirs = vec![
            "node_modules".to_string(),
            "sandbox".to_string(),
            "vendor".to_string()
        ];

        Ok(Config {
            dotfiles_dir,
            home_dir,
            ignore_dirs,
            backup_dir,
            state_file
        })
    }
}

#[derive(Debug)]
pub struct Dotlet {
    path: String,
    configs: Vec<String>,
}

pub fn create_dotlets(config: &Config) -> Result<Vec<Dotlet>, io::Error> {
    let dotlets = fs::read_dir(config.dotfiles_dir.clone())?
        .into_iter()
        .fold(vec![], |mut acc, dotfiles_dir| {
            let dir_entry = match dotfiles_dir {
                Ok(dir_entry) => dir_entry,
                Err(_) => return acc
            };
            let dir_path = dir_entry.path();
            let is_dir = dir_path.is_dir();
            let is_not_ignored = config.ignore_dirs.iter().all(|ignore_dir| match dir_path.to_str() {
                Some(dir_str_path) => !dir_str_path.contains(ignore_dir),
                None => false
            });
            if is_dir && is_not_ignored  {
                acc.push(Dotlet {
                    path: dir_path.to_str().unwrap().to_string(),
                    configs: vec![]
                });
            }
            acc
        });
    Ok(dotlets)
}

fn extract_configs_from_dir(config_dir_path: &PathBuf, dotfiles_dir: &str) -> Vec<String> {
    let config_dir = match fs::read_dir(config_dir_path) {
        Ok(dotlet_dir) => dotlet_dir,
        Err(_) => return vec![]
    };

    config_dir
        .fold(vec![], |mut acc, entry| match entry {
            Ok(dir_entry) => {
                acc.push(dir_entry);
                acc
            },
            Err(_) => acc,
        })
        .into_iter()
        .fold(vec![], |mut acc, config_dir_entity| {
            let path = config_dir_entity.path();

            if path.is_dir() {
                extract_configs_from_dir(&path, &dotfiles_dir).into_iter().for_each(|config| {
                    acc.push(config);
                });
            } else {
                acc.push(path.strip_prefix(dotfiles_dir).unwrap().to_str().unwrap().to_string());
            }
            acc
        })
}

fn extract_configs(dotlet_path: &str, dotfiles_dir: &str) -> Vec<String> {
    let ignore_list = vec![".gitkeep"];

    let dotlet_dir = match fs::read_dir(dotlet_path) {
        Ok(dotlet_dir) => dotlet_dir,
        Err(err) => return vec![]
    };

    dotlet_dir
        .fold(vec![], |mut acc, entry| match entry {
            Ok(dir_entry) => {
                acc.push(dir_entry);
                acc
            },
            Err(_) => acc,
        })
        .into_iter()
        .filter(|dir_entry| match dir_entry.file_name().to_str() {
            Some(file_name) => file_name.contains(".") && !ignore_list.contains(&file_name),
            None => false
        })
        .fold(vec![], |mut acc, dir_entry| {
            let path = dir_entry.path();
            if path.is_dir() {
                extract_configs_from_dir(&path, dotfiles_dir).into_iter().for_each(|config| {
                    acc.push(config);
                });
            } else {
                acc.push(path.strip_prefix(dotfiles_dir).unwrap().to_str().unwrap().to_string());
            }
            acc
        })
}

fn link_configs_to_home(config: &ConfigV2) -> Result<StateV2, io::Error> {
    let mut state = StateV2 {
        linked_configs: vec![],
        backup_configs: vec![]
    };
    config.dotlets.iter().fold(vec![],|mut acc, dotlet| {
        dotlet.configs.iter().for_each(|dotlet_config| {
            let link = format!("{}/{}", &config.home_dir, &dotlet_config.to);
            let origin = format!("{}/{}/{}", &config.dotfiles_dir, &dotlet.path, &dotlet_config.from);
            let backup = format!("{}/{}", &config.backup_dir, &dotlet_config.to);

            if let Ok(_) = fs::metadata(&link) {
                fs::create_dir_all(Path::new(&backup).parent().unwrap()).unwrap();
                fs::rename(&link, &backup).unwrap();
                state.backup_configs.push(backup);
            };

            fs::create_dir_all(Path::new(&link).parent().unwrap()).unwrap();

            println!("Link {} to {}", &origin, &link);
            let result = unix::fs::symlink(origin, &link);
            acc.push(result);
            state.linked_configs.push(link);
        });
        acc
    });

    Ok(state)
}

fn find_configs(dotlets: Vec<Dotlet>) -> Vec<Dotlet> {
    dotlets.into_iter().map(|dotlet| {
        let path = Path::new(&dotlet.path).to_path_buf();

        Dotlet { configs: extract_configs(path.to_str().unwrap(), &dotlet.path), ..dotlet }
    }).collect()
}

fn remove_links(links: &Vec<String>) -> Result<(), io::Error> {
    links.iter().for_each(|link| {
        fs::remove_file(&link);
    });
    Ok(())
}

fn remove_old_links(state_file: &str) -> Result<(), Box<dyn Error>> {
    let state_file_exists = Path::new(&state_file).try_exists();

    if state_file_exists.is_ok() && state_file_exists.unwrap() {
        let old_state = State::restore(&state_file)?;
        remove_links(&old_state.linked_configs)?;
    }

    Ok(())
}

fn save() -> {
    let state_string = toml::to_string()?;
    fs::write(&self.config.state_file, state_string)?;
}

pub fn install(config: ConfigV2) -> Result<(), Box<dyn Error>>  {
    // let dotlets = create_dotlets(&config)?;
    // let dotlets = find_configs(dotlets);

    remove_old_links(&config.state_file)?;

    let state = link_configs_to_home(&config)?;

    //let state = State {
    //    linked_configs,
    //    backups,
    //    config
    //};
    //state.save()?;

    save(state);
    save(config);

    Ok(())
}

#[derive(Deserialize, Serialize, Debug)]
struct State {
    linked_configs: Vec<String>,
    backups: Vec<String>,
    config: Config,
}

impl State {
    fn save(&self) -> Result<(), Box<dyn Error>> {
        if let Some(parent) = Path::new(&self.config.state_file).parent() {
            fs::create_dir_all(parent)?;
        }
        let state_string = toml::to_string(&self)?;
        fs::write(&self.config.state_file, state_string)?;
        Ok(())
    }

    fn restore(state_file: &str) -> Result<State, Box<dyn Error>> {
        let state_file = fs::read_to_string(&state_file)?;
        let restored_state: State = toml::from_str(&state_file)?;
        Ok(restored_state)
    }
}

#[cfg(test)]
mod test {

    use super::*;

    fn create_test_home_dir(test_dir: &str) -> String {
        let tmp_dir = "/shared_disk/projects/dotfiles/dot/tmp";
        let test_home_dir = format!("{}/{}/home", tmp_dir, test_dir);
        if let Ok(_) = fs::metadata(&test_home_dir) {
            fs::remove_dir_all(&test_home_dir).unwrap();
        }

        fs::create_dir_all(&test_home_dir).unwrap();

        return test_home_dir;
    }

    #[ignore]
    #[test]
    fn dotlets() {
        let test_home_dir = create_test_home_dir("dotlets");
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";

        let config = Config::build(
            dotfiles_dir.to_string(),
            test_home_dir.clone(),
            format!("{}/.local/share/backup", test_home_dir),
            format!("{}/.local/state", test_home_dir)
        ).unwrap();


        let expected_dotlets: Vec<String> = vec![
            Dotlet {
                path: format!("{}/dotlet_a", dotfiles_dir),
                configs: vec![]
            },
            Dotlet {
                path: format!("{}/dotlet_b", dotfiles_dir),
                configs: vec![]
            },
            Dotlet {
                path: format!("{}/dotlet_c", dotfiles_dir),
                configs: vec![]
            }
        ]
            .iter()
            .map(|dotlet| dotlet.path.clone())
            .collect();

        let actual_dotlets: Vec<String> = create_dotlets(&config)
            .unwrap()
            .iter()
            .map(|dotlet| dotlet.path.clone())
            .collect();

        assert_eq!(expected_dotlets, actual_dotlets);
    }

    #[test]
    fn extend_dotlets_with_configs() {
        let expected_dotlets: Vec<Dotlet> = vec![
            Dotlet {
                path: "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles/dotlet_b".to_string(),
                configs: vec![".config_file".to_string()]
            },
            Dotlet {
                path: "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles/dotlet_c".to_string(),
                configs: vec![".config_dir/.config_file".to_string(), ".config_dir/config_dir/.config_file".to_string()]
            },
        ];
        let actual_dotlets: Vec<Dotlet> = vec![
            Dotlet {
                path: "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles/dotlet_b".to_string(),
                configs: vec![]
            },
            Dotlet {
                path: "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles/dotlet_c".to_string(),
                configs: vec![]
            }
        ];

        let actual_dotlets = find_configs(actual_dotlets);

        actual_dotlets
            .iter()
            .zip(expected_dotlets.iter())
            .for_each(|(actual_dotlet, expected_dotlet)| {
                assert_eq!(actual_dotlet.configs, expected_dotlet.configs)
            });

    }

    #[test]
    fn link_dotlet_configs() {
        let test_home_dir = create_test_home_dir("link_dotlet_configs");
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";
        let backup_dir = format!("{}/.local/share/backup", test_home_dir);
        let state_file = format!("{}/.local/state", test_home_dir);
        let dotlets = vec![
            DotletV2 {
                name: "dotlet_a".to_string(),
                path: "dotlet_a".to_string(),
                configs: vec![]
            },
            DotletV2 {
                name: "dotlet_b".to_string(),
                path: "dotlet_b".to_string(),
                configs: vec![
                    DotletConfig {
                        from: ".config_file".to_string(),
                        to: ".config_file".to_string(),
                    }
                ]
            },
            DotletV2 {
                name: "dotlet_c".to_string(),
                path: "dotlet_c".to_string(),
                configs: vec![
                    DotletConfig {
                        from: ".config_dir/config_dir/.config_file".to_string(),
                        to: ".config_dir/config_dir/.config_file".to_string(),
                    },
                    DotletConfig {
                        from: ".config_dir/.config_file".to_string(),
                        to: ".config_dir/.config_file".to_string(),
                    }
                ]
            }
        ];
        let config = ConfigV2 {
            home_dir: test_home_dir.clone(),
            dotfiles_dir: dotfiles_dir.to_string(),
            backup_dir,
            state_file,
            dotlets
        };

        link_configs_to_home(&config).unwrap();

        let expected_config_links = [
            ".config_file",
            ".config_dir/.config_file",
            ".config_dir/config_dir/.config_file"
        ];
        assert!(expected_config_links.iter().all(|config_link| {
            let config_link_full_path = format!("{}/{}", &config.home_dir, &config_link);


            let is_symlink = match fs::symlink_metadata(&config_link_full_path) {
                Ok(metadata) => metadata.file_type().is_symlink(),
                Err(_) => return false
            };

            if !is_symlink {
                return false;
            }

            fs::read_link(&config_link_full_path).is_ok()
        }));
    }

    #[test]
    fn create_config_dirs() {
        let test_home_dir = create_test_home_dir("create_config_dirs");
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";
        let backup_dir = format!("{}/.local/share/backup", test_home_dir);
        let state_file = format!("{}/.local/state", test_home_dir);
        let dotlets = vec![
            DotletV2 {
                name: "dotlet_c".to_string(),
                path: "dotlet_c".to_string(),
                configs: vec![
                    DotletConfig {
                        from: ".config_dir/config_dir/.config_file".to_string(),
                        to: ".config_dir/config_dir/.config_file".to_string(),
                    },
                ]
            }
        ];
        let config = ConfigV2 {
            home_dir: test_home_dir.clone(),
            dotfiles_dir: dotfiles_dir.to_string(),
            backup_dir,
            state_file,
            dotlets
        };

        link_configs_to_home(&config).unwrap();

        assert!(match fs::symlink_metadata(format!("{}/.config_dir/config_dir/", test_home_dir)) {
            Ok(metadata) => metadata.file_type().is_dir(),
            Err(_) => false
        });
    }

    #[test]
    fn backup_existing_configs() {
        let test_home_dir = create_test_home_dir("backup_existing_configs");
        let backup_dir = format!("{}/.local/share/backup", test_home_dir);
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";
        let state_file = format!("{}/.local/state", test_home_dir);

        fs::create_dir_all(&backup_dir).unwrap();
        fs::create_dir(format!("{}/.config_dir", test_home_dir)).unwrap();
        fs::File::create(format!("{}/.config_dir/.config_file", test_home_dir)).unwrap();

        let dotlets = vec![
            DotletV2 {
                name: "dotlet_c".to_string(),
                path: "dotlet_c".to_string(),
                configs: vec![
                    DotletConfig {
                        from: ".config_dir/.config_file".to_string(),
                        to: ".config_dir/.config_file".to_string(),
                    },
                ]
            }
        ];
        let config = ConfigV2 {
            home_dir: test_home_dir.clone(),
            dotfiles_dir: dotfiles_dir.to_string(),
            backup_dir,
            state_file,
            dotlets
        };

        link_configs_to_home(&config).unwrap();

        assert!(fs::metadata(format!("{}/.config_dir/.config_file", &config.backup_dir)).unwrap().is_file());
    }

    #[test]
    fn save_state() {
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";
        let test_home_dir = create_test_home_dir("save_state");
        let backup_dir = format!("{}/.local/share/backup", test_home_dir);
        let state_file = format!("{}/.local/state/state.toml", test_home_dir);

        let linked_configs = vec![
            ".config_file".to_string()
        ];
        let backups = vec![
            ".config_file".to_string()
        ];
        let config = Config::build(
            dotfiles_dir.to_string(),
            test_home_dir.clone(),
            backup_dir.clone(),
            state_file.clone()
        ).unwrap();
        let state: State = State {
            linked_configs,
            backups,
            config
        };

        state.save().unwrap();

        assert!(Path::new(&state.config.state_file).try_exists().is_ok());
    }

    #[test]
    fn restore_state() {
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";
        let test_home_dir = create_test_home_dir("restore_state");
        let backup_dir = format!("{}/.local/share/backup", test_home_dir);
        let state_file = format!("{}/.local/state/state.toml", test_home_dir);

        let linked_configs = vec![
            ".config_file".to_string()
        ];
        let backups = vec![
            ".config_file".to_string()
        ];
        let config = Config::build(
            dotfiles_dir.to_string(),
            test_home_dir.clone(),
            backup_dir.clone(),
            state_file.clone()
        ).unwrap();
        let state: State = State {
            linked_configs,
            backups,
            config
        };

        state.save().unwrap();

        let restored_state = State::restore(&state.config.state_file).unwrap();

        assert_eq!(restored_state.linked_configs, state.linked_configs);
        assert_eq!(restored_state.backups, state.backups);
        assert_eq!(restored_state.config.dotfiles_dir, state.config.dotfiles_dir);
        assert_eq!(restored_state.config.home_dir, state.config.home_dir);
        assert_eq!(restored_state.config.ignore_dirs, state.config.ignore_dirs);
        assert_eq!(restored_state.config.backup_dir, state.config.backup_dir);
        assert_eq!(restored_state.config.state_file, state.config.state_file);
    }

    #[test]
    fn old_links() {
        let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles";
        let test_home_dir = create_test_home_dir("remove_old_links");
        let backup_dir = format!("{}/.local/share/backup", test_home_dir);
        let state_file = format!("{}/.local/state/state.toml", test_home_dir);


        let config = Config::build(
            dotfiles_dir.to_string(),
            test_home_dir.clone(),
            backup_dir.clone(),
            state_file.clone()
        ).unwrap();
        let dotlets = create_dotlets(&config).unwrap();
        // let (linked_configs, backups) = link_configs_to_home(dotlets, &test_home_dir, &backup_dir).unwrap();
        //let state: State = State {
        //    linked_configs,
        //    backups,
        //    config
        //};
        // state.save().unwrap();

        remove_old_links(&state_file).unwrap();

        //state.linked_configs.iter().for_each(|linked_config: &String| {
        //    let config_path = format!("{}/{}", &test_home_dir, &linked_config);
        //    assert!(Path::new(&config_path).try_exists().is_err());
        //});
    }
}
