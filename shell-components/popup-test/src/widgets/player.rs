use std::cell::RefCell;

use crate::models::actions::Action;
use gtk::prelude::*;
use gtk4::{self as gtk, gdk_pixbuf, gio};

use flume::Sender;

pub struct Player {
    root: gtk::Box,

    action_tx: Sender<Action>,

    album_art: gtk::Picture,

    title: gtk::Label,
    artist: gtk::Label,

    previous_button: gtk::Button,
    play_pause_button: gtk::Button,
    next_button: gtk::Button,

    cached_art_uri: RefCell<Option<String>>,
    cached_texture: RefCell<Option<gtk::gdk::Texture>>,
}

impl Player {
    pub fn new(action_tx: Sender<Action>) -> Self {
        // ------------------------------------------------------------
        // Root
        // ------------------------------------------------------------

        let root = gtk::Box::new(gtk::Orientation::Horizontal, 20);

        root.add_css_class("player-popup");

        // ------------------------------------------------------------
        // Album art container
        // ------------------------------------------------------------
        let art_container = gtk::Frame::new(None);

        art_container.set_size_request(160, 160);
        art_container.set_hexpand(false);
        art_container.set_vexpand(false);
        art_container.add_css_class("album-frame");

        // ------------------------------------------------------------
        // Album art
        // ------------------------------------------------------------

        let album_art = gtk::Picture::new();
        album_art.set_size_request(160, 160);
        album_art.set_hexpand(false);
        album_art.set_vexpand(false);
        album_art.add_css_class("album-art");

        album_art.set_content_fit(gtk::ContentFit::Cover);
        album_art.set_can_shrink(true);

        art_container.set_child(Some(&album_art));

        // ------------------------------------------------------------
        // Right content
        // ------------------------------------------------------------

        let right = gtk::Box::new(gtk::Orientation::Vertical, 12);

        right.set_hexpand(true);
        right.set_vexpand(true);

        // ------------------------------------------------------------
        // Metadata section
        // ------------------------------------------------------------

        let metadata = gtk::Box::new(gtk::Orientation::Vertical, 4);

        let title = gtk::Label::new(Some("Song Title"));

        title.set_xalign(0.0);

        title.add_css_class("song-title");

        let artist = gtk::Label::new(Some("Artist Name"));

        artist.set_xalign(0.0);

        artist.add_css_class("artist-name");

        metadata.append(&title);
        metadata.append(&artist);

        // ------------------------------------------------------------
        // Spacer
        // ------------------------------------------------------------

        let spacer = gtk::Box::new(gtk::Orientation::Vertical, 0);

        spacer.set_vexpand(true);

        // ------------------------------------------------------------
        // Controls
        // ------------------------------------------------------------

        let controls = gtk::Box::new(gtk::Orientation::Horizontal, 10);

        let previous_button = gtk::Button::from_icon_name("media-skip-backward-symbolic");

        let play_pause_button = gtk::Button::from_icon_name("media-playback-start-symbolic");

        let next_button = gtk::Button::from_icon_name("media-skip-forward-symbolic");

        previous_button.add_css_class("control-button");
        play_pause_button.add_css_class("control-button");
        next_button.add_css_class("control-button");

        controls.append(&previous_button);
        controls.append(&play_pause_button);
        controls.append(&next_button);

        // ------------------------------------------------------------
        // Keyboard hints
        // ------------------------------------------------------------

        let hints = gtk::Label::new(Some(
            "b: previous    space: play/pause    n: next    Esc/q: close",
        ));

        hints.set_xalign(0.0);

        hints.add_css_class("key-hints");

        // ------------------------------------------------------------
        // Compose
        // ------------------------------------------------------------

        right.append(&metadata);
        right.append(&spacer);
        right.append(&controls);
        right.append(&hints);

        root.append(&art_container);
        root.append(&right);

        Self {
            root,

            action_tx,

            album_art,

            title,
            artist,

            previous_button,
            play_pause_button,
            next_button,

            cached_art_uri: RefCell::new(None),
            cached_texture: RefCell::new(None),
        }
    }

    // ------------------------------------------------------------
    // Public API
    // ------------------------------------------------------------

    pub fn widget(&self) -> &gtk::Box {
        &self.root
    }

    pub fn setup_callbacks(&self) {
        let tx1 = self.action_tx.clone();
        self.previous_button.connect_clicked(move |_| {
            let _ = tx1.send(Action::Previous);
        });

        let tx2 = self.action_tx.clone();
        self.play_pause_button.connect_clicked(move |_| {
            let _ = tx2.send(Action::PlayPause);
        });

        let tx3 = self.action_tx.clone();
        self.next_button.connect_clicked(move |_| {
            let _ = tx3.send(Action::Next);
        });
    }

    // ------------------------------------------------------------
    // UI update methods
    // ------------------------------------------------------------

    pub fn set_title(&self, title: &str) {
        self.title.set_label(title);
    }

    pub fn set_artist(&self, artist: &str) {
        self.artist.set_label(artist);
    }

    pub fn set_album_art(&self, uri: &str) {
        // Album art didn't change
        {
            let cached = self.cached_art_uri.borrow();

            if cached.as_deref() == Some(uri) {
                return;
            }
        }

        // Different album art
        let file = gio::File::for_uri(uri);

        if let Some(path) = file.path() {
            match gdk_pixbuf::Pixbuf::from_file_at_scale(path, 160, 160, true) {
                Ok(pixbuf) => {
                    let texture = gtk::gdk::Texture::for_pixbuf(&pixbuf);
                    self.album_art.set_paintable(Some(&texture));

                    // update cache
                    *self.cached_art_uri.borrow_mut() = Some(uri.to_string());
                    *self.cached_texture.borrow_mut() = Some(texture);
                }

                Err(err) => {
                    eprintln!("Failed to load album art: {err}");
                }
            }
        }
    }

    pub fn set_playing(&self, playing: bool) {
        let icon = if playing {
            "media-playback-pause-symbolic"
        } else {
            "media-playback-start-symbolic"
        };

        self.play_pause_button.set_icon_name(icon);
    }
}
