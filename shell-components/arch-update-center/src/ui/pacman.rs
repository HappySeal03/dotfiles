use std::{process::Command, rc::Rc};

use gtk::gio;

use crate::{
    backend::{pacman::PacmanUpdater, updater::Updater},
    ui::update_list::UpdateList,
};

pub fn pacman_page() -> gtk::Box {
    let widget = Rc::new(UpdateList::new("Pacman Updates"));

    let updater = PacmanUpdater::new();

    refresh_updates_async(Rc::clone(&widget), updater.clone());

    // Refresh callback
    {
        let widget_clone = Rc::clone(&widget);
        let updater = updater.clone();

        widget.set_on_refresh(move || {
            println!("Refresh pacman updates");

            refresh_updates_async(Rc::clone(&widget_clone), updater.clone());
        });
    }

    // Update callback
    {
        let widget_clone = Rc::clone(&widget);
        let updater = updater.clone();

        widget.set_on_update(move || {
            println!("Updating pacman packages");

            run_update_async(Rc::clone(&widget_clone), updater.clone());
        });
    }

    widget.container.clone()
}

fn refresh_updates_async(widget: Rc<UpdateList>, updater: PacmanUpdater) {
    widget.clear();
    widget.set_loading(true, "Checking for updates...");

    glib::MainContext::default().spawn_local(async move {
        let updates = gio::spawn_blocking(move || updater.check_for_updates())
            .await
            .expect("spawn_blocking failed");

        widget.set_loading(false, "");

        if updates.is_empty() {
            widget.add_update("System", "Up to date", "");
            return;
        }

        for u in updates {
            widget.add_update(&u.package, &u.old_version, &u.new_version);
        }
    });
}

fn run_update_async(widget: Rc<UpdateList>, updater: PacmanUpdater) {
    widget.clear();
    widget.set_loading(true, "Updating...");

    notify(
        "System update started",
        "The updater has started an update using pacman",
    );

    glib::MainContext::default().spawn_local(async move {
        let result = gio::spawn_blocking(move || updater.update())
            .await
            .expect("spawn_blocking failed");

        widget.set_loading(false, "");

        match result {
            Ok(true) => {
                notify("System updated", "Pacman update completed successfully");
                widget.add_update("System", "Update completed", "");
            }
            Ok(false) => {
                notify("Update failed", "Pacman returned a failure status");
                widget.add_update("System", "Update failed", "");
            }
            Err(e) => {
                notify("Update error", &e.to_string());
                widget.add_update("Error", "Update failed", &e.to_string());
            }
        }
    });
}

fn notify(title: &str, body: &str) {
    let _ = Command::new("notify-send").arg(title).arg(body).status();
}
