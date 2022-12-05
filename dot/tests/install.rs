extern crate dot;
use std::path::{Path};
use std::fs;

// TODO:
// [ ] - write test to verify that backups work

#[test]
fn install_dotfiles() {
    let mut config = dot::create_test_config("install_dotfiles");
    let mut dotlets = vec![
        dot::Dotlet {
            name: "dotlet_a".to_string(),
            path: "dotlet_a".to_string(),
            configs: vec![]
        },
        dot::Dotlet {
            name: "dotlet_b".to_string(),
            path: "dotlet_b".to_string(),
            configs: vec![
                dot::DotletConfig {
                    from: ".config_file".to_string(),
                    to: ".config_file".to_string(),
                }
            ]
        },
        dot::Dotlet {
            name: "dotlet_c".to_string(),
            path: "dotlet_c".to_string(),
            configs: vec![
                dot::DotletConfig {
                    from: ".config_dir/config_dir/.config_file".to_string(),
                    to: ".config_dir/config_dir/.config_file".to_string(),
                },
                dot::DotletConfig {
                    from: ".config_dir/.config_file".to_string(),
                    to: ".config_dir/.config_file".to_string(),
                }
            ]
        }
    ];
    config.dotlets.append(&mut dotlets);
    fs::create_dir_all(Path::new(&config.state_file).parent().unwrap()).unwrap();
    fs::create_dir_all(&config.backup_dir).unwrap();

    dot::install(&config).unwrap();

    [
        ".config_dir/config_dir/.config_file",
        ".config_dir/.config_file",
        ".config_file"
    ].into_iter().for_each(|linked_config| {
        let config_path = format!("{}/{}", &config.home_dir, &linked_config);
        let config_path = Path::new(&config_path);

        assert!(config_path.try_exists().is_ok() && config_path.try_exists().unwrap());
        assert!(config_path.is_symlink());
        assert!(config_path.is_file());
        assert!(config_path.read_link().unwrap().to_str().unwrap().contains(&config.dotfiles_dir));
    });
}

#[test]
fn save_state() {
    let config = dot::create_test_config("save_state");

    dot::install(&config).unwrap();

    assert!(Path::new(&config.state_file).try_exists().unwrap());
}


/* #[test]
fn remove_dangling_links() {
}
 */
