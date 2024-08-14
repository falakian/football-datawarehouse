
-- drop database football;

create database football;
use football;

--drop table players
CREATE TABLE players (
	[player_id] integer NOT NULL ,
	[current_club_id] integer NOT NULL,
	[player_code] character varying(64) NOT NULL,
	[country_of_birth] character varying(32) NULL,
	[city_of_birth] character varying(64) NULL,
	[country_of_citizenship] character varying(32) NULL,
	[date_of_birth] date NULL,
	[sub_position] character varying(32) NULL,
	["position"] character varying(16) NULL,
	[foot] character varying(8) NULL,
	[height_in_cm] integer NULL,
	[contract_expiration_date] date NULL,
	PRIMARY KEY(player_id)
);

--drop table appearances
CREATE TABLE appearances (
	[appearance_id] character varying(16) NOT NULL,
	[game_id] integer NOT NULL,
	[player_id] integer NOT NULL,
	[yellow_cards] integer NOT NULL,
	[red_cards] integer NOT NULL,
	[goals] integer NOT NULL,
	[assists] integer NOT NULL,
	[minutes_played] integer NOT NULL,
	PRIMARY KEY(appearance_id)
);

--drop table competitions
CREATE TABLE competitions (
	[competition_id] character varying(4) NOT NULL,
	[name] character varying(64) NOT NULL,
	["type"] character varying(32) NOT NULL,
	[country_name] character varying(16) NULL,
	PRIMARY KEY(competition_id)
);

--drop table clubs
CREATE TABLE clubs (
	[club_id] integer NOT NULL,
	[name] character varying(64) NOT NULL,
	[domestic_competition_id] character varying(4) NOT NULL,
	[squad_size] integer NOT NULL,
	[foreigners_number] integer NOT NULL,
	[national_team_players] integer NOT NULL,
	[stadium_name] character varying(64) NOT NULL,
	[stadium_seats] integer NOT NULL,
	[net_transfer_record] character varying(16) NOT NULL,
	PRIMARY KEY(club_id)
);

--drop table games
CREATE TABLE games (
	[game_id] integer NOT NULL,
	[competition_id] character varying(4) NOT NULL,
	[season] integer NOT NULL,
	[date] date NOT NULL,
	[home_club_id] integer NOT NULL,
	[away_club_id] integer NOT NULL,
	[home_club_goals] integer NOT NULL,
	[away_club_goals] integer NOT NULL,
	[stadium] character varying(64) NOT NULL,
	[attendance] integer NULL,
	PRIMARY KEY(game_id)
);

--drop table game_events
CREATE TABLE game_events (
	[game_event_id] integer NOT NULL,
	[game_id] integer NOT NULL,
	["minute"] integer NOT NULL,
	["type"] character varying(16) NOT NULL,
	[player_id] integer NOT NULL,
	[player_in_id] integer NULL,
	[player_assist_id] integer NULL,
	PRIMARY KEY(game_event_id)
);