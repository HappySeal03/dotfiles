use gtk::prelude::*;

pub fn yay_page() -> gtk::Box {
    build_page("Yay Updates")
}

fn build_page(title: &str) -> gtk::Box {
    let page = gtk::Box::new(gtk::Orientation::Vertical, 12);

    page.set_margin_top(20);
    page.set_margin_bottom(20);
    page.set_margin_start(20);
    page.set_margin_end(20);

    let label = gtk::Label::builder()
        .label(title)
        .halign(gtk::Align::Start)
        .css_classes(vec!["title-1"])
        .build();

    page.append(&label);
    page
}
