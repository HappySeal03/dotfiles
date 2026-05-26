use adw::prelude::*;

use crate::ui::{flatpak::flatpak_page, news::news_page, pacman::pacman_page, yay::yay_page};

pub fn build_ui(app: &adw::Application) {
    let window = adw::ApplicationWindow::builder()
        .application(app)
        .title("Update Center")
        .default_width(900)
        .default_height(600)
        .build();

    // Root layout
    let root = gtk::Box::new(gtk::Orientation::Vertical, 0);

    // Header bar
    let header = adw::HeaderBar::new();

    // View stack (pages)
    let stack = adw::ViewStack::new();

    // Pages
    let pacman = pacman_page();
    let flatpak = flatpak_page();
    let news = news_page();
    let yay = yay_page();

    stack.add_titled(&pacman, Some("pacman"), "Pacman");
    stack.add_titled(&flatpak, Some("flatpak"), "Flatpak");
    stack.add_titled(&news, Some("news"), "News");
    stack.add_titled(&yay, Some("yay"), "Yay");

    // Tab switcher
    let switcher = adw::ViewSwitcher::builder()
        .stack(&stack)
        .policy(adw::ViewSwitcherPolicy::Wide)
        .build();

    header.set_title_widget(Some(&switcher));

    root.append(&header);
    root.append(&stack);

    window.set_content(Some(&root));
    window.present();
}
