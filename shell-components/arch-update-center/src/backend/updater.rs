use std::error::Error;

pub struct Update {
    pub package: String,
    pub old_version: String,
    pub new_version: String,
}

pub trait Updater {
    fn check_for_updates(&self) -> Vec<Update>;
    fn update(&self) -> Result<bool, Box<dyn Error>>;
    fn lock_db(&self) -> Result<bool, Box<dyn Error>>;
}
