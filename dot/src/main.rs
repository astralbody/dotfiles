use std::fs;

use clap::{Parser};
use dot::{Config, Dotlet, Profile, DotletConfig};
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

fn build_config(args: Args, config_file: ConfigFile) -> Config {
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

fn parse_config_file(config_path: &str) -> ConfigFile {
    let config_file = fs::read_to_string(&config_path).unwrap();
    let config_file: ConfigFile = ron::from_str(&config_file).unwrap();
    return config_file
}

fn main() {
 /*    let configFile = ConfigFile {
        profiles: vec![Profile {
            name: "venus".to_string(),
            dotlets: vec!["dotlet_b".to_string()],
        }],
        dotlets: vec![
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
        ]
    };
    let string = ron::to_string(&configFile);
    fs::write("./dotfiles.ron", string.unwrap()); */

    let args = Args::parse();
    let config_file = parse_config_file(&args.config);

    let config = build_config(args, config_file);
    println!("{:?}", config);
    /* let config = Config::build("../", "").unwrap_or_else(|err| {
        println!("Problem parsing arguments: {err}");
        process::exit(1);
    }); */

    /* let dotfiles_dirs = get_dotlets(config);
    println!("{:?}", dotfiles_dirs); */
}
