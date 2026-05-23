#[derive(Clone, Debug, Default)]
pub struct PlayerState {
    pub title: String,
    pub artist: String,

    pub playing: bool,

    pub artwork_path: Option<String>,
}
