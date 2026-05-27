use crate::{
    backend::{pacman::PacmanUpdater, updater::Updater},
    ui::update_list::UpdateList,
};

pub fn pacman_page() -> gtk::Box {
    let widget = UpdateList::new("Pacman Updates");

    let updater = PacmanUpdater::new();

    let available_updates = updater.check_for_updates();

    for u in available_updates {
        widget.add_update(&u.package, &u.old_version, &u.new_version);
    }

    let updater_clone = updater.clone();
    widget.set_on_refresh(move || {
        println!("Refresh pacman updates");

        let available_updates = updater_clone.check_for_updates();
        for u in available_updates {
            widget.add_update(&u.package, &u.old_version, &u.new_version);
        }
    });

    let updater_clone = updater.clone();
    widget.set_on_update(move || {
        println!("Updating pacman packages");
        let res = updater_clone.update();
        // TODO: toast notification instead of print
        match res {
            Ok(v) => {
                println!("Update ok");
            }
            Err(e) => {
                println!("Error with updating");
            }
        }
    });

    widget.container
}
