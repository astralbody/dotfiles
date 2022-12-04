use std::process;
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

fn main() {
    /* let config = Config::build("../", "").unwrap_or_else(|err| {
        println!("Problem parsing arguments: {err}");
        process::exit(1);
    }); */

    /* let dotfiles_dirs = get_dotlets(config);
    println!("{:?}", dotfiles_dirs); */
}
