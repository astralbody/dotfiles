use clap::{Parser, Arg};
use dot::Config;
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

fn build_config(args: Args) -> Config {
    let backup_dir = args.backup.or(Some(format!("{}/.local/share/backup", args.home))).unwrap();
    let state_file = args.state.or(Some(format!("{}/.local/share/backup", args.home))).unwrap()

    Config {
        backup_dir,
        state_file,
    }
}

fn main() {
    let args = Args::parse();
    println!("{:?}", args);
    /* let config = Config::build("../", "").unwrap_or_else(|err| {
        println!("Problem parsing arguments: {err}");
        process::exit(1);
    }); */

    /* let dotfiles_dirs = get_dotlets(config);
    println!("{:?}", dotfiles_dirs); */
}
