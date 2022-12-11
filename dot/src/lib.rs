use serde::{Deserialize, Serialize};
use std::env;
use std::error::Error;
use std::fs::{self};
use std::io;
use std::os::unix;
use std::path::Path;
use std::vec;

// TODO:
// [x] - Integration tests
// [x] - Save state
// [x] - Remove previous links before installing new ones
// [x] - Add support dotlets
// [x] - Add support profiles and profile_name, link selected dotlets
// [ ] - Handle arguments (https://docs.rs/clap/latest/clap/)
// [ ] - Handle environment variables
// [ ] - Handle config files
// [ ] - Validation
// [ ] - Handle errors
// [ ] - Write docs

#[derive(Deserialize, Serialize, Debug)]
pub struct Profile {
    pub name: String,
    pub dotlets: Vec<String>,
}

#[derive(Deserialize, Serialize, Debug)]
pub struct DotletConfig {
    pub from: String,
    pub to: String,
}

#[derive(Deserialize, Serialize, Debug)]
pub struct Dotlet {
    pub name: String,
    pub path: String,
    pub configs: Vec<DotletConfig>,
}

#[derive(Debug)]
pub struct Config {
    pub profile_name: String,
    pub dotfiles_dir: String,
    pub home_dir: String,
    pub backup_dir: String,
    pub state_file: String,
    pub profiles: Vec<Profile>,
    pub dotlets: Vec<Dotlet>,
}

#[derive(Deserialize, Serialize, Debug)]
struct State {
    linked_configs: Vec<String>,
    backup_configs: Vec<String>,
}

fn filter_dotlets_by_profile(config: &Config) -> Vec<&Dotlet> {
    let current_profile = config
        .profiles
        .iter()
        .find(|profile| profile.name == config.profile_name);
    let mut dotlets: Vec<&Dotlet> = vec![];

    match current_profile {
        Some(profile) => {
            for dotlet in config.dotlets.iter() {
                if profile
                    .dotlets
                    .iter()
                    .all(|profile_dotlet_name| !profile_dotlet_name.eq(&dotlet.name))
                {
                    continue;
                };

                dotlets.push(dotlet);
            }
            dotlets
        }
        None => config.dotlets.iter().collect(),
    }
}

fn link_configs_to_home(config: &Config) -> Result<State, io::Error> {
    let mut state = State {
        linked_configs: vec![],
        backup_configs: vec![],
    };

    filter_dotlets_by_profile(&config)
        .iter()
        .fold(vec![], |mut acc, dotlet| {
            dotlet.configs.iter().for_each(|dotlet_config| {
                let link = format!("{}/{}", &config.home_dir, &dotlet_config.to);
                let origin = format!(
                    "{}/{}/{}",
                    &config.dotfiles_dir, &dotlet.path, &dotlet_config.from
                );
                let backup = format!("{}/{}", &config.backup_dir, &dotlet_config.to);

                if let Ok(_) = fs::metadata(&link) {
                    fs::create_dir_all(Path::new(&backup).parent().unwrap()).unwrap();
                    fs::rename(&link, &backup).unwrap();
                    state.backup_configs.push(backup);
                };

                fs::create_dir_all(Path::new(&link).parent().unwrap()).unwrap();

                let result = unix::fs::symlink(origin, &link);
                acc.push(result);
                state.linked_configs.push(link);
            });
            acc
        });

    Ok(state)
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
        let old_state = restore(&state_file)?;
        remove_links(&old_state.linked_configs)?;
    }

    Ok(())
}

fn save(file: &str, state: &State) -> Result<(), Box<dyn Error>> {
    let string = ron::to_string(&state)?;
    fs::write(file, string)?;
    Ok(())
}

fn restore(file: &str) -> Result<State, Box<dyn Error>> {
    let file = fs::read_to_string(&file)?;
    let restored_state: State = ron::from_str(&file)?;
    Ok(restored_state)
}

