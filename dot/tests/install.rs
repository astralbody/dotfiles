extern crate dot;
use std::path::{Path};

// TODO:
// [ ] - write test to verify that backups work

#[test]
fn install_dotfiles() {
    let config = dot::create_test_config("install_dotfiles");

    dot::install(&config).unwrap();

    [
        ".config_dir/config_dir/.config_file",
        ".config_dir/.config_file",
        ".config_file"
    ].into_iter().for_each(|linked_config| {
        let config_path = format!("{}/{}", &linked_config, &config.home_dir);
        let config_path = Path::new(&config_path);

        assert!(config_path.try_exists().is_ok());
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
