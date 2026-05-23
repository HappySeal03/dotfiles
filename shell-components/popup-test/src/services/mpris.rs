use crate::models::player_state::PlayerState;
use mpris::{Player, PlayerFinder};

pub struct MprisService {
    player: Option<Player>,
}

impl MprisService {
    pub fn new() -> Self {
        let finder = PlayerFinder::new().ok();

        let player = finder.and_then(|f| f.find_active().ok());

        Self { player }
    }

    pub fn current_state(&self) -> PlayerState {
        let Some(player) = &self.player else {
            return PlayerState::default();
        };

        let metadata = player.get_metadata().ok();
        let playback = player.get_playback_status().ok();

        let title = metadata
            .as_ref()
            .and_then(|m| m.title())
            .unwrap_or("Unknown")
            .to_string();

        let artist = metadata
            .as_ref()
            .and_then(|m| m.artists())
            .and_then(|artists| artists.first().copied())
            .unwrap_or("Unknown")
            .to_string();

        let artwork_path = metadata
            .as_ref()
            .and_then(|m| m.art_url())
            .map(|u| u.to_string());

        let playing = matches!(playback, Some(mpris::PlaybackStatus::Playing));

        PlayerState {
            title,
            artist,
            playing,
            artwork_path,
        }
    }

    pub fn play_pause(&self) {
        if let Some(player) = &self.player {
            let _ = player.play_pause();
        }
    }

    pub fn next(&self) {
        if let Some(player) = &self.player {
            let _ = player.next();
        }
    }

    pub fn previous(&self) {
        if let Some(player) = &self.player {
            let _ = player.previous();
        }
    }
}
