use std::{fs, error::Error};

use clap::{Parser};
use dot::{Config, Dotlet, Profile, install};
use serde::{Deserialize, Serialize};
/* use dot::{Config,get_dotlets}; */

extern crate exitcode;

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
// - [x] error handling
// - [ ] add unit and integration tests

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

fn parse_config_file(config_path: &str) -> Result<ConfigFile, Box<dyn Error>>{
    let config_file = fs::read_to_string(&config_path)?;
    let config_file: ConfigFile = ron::from_str(&config_file)?;
    Ok(config_file)
}

fn build_config() -> Result<Config, Box<dyn Error>> {
    let args = Args::parse();
    let config_file = parse_config_file(&args.config)?;

    let backup_dir = args.backup.or(Some(format!("{}/.local/share/backup", args.home))).unwrap();
    let state_file = args.state.or(Some(format!("{}/.local/share/backup", args.home))).unwrap();

    Ok(Config {
        dotfiles_dir: args.dotfiles,
        home_dir: args.home,
        profile_name: args.profile,
        backup_dir,
        state_file,
        dotlets: config_file.dotlets,
        profiles: config_file.profiles
    })
}

fn run() -> Result<(), Box<dyn Error>> {
    let config = build_config()?;
    install(&config)?;
    Ok(())
}

fn main() {
    let result = run();
    match result {
        Ok(_) => {
            println!("Done!");
            std::process::exit(exitcode::OK);
        }
        Err(err) => {
            eprintln!("{:#}", err);
            std::process::exit(1);
        }
    }
}
