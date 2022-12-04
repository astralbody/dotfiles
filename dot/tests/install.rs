extern crate dot;
use std::fs;
use std::path::{Path};

// TODO:
// [ ] - write test to verify that backups work

fn create_test_home_dir(test_dir: &str) -> String {
    let tmp_dir = "/shared_disk/projects/dotfiles/dot/tmp";
    let test_home_dir = format!("{}/{}/home", tmp_dir, test_dir);
    if let Ok(_) = fs::metadata(&test_home_dir) {
        fs::remove_dir_all(&test_home_dir).unwrap();
    }

    fs::create_dir_all(&test_home_dir).unwrap();

    return test_home_dir;
}

#[test]
fn install_dotfiles() {
    let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles".to_string();
    let test_home_dir = create_test_home_dir("install_dotfiles");
    let backup_dir = format!("{}/.local/share/backup", test_home_dir);
    let state_file = format!("{}/.local/state/state.json", test_home_dir);
    let config = dot::Config::build(
        dotfiles_dir.clone(),
        test_home_dir.clone(),
        backup_dir.clone(),
        state_file.clone()
    ).unwrap();

    dot::install(config).unwrap();

    [
        ".config_dir/config_dir/.config_file",
        ".config_dir/.config_file",
        ".config_file"
    ].into_iter().for_each(|config| {
        let config_path = format!("{}/{}", &test_home_dir, &config);
        let config_path = Path::new(&config_path);

        assert!(config_path.try_exists().is_ok());
        assert!(config_path.is_symlink());
        assert!(config_path.is_file());
        assert!(config_path.read_link().unwrap().to_str().unwrap().contains(&dotfiles_dir));
    });
}

#[test]
fn save_state() {
    let dotfiles_dir = "/shared_disk/projects/dotfiles/dot/fixtures/dotfiles".to_string();
    let test_home_dir = create_test_home_dir("save_state");
    let backup_dir = format!("{}/.local/share/backup", test_home_dir);
    let state_file = format!("{}/.local/state/state.json", test_home_dir);
    let config = dot::Config::build(
        dotfiles_dir.clone(),
        test_home_dir.clone(),
        backup_dir.clone(),
        state_file.clone()
    ).unwrap();

    dot::install(config).unwrap();

    assert!(Path::new(&state_file).try_exists().unwrap());
}


/* #[test]
fn remove_dangling_links() {
}
 */
