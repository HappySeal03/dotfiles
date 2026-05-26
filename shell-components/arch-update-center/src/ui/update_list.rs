use gtk::{Box, Orientation, ScrolledWindow, prelude::*};
use gtk::{Button, Label, ListBox, ListBoxRow};

pub struct UpdateList {
    pub container: gtk::Box,
    pub list: ListBox,
    refresh_button: Button,
    update_button: Button,
}

impl UpdateList {
    pub fn new(title: &str) -> Self {
        let container = gtk::Box::new(gtk::Orientation::Vertical, 12);

        container.set_margin_top(16);
        container.set_margin_bottom(16);
        container.set_margin_start(16);
        container.set_margin_end(16);

        let header = gtk::Box::new(gtk::Orientation::Horizontal, 8);

        let label = Label::builder()
            .label(title)
            .xalign(0.0)
            .hexpand(true)
            .css_classes(vec!["title-2"])
            .build();

        let refresh_button = Button::with_label("Refresh");
        refresh_button.add_css_class("suggested-action");

        let update_button = Button::with_label("Update");
        update_button.add_css_class("suggested-action");

        header.append(&label);
        header.append(&refresh_button);
        header.append(&update_button);
        header.set_hexpand(true);

        let scroll = ScrolledWindow::builder()
            .vexpand(true)
            .hscrollbar_policy(gtk::PolicyType::Never)
            .vscrollbar_policy(gtk::PolicyType::Automatic)
            .build();

        let list = ListBox::new();
        list.add_css_class("boxed-list");

        scroll.set_child(Some(&list));

        container.append(&header);
        container.append(&scroll);

        Self {
            container,
            list,
            refresh_button,
            update_button,
        }
    }

    pub fn set_on_refresh<F>(&self, callback: F)
    where
        F: Fn() + 'static,
    {
        let button = self.refresh_button.clone();

        button.connect_clicked(move |_| {
            callback();
        });
    }

    pub fn set_on_update<F>(&self, callback: F)
    where
        F: Fn() + 'static,
    {
        let button = self.update_button.clone();

        button.connect_clicked(move |_| {
            callback();
        });
    }

    pub fn clear(&self) {
        while let Some(child) = self.list.first_child() {
            self.list.remove(&child);
        }
    }

    pub fn add_update(&self, package: &str, old_version: &str, new_version: &str) {
        let row = ListBoxRow::new();

        let container = Box::new(Orientation::Horizontal, 12);
        container.set_margin_top(6);
        container.set_margin_bottom(6);
        container.set_margin_start(8);
        container.set_margin_end(8);

        let name_label = Label::builder()
            .label(package)
            .xalign(0.0)
            .hexpand(false)
            .build();

        let version_label = Label::builder()
            .label(&format!("{old_version} → {new_version}"))
            .xalign(1.0)
            .build();

        let spacer = Box::new(Orientation::Horizontal, 0);
        spacer.set_hexpand(true);

        container.append(&name_label);
        container.append(&spacer);
        container.append(&version_label);

        row.set_child(Some(&container));
        self.list.append(&row);
    }
}
