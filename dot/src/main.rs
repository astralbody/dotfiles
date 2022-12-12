use std::fs;

use clap::{Parser};
use dot::{Config, Dotlet, Profile};
use serde::{Deserialize, Serialize};
/* use dot::{Config,get_dotlets}; */

// Algorithm:
// 1. Collect all dotlets in dotfiles
//   - Ignore sandbox, node_modules and etc
// 2. Collect configs from dotlets
//   - Ignore .gitkeep
// 3. Link configs to home dir
// 4. Cover with unit and integration tests
// 5. Integrate with dotfiles

// TODO:
// - [x] create config
// - [ ] add unit and integration tests
// - [ ] error handling

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(short, long)]
    dotfiles: String,

    #[arg(short = 'm', long)]
    home: String,

    #[arg(short, long)]
    profile: String,

    #[arg(short, long)]
    config: String,

    #[arg(short, long)]
    backup: Option<String>,

    #[arg(short, long)]
    state: Option<String>,
}

#[derive(Deserialize, Serialize, Debug)]
struct ConfigFile {
    dotlets: Vec<Dotlet>,
    profiles: Vec<Profile>
}

fn parse_config_file(config_path: &str) -> ConfigFile {
    let config_file = fs::read_to_string(&config_path).unwrap();
    let config_file: ConfigFile = ron::from_str(&config_file).unwrap();
    return config_file
}

fn build_config() -> Config {
    let args = Args::parse();
    let config_file = parse_config_file(&args.config);

    let backup_dir = args.backup.or(Some(format!("{}/.local/share/backup", args.home))).unwrap();
    let state_file = args.state.or(Some(format!("{}/.local/share/backup", args.home))).unwrap();

    Config {
        dotfiles_dir: args.dotfiles,
        home_dir: args.home,
        profile_name: args.profile,
        backup_dir,
        state_file,
        dotlets: config_file.dotlets,
        profiles: config_file.profiles
    }
}

fn run() {
    let config = build_config();
    println!("{:?}", config);
}

fn main() {
    run();
    /* let config = Config::build("../", "").unwrap_or_else(|err| {
        println!("Problem parsing arguments: {err}");
        process::exit(1);
    }); */

    /* let dotfiles_dirs = get_dotlets(config);
    println!("{:?}", dotfiles_dirs); */
}
