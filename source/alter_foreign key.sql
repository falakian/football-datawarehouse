
ALTER TABLE appearances
    ADD CONSTRAINT fk_player_id
    FOREIGN KEY (player_id)
    REFERENCES players (player_id);

ALTER TABLE appearances
    ADD CONSTRAINT fk_game_id
    FOREIGN KEY (game_id)
    REFERENCES games (game_id);

ALTER TABLE clubs
    ADD CONSTRAINT fk_domestic_competition_id
    FOREIGN KEY (domestic_competition_id)
    REFERENCES competitions (competition_id);

ALTER TABLE game_events
    ADD CONSTRAINT fk_player_ev_id
    FOREIGN KEY (player_id)
    REFERENCES players (player_id);

ALTER TABLE game_events
    ADD CONSTRAINT fk_player_in_id
    FOREIGN KEY (player_in_id)
    REFERENCES players (player_id);

ALTER TABLE game_events
    ADD CONSTRAINT fk_game_id_1
    FOREIGN KEY (game_id)
    REFERENCES games (game_id);

ALTER TABLE game_events
    ADD CONSTRAINT fk_player_assist_id
    FOREIGN KEY (player_assist_id)
    REFERENCES players (player_id);

ALTER TABLE games
    ADD CONSTRAINT fk_away_club_id
    FOREIGN KEY (away_club_id)
    REFERENCES clubs (club_id);

ALTER TABLE games
    ADD CONSTRAINT fk_competition_id
    FOREIGN KEY (competition_id)
    REFERENCES competitions (competition_id);

ALTER TABLE games
    ADD CONSTRAINT fk_home_club_id
    FOREIGN KEY (home_club_id)
    REFERENCES clubs (club_id);

ALTER TABLE players
    ADD CONSTRAINT fk_current_club_id
    FOREIGN KEY (current_club_id)
    REFERENCES clubs (club_id);
