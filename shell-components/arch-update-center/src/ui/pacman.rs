use crate::ui::update_list::UpdateList;

pub fn pacman_page() -> gtk::Box {
    let widget = UpdateList::new("Pacman Updates");

    widget.add_update("Example", "1.0", "1.1");
    widget.add_update("Example", "1.0", "1.2");
    widget.add_update("Example", "1.0", "1.3");
    widget.add_update("Example", "1.0", "1.4");
    widget.add_update("Example", "1.0", "1.5");
    widget.add_update("Example", "1.0", "1.6");
    widget.add_update("Example", "1.0", "1.7");
    widget.add_update("Example", "1.0", "1.8");
    widget.add_update("Example", "1.0", "1.9");
    widget.add_update("Example", "1.0", "1.10");
    widget.add_update("Example", "1.0", "1.11");
    widget.add_update("Example", "1.0", "1.12");

    widget.set_on_refresh(|| {
        println!("Refresh pacman updates");
    });

    widget.set_on_update(|| {
        println!("Updating pacman packages");
    });

    widget.container
}
