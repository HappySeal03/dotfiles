mod backend;
mod ui;

use adw::prelude::*;

fn main() {
    adw::init().expect("Failed to init libadwaita");

    let app = adw::Application::builder()
        .application_id("com.example.UpdateCenter")
        .build();

    app.connect_activate(ui::window::build_ui);

    app.run();
}