pub fn install(config: &Config) -> Result<(), Box<dyn Error>> {
    remove_old_links(&config.state_file)?;
    let state = link_configs_to_home(&config)?;
    save(&config.state_file, &state)?;
    Ok(())
}

fn create_test_home_dir(tmp_dir: &str, user_dir: &str) -> String {
    let test_home_dir = format!("{}/{}/home", tmp_dir, user_dir);
    if let Ok(_) = fs::metadata(&test_home_dir) {
        fs::remove_dir_all(&test_home_dir).unwrap();
    }

    fs::create_dir_all(&test_home_dir).unwrap();

    return test_home_dir;
}

pub fn create_test_config(user_dir: &str) -> Config {
    let current_dir = env::current_dir().unwrap();
    let current_dir = current_dir.display();
    let dotfiles_dir = format!("{}/fixtures/dotfiles", current_dir);
    let tmp_dir = format!("{}/tmp", current_dir);
    let home_dir = create_test_home_dir(&tmp_dir, user_dir);
    let backup_dir = format!("{}/.local/share/backup", home_dir);
    let state_file = format!("{}/.local/state.ron", home_dir);

    fs::create_dir_all(Path::new(&state_file).parent().unwrap()).unwrap();
    fs::create_dir_all(&backup_dir).unwrap();

    return Config {
        home_dir,
        dotfiles_dir,
        backup_dir,
        state_file,
        dotlets: vec![],
        profiles: vec![],
        profile_name: "".to_string(),
    };
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn link_dotlet_configs() {
        let mut config = create_test_config("link_dotlet_configs");
        let mut dotlets = vec![
            Dotlet {
                name: "dotlet_a".to_string(),
                path: "dotlet_a".to_string(),
                configs: vec![],
            },
            Dotlet {
                name: "dotlet_b".to_string(),
                path: "dotlet_b".to_string(),
                configs: vec![DotletConfig {
                    from: ".config_file".to_string(),
                    to: ".config_file".to_string(),
                }],
            },
            Dotlet {
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
                    },
                ],
            },
        ];
        config.dotlets.append(&mut dotlets);

        link_configs_to_home(&config).unwrap();

        let expected_config_links = [
            ".config_file",
            ".config_dir/.config_file",
            ".config_dir/config_dir/.config_file",
        ];
        assert!(expected_config_links.iter().all(|config_link| {
            let config_link_full_path = format!("{}/{}", &config.home_dir, &config_link);

            let is_symlink = match fs::symlink_metadata(&config_link_full_path) {
                Ok(metadata) => metadata.file_type().is_symlink(),
                Err(_) => return false,
            };

            if !is_symlink {
                return false;
            }

            fs::read_link(&config_link_full_path).is_ok()
        }));
    }

    #[test]
    fn create_config_dirs() {
        let mut config = create_test_config("create_config_dirs");
        config.dotlets.push(Dotlet {
            name: "dotlet_c".to_string(),
            path: "dotlet_c".to_string(),
            configs: vec![DotletConfig {
                from: ".config_dir/config_dir/.config_file".to_string(),
                to: ".config_dir/config_dir/.config_file".to_string(),
            }],
        });

        link_configs_to_home(&config).unwrap();

        assert!(
            match fs::symlink_metadata(format!("{}/.config_dir/config_dir/", &config.home_dir)) {
                Ok(metadata) => metadata.file_type().is_dir(),
                Err(_) => false,
            }
        );
    }

    #[test]
    fn backup_existing_configs() {
        let mut config = create_test_config("backup_existing_configs");
        config.dotlets.push(Dotlet {
            name: "dotlet_c".to_string(),
            path: "dotlet_c".to_string(),
            configs: vec![DotletConfig {
                from: ".config_dir/.config_file".to_string(),
                to: ".config_dir/.config_file".to_string(),
            }],
        });
        fs::create_dir_all(&config.backup_dir).unwrap();
        fs::create_dir(format!("{}/.config_dir", &config.home_dir)).unwrap();
        fs::File::create(format!("{}/.config_dir/.config_file", &config.home_dir)).unwrap();

        link_configs_to_home(&config).unwrap();

        assert!(
            fs::metadata(format!("{}/.config_dir/.config_file", &config.backup_dir))
                .unwrap()
                .is_file()
        );
    }

    #[test]
    fn save_state() {
        let config = create_test_config("save_state");
        let state = State {
            linked_configs: vec![format!("{}/.config_file", &config.home_dir)],
            backup_configs: vec![format!("{}/.config_file", &config.home_dir)],
        };
        fs::create_dir_all(Path::new(&config.state_file).parent().unwrap()).unwrap();

        save(&config.state_file, &state).unwrap();

        assert!(Path::new(&config.state_file).try_exists().is_ok());
    }

    #[test]
    fn restore_state() {
        let config = create_test_config("restore_state");
        let state = State {
            linked_configs: vec![format!("{}/.config_file", &config.home_dir)],
            backup_configs: vec![format!("{}/.config_file", &config.home_dir)],
        };
        fs::create_dir_all(Path::new(&config.state_file).parent().unwrap()).unwrap();
        save(&config.state_file, &state).unwrap();

        let restored_state = restore(&config.state_file).unwrap();

        assert_eq!(restored_state.linked_configs, state.linked_configs);
        assert_eq!(restored_state.backup_configs, state.backup_configs);
    }

    #[test]
    fn removing_old_links() {
        let mut config = create_test_config("removing_old_links");
        config.dotlets.push(Dotlet {
            name: "dotlet_c".to_string(),
            path: "dotlet_c".to_string(),
            configs: vec![DotletConfig {
                from: ".config_dir/config_dir/.config_file".to_string(),
                to: ".config_dir/config_dir/.config_file".to_string(),
            }],
        });
        let state = link_configs_to_home(&config).unwrap();
        fs::create_dir_all(Path::new(&config.state_file).parent().unwrap()).unwrap();
        save(&config.state_file, &state).unwrap();

        remove_old_links(&config.state_file).unwrap();

        state
            .linked_configs
            .iter()
            .for_each(|linked_config: &String| {
                let config_path = format!("{}/{}", &config.home_dir, &linked_config);
                let config_exists = Path::new(&config_path).try_exists();

                assert!(config_exists.is_ok() && !config_exists.unwrap());
            });
    }

    #[test]
    fn install_dotlets_of_profile() {
        let mut config = create_test_config("install_dotlets_in_profile");
        let mut dotlets = vec![
            Dotlet {
                name: "dotlet_b".to_string(),
                path: "dotlet_b".to_string(),
                configs: vec![DotletConfig {
                    from: ".config_file".to_string(),
                    to: ".config_file".to_string(),
                }],
            },
            Dotlet {
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
                    },
                ],
            },
        ];
        config.dotlets.append(&mut dotlets);
        config.profiles.push(Profile {
            name: "venus".to_string(),
            dotlets: vec!["dotlet_b".to_string()],
        });
        config.profile_name = "venus".to_string();

        link_configs_to_home(&config).unwrap();

        let config_exists = Path::new(&format!(
            "{}/{}",
            &config.home_dir,
            ".config_file".to_string()
        ))
        .try_exists()
        .unwrap();
        assert!(config_exists);
        let config_exists = Path::new(&format!(
            "{}/{}",
            &config.home_dir,
            ".config_dir/.config_file".to_string()
        ))
        .try_exists()
        .unwrap();
        assert!(!config_exists);
        let config_exists = Path::new(&format!(
            "{}/{}",
            &config.home_dir,
            ".config_dir/config_dir/.config_file".to_string()
        ))
        .try_exists()
        .unwrap();
        assert!(!config_exists);
    }
}
