use std::{error::Error, process::Command};

use crate::backend::updater::{Update, Updater};

#[derive(Clone)]
pub struct PacmanUpdater;

impl PacmanUpdater {
    pub fn new() -> Self {
        Self
    }
}

impl Updater for PacmanUpdater {
    fn lock_db(&self) -> Result<bool, Box<dyn std::error::Error>> {
        Ok(false)
    }

    fn check_for_updates(&self) -> Vec<Update> {
        let output = Command::new("checkupdates")
            .output()
            .expect("failed to execute checkupdates");

        let stdout = String::from_utf8_lossy(&output.stdout);

        stdout
            .lines()
            .filter_map(|line| {
                // Format: package old_version -> new_version
                let parts: Vec<&str> = line.split_whitespace().collect();

                if parts.len() >= 4 {
                    Some(Update {
                        package: parts[0].to_string(),
                        old_version: parts[1].to_string(),
                        new_version: parts[3].to_string(),
                    })
                } else {
                    None
                }
            })
            .collect()
    }

    fn update(&self) -> Result<bool, Box<dyn Error>> {
        let status = Command::new("pkexec").arg("pacman").arg("-Syu").status()?;

        Ok(status.success())
    }
}
