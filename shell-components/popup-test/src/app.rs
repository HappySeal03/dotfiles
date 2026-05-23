use std::path::PathBuf;
use std::rc::Rc;

use gtk::gdk;
use gtk::prelude::*;
use gtk4 as gtk;
use gtk4_layer_shell::{KeyboardMode, Layer, LayerShell};

use crate::models::actions::Action;
use crate::services::mpris::MprisService;
use crate::widgets::player::Player;

pub fn run() -> glib::ExitCode {
    let app = gtk::Application::builder()
        .application_id("com.example.popup-test")
        .build();

    app.connect_activate(build_ui);

    app.run()
}

fn build_ui(app: &gtk::Application) {
    let (tx, rx) = flume::unbounded::<Action>();

    load_css();

    let window = gtk::ApplicationWindow::builder()
        .application(app)
        .title("Music Popup")
        .decorated(false)
        .resizable(false)
        .build();

    let mpris = Rc::new(MprisService::new());

    // Layer shell setup
    window.init_layer_shell();
    window.set_layer(Layer::Overlay);
    window.set_keyboard_mode(KeyboardMode::OnDemand);

    // Events handling
    {
        let win_clone = window.clone();
        let mpris_clone = mpris.clone();
        setup_keyboard_shortcuts(&window, tx.clone());

        glib::MainContext::default().spawn_local(async move {
            while let Ok(action) = rx.recv_async().await {
                handle_action(action, &win_clone, &mpris_clone);
            }
        });
    }
    // Main widget
    let popup = Rc::new(Player::new(tx));

    // Placeholder setup
    popup.setup_callbacks();

    window.set_child(Some(popup.widget()));

    // ------------------------------------------------------------
    // Periodic UI refresh
    // ------------------------------------------------------------

    {
        let popup = popup.clone();
        let mpris = mpris.clone();

        glib::timeout_add_local(std::time::Duration::from_millis(500), move || {
            let state = mpris.current_state();

            popup.set_title(&state.title);
            popup.set_artist(&state.artist);
            popup.set_playing(state.playing);

            if let Some(path) = state.artwork_path {
                popup.set_album_art(&path);
            }

            glib::ControlFlow::Continue
        });
    }

    window.present();
}

fn load_css() {
    let provider = gtk::CssProvider::new();

    let mut path: PathBuf = glib::user_config_dir();
    path.push("simple-mpris-controls");
    path.push("style.css");

    provider.load_from_path(path);

    gtk::style_context_add_provider_for_display(
        &gdk::Display::default().expect("Failed to get display"),
        &provider,
        gtk::STYLE_PROVIDER_PRIORITY_APPLICATION,
    );
}

fn setup_keyboard_shortcuts(window: &gtk::ApplicationWindow, tx: flume::Sender<Action>) {
    let controller = gtk::EventControllerKey::new();

    controller.set_propagation_phase(gtk::PropagationPhase::Capture);

    controller.connect_key_pressed(move |_, key, _, _| {
        let action = match key {
            gdk::Key::space => Some(Action::PlayPause),
            gdk::Key::b => Some(Action::Previous),
            gdk::Key::n => Some(Action::Next),

            gdk::Key::q => Some(Action::Close),
            gdk::Key::Escape => Some(Action::Close),
            gdk::Key::m => Some(Action::Close),
            _ => None,
        };

        if let Some(action) = action {
            tx.send(action).ok();
            return glib::Propagation::Stop;
        }

        glib::Propagation::Proceed
    });

    window.add_controller(controller);
}

fn handle_action(action: Action, window: &gtk::ApplicationWindow, mpris: &MprisService) {
    match action {
        Action::PlayPause => mpris.play_pause(),
        Action::Next => mpris.next(),
        Action::Previous => mpris.previous(),
        Action::Close => window.close(),
    }
}
