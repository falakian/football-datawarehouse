use datawarehouse;
--CREATE SCHEMA tmp;
--GO

--drop table tmp.dimClubs_join;
--truncate table tmp.dimClubs_join;
create table tmp.dimClubs_join(
	[club_id] integer NOT NULL,
	[name] character varying(70) NOT NULL,
	[domestic_competition_id] character varying(10) NOT NULL,
	[squad_size] integer NOT NULL,
	[foreigners_number] integer NOT NULL,
	[national_team_players] integer NOT NULL,
	[stadium_name] character varying(70) NOT NULL,
	[stadium_seats] integer NOT NULL,
	[net_transfer_record] character varying(20) NOT NULL,
);
GO
--drop table tmp.dimClubs_active;
--truncate table tmp.dimClubs_active;
create table tmp.dimClubs_active(
	[sec_id] integer primary key,
	[club_id] integer NOT NULL,
	[name] character varying(70) NOT NULL,
	[domestic_competition_id] character varying(10) NOT NULL,
	[squad_size] integer NOT NULL,
	[foreigners_number] integer NOT NULL,
	[national_team_players] integer NOT NULL,
	[stadium_name] character varying(70) NOT NULL,
	[stadium_seats] integer NOT NULL,
	[net_transfer_record] character varying(20) NOT NULL,
	[start_date] date NOT NULL,
	[end_date] date NULL,
	[flag] bit NULL,
);
GO

--drop table tmp.dimClubs_active;
--truncate table tmp.dimClubs_active;
create table tmp.dimClubs_final(
	[sec_id] integer identity(1,1) primary key,
	[club_id] integer NOT NULL,
	[name] character varying(70) NOT NULL,
	[domestic_competition_id] character varying(10) NOT NULL,
	[squad_size] integer NOT NULL,
	[foreigners_number] integer NOT NULL,
	[national_team_players] integer NOT NULL,
	[stadium_name] character varying(70) NOT NULL,
	[stadium_seats] integer NOT NULL,
	[net_transfer_record] character varying(20) NOT NULL,
	[start_date] date NOT NULL,
	[end_date] date NULL,
	[flag] bit NULL,
);
GO

--drop table tmp.dimGames_source;
--truncate tmp.dimGames_source;
create table tmp.dimGames_source(
	[game_id] integer NOT NULL,
	[competition_id] character varying(10) NOT NULL,
	[competition_name] character varying(70) NOT NULL,
	[competition_type] character varying(40) NOT NULL,
	[competition_country_name] character varying(20),
	[season] integer NOT NULL,
	[date] date NOT NULL,
	[home_club_id] integer NOT NULL,
	[away_club_id] integer NOT NULL,
	[home_club_goals] integer NOT NULL,
	[away_club_goals] integer NOT NULL,
	[stadium] character varying(70) NOT NULL,
	[attendance] integer NULL,
	PRIMARY KEY(game_id)
);
go

--drop table tmp.dimGames_final;
--truncate tmp.dimGames_final;
create table tmp.dimGames_final(
	[game_id] integer NOT NULL,
	[competition_id] character varying(10) NOT NULL,
	[competition_name] character varying(70) NOT NULL,
	[competition_type] character varying(40) NOT NULL,
	[competition_country_name] character varying(20),
	[season] integer NOT NULL,
	[date] date NOT NULL,
	[home_club_id] integer NOT NULL,
	[away_club_id] integer NOT NULL,
	[home_club_goals] integer NOT NULL,
	[away_club_goals] integer NOT NULL,
	[stadium] character varying(70) NOT NULL,
	[attendance] integer NULL,
	PRIMARY KEY(game_id)
);
go

--drop table tmp.dimPlayers_active;
--truncate tmp.dimPlayers_active;
CREATE TABLE tmp.dimPlayers_active(
	[id] int NOT NULL,
	[player_id] int NOT NULL,
	[current_club_id] int NOT NULL,
	[player_code] varchar(70) NOT NULL,
	[country_of_birth] varchar(40) NULL,
	[city_of_birth] varchar(70) NULL,
	[country_of_citizenship] varchar(40) NULL,
	[date_of_birth] date NULL,
	[sub_position] varchar(40) NULL,
	[position] varchar(20) NULL,
	[foot] varchar(10) NULL,
	[height_in_cm] int NULL,
	[contract_expiration_date] date NULL,
	[start_date] date NOT NULL,
	[end_date] date NULL,
	[current_flag] bit NULL,
	PRIMARY KEY(id)
);
go

--drop table tmp.dimPlayers_final;
--truncate tmp.dimPlayers_final;
CREATE TABLE tmp.dimPlayers_final(
	[id] int identity(1,1) NOT NULL,
	[player_id] int NOT NULL,
	[current_club_id] int NOT NULL,
	[player_code] varchar(70) NOT NULL,
	[country_of_birth] varchar(40) NULL,
	[city_of_birth] varchar(70) NULL,
	[country_of_citizenship] varchar(40) NULL,
	[date_of_birth] date NULL,
	[sub_position] varchar(40) NULL,
	[position] varchar(20) NULL,
	[foot] varchar(10) NULL,
	[height_in_cm] int NULL,
	[contract_expiration_date] date NULL,
	[start_date] date NOT NULL,
	[end_date] date NULL,
	[current_flag] bit NULL,
	PRIMARY KEY(id)
);
go


--drop table tmp.dimPlayers_active;
--truncate tmp.dimPlayers_active;
CREATE TABLE tmp.dimPlayers_join(
	[player_id] int NOT NULL,
	[current_club_id] int NOT NULL,
	[player_code] varchar(70) NOT NULL,
	[country_of_birth] varchar(40) NULL,
	[city_of_birth] varchar(70) NULL,
	[country_of_citizenship] varchar(40) NULL,
	[date_of_birth] date NULL,
	[sub_position] varchar(40) NULL,
	[position] varchar(20) NULL,
	[foot] varchar(10) NULL,
	[height_in_cm] int NULL,
	[contract_expiration_date] date NULL,
	PRIMARY KEY(player_id)
);
go

--drop table tmp.dimPlayersRelationship_final;
--truncate tmp.dimPlayersRelationship_final;
CREATE TABLE tmp.dimPlayersRelationship_final(
	[Type] INT identity(1,1) primary key,
	[TypeDescription] VARCHAR(20) NOT NULL
);
GO

--drop table tmp.dimPlayersRelationship_join;
--truncate tmp.dimPlayersRelationship_join;
CREATE TABLE tmp.dimPlayersRelationship_join(
	[TypeDescription] VARCHAR(20) NOT NULL
);
GO

--drop table tmp.dimCompetitions_source;
--truncate tmp.dimCompetitions_source;
CREATE TABLE tmp.dimCompetitions_source(
	[competition_id] character varying(10) NOT NULL,
	[name] character varying(70) NOT NULL,
	["type"] character varying(40) NOT NULL,
	[country_name] character varying(20) NULL,
	PRIMARY KEY(competition_id)
);
GO

--drop table tmp.dimCompetitions_final;
--truncate tmp.dimCompetitions_final;
CREATE TABLE tmp.dimCompetitions_final(
	[competition_id] character varying(10) NOT NULL,
	[competition_name_orginal] character varying(70) NULL,
	[competition_name_current] character varying(70) NOT NULL,
	[effective_date] date NULL,
	["type"] character varying(40) NOT NULL,
	[country_name] character varying(20) NULL,
	PRIMARY KEY(competition_id)
);
GO

--drop table tmp.FactPlayersTransactional_final;
--truncate tmp.FactPlayersTransactional_final;
create table tmp.FactPlayersTransactional_final(
	[player_key] integer NOT NULL,
	[time_key] integer NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] integer NOT NULL,
	[game_key] integer NOT NULL,
	[type] integer NOT NULL,
	[minute] integer NOT NULL
);
go

--drop table tmp.FactPlayersTransactional_join;
--truncate tmp.FactPlayersTransactional_join;
create table tmp.FactPlayersTransactional_join(
	[player_key] integer NOT NULL,
	[time_key] integer NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] integer NOT NULL,
	[game_key] integer NOT NULL,
	[type] integer NOT NULL,
	[minute] integer NOT NULL
);
go

--drop table tmp.FactPlayersTransactional_source;
--truncate tmp.FactPlayersTransactional_source;
create table tmp.FactPlayersTransactional_source(
	[player_id] integer NOT NULL,
	[type] integer NOT NULL,
	[minute] integer NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_ID] integer NOT NULL,
	[game_key] integer NOT NULL,
	[time_key] date NOT NULL
);
go

--drop table tmp.FactCompetitionTransactional_final;
--truncate tmp.FactCompetitionTransactional_final;
create table tmp.FactCompetitionTransactional_final(
	[competition_key] character varying(10) NOT NULL,
	[game_key] integer NOT NULL,
	[time_key] integer NOT NULL,
	[TotalNumberEvents] integer NOT NULL,
	[NumberSubstitutions] integer NOT NULL
);
go

--drop table tmp.FactCompetitionTransactional_source;
--truncate tmp.FactCompetitionTransactional_source;
create table tmp.FactCompetitionTransactional_source(
	[competition_key] character varying(10) NOT NULL,
	[game_key] integer NOT NULL,
	[time_key] integer NOT NULL,
	[TotalNumberEvents] integer NOT NULL,
	[NumberSubstitutions] integer NOT NULL
);
go

--drop table tmp.FactRelationshipClubsPlayers_final;
--truncate tmp.FactRelationshipClubsPlayers_final;
CREATE TABLE tmp.FactRelationshipClubsPlayers_final(
	[Type] INT identity(1,1) primary key,
	[TypeDescription] VARCHAR(20) NOT NULL
);
GO

--drop table tmp.FactPlayersDaily_tmp;
--truncate tmp.FactPlayersDaily_tmp;
create table tmp.FactPlayersDaily_tmp(
	[player_key] int NOT NULL,
	[time_key] int NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[assistCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[playMinute] int NOT NULL
);

--drop table tmp.FactPlayersDaily;
--truncate tmp.FactPlayersDaily;
create table tmp.FactPlayersDaily(
	[player_key] int NOT NULL,
	[time_key] int NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[assistCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[playMinute] int NOT NULL
);

--drop table tmp.FactPlayersDaily_source;
--truncate tmp.FactPlayersDaily_source;
create table tmp.FactPlayersDaily_source(
	[player_id] int NOT NULL,
	[date] date NOT NULL,
	[competition_id] character varying(10) NOT NULL,
	[club_id] int NOT NULL,
	[goals] int NULL,
	[assists] int NULL,
	[red_cards] int NULL,
	[yellow_cards] int NULL,
	[minutes_played] int NULL
);

--drop table tmp.FactPlayersDaily_join;
--truncate tmp.FactPlayersDaily_join;
create table tmp.FactPlayersDaily_join(
	[player_key] int NOT NULL,
	[time_key] date NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NULL,
	[assistCount] int NULL,
	[redCardCount] int NULL,
	[yellowCardCount] int NULL,
	[playMinute] int NULL
);

--drop table tmp.FactPlayersDaily_final;
--truncate tmp.FactPlayersDaily_final;
create table tmp.FactPlayersDaily_final(
	[player_key] int NOT NULL,
	[time_key] int NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[assistCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[playMinute] int NOT NULL
);

--drop table tmp.FactCompetitionsDaily;
--truncate tmp.FactCompetitionsDaily;
create table tmp.FactCompetitionsDaily(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactCompetitionsDaily_tmp;
--truncate tmp.FactCompetitionsDaily_tmp;
create table tmp.FactCompetitionsDaily_tmp(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactCompetitionsDaily_source;
--truncate tmp.FactCompetitionsDaily_source;
create table tmp.FactCompetitionsDaily_source(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactCompetitionsDaily_final;
--truncate tmp.FactCompetitionsDaily_final;
create table tmp.FactCompetitionsDaily_final(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactCompetitionsAcc_tmp;
--truncate tmp.FactCompetitionsAcc_tmp;
create table tmp.FactCompetitionsAcc_tmp(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactCompetitionsAcc_source;
--truncate tmp.FactCompetitionsAcc_source;
create table tmp.FactCompetitionsAcc_source(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactCompetitionsAcc_final;
--truncate tmp.FactCompetitionsAcc_final;
create table tmp.FactCompetitionsAcc_final(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);

--drop table tmp.FactPlayersAcc_tmp;
--truncate tmp.FactPlayersAcc_tmp;
create table tmp.FactPlayersAcc_tmp(
	[player_key] int NOT NULL,
	[time_key] int NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[assistCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[playMinute] int NOT NULL
);
go

--drop table tmp.FactPlayersAcc_source;
--truncate tmp.FactPlayersAcc_source;
create table tmp.FactPlayersAcc_source(
	[player_id] int NOT NULL,
	[date] date NOT NULL,
	[competition_id] character varying(10) NOT NULL,
	[club_id] int NOT NULL,
	[goals] int NULL,
	[assists] int NULL,
	[red_cards] int NULL,
	[yellow_cards] int NULL,
	[minutes_played] int NULL
);
go

--drop table tmp.FactPlayersAcc_join;
--truncate tmp.FactPlayersAcc_join;
create table tmp.FactPlayersAcc_join(
	[player_key] int NOT NULL,
	[time_key] date NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NULL,
	[assistCount] int NULL,
	[redCardCount] int NULL,
	[yellowCardCount] int NULL,
	[playMinute] int NULL
);
go

--drop table tmp.FactPlayersAcc_final;
--truncate tmp.FactPlayersAcc_final;
create table tmp.FactPlayersAcc_final(
	[player_key] int NOT NULL,
	[time_key] int NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[assistCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[playMinute] int NOT NULL
);

--drop table tmp.FactClubsDaily;
--truncate tmp.FactClubsDaily;
create table tmp.FactClubsDaily(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_tmp;
--truncate tmp.FactClubsDaily_tmp;
create table tmp.FactClubsDaily_tmp(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_source_home;
--truncate tmp.FactClubsDaily_source_home;
create table tmp.FactClubsDaily_source_home(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_id] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_source_away;
--truncate tmp.FactClubsDaily_source_away;
create table tmp.FactClubsDaily_source_away(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_id] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_source_home_join;
--truncate tmp.FactClubsDaily_source_home_join;
create table tmp.FactClubsDaily_source_home_join(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_source_away_join;
--truncate tmp.FactClubsDaily_source_away_join;
create table tmp.FactClubsDaily_source_away_join(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_final;
--truncate tmp.FactClubsDaily_final;
create table tmp.FactClubsDaily_final(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsDaily_final_tmp;
--truncate tmp.FactClubsDaily_final_tmp;
create table tmp.FactClubsDaily_final_tmp(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc_source_home;
--truncate tmp.FactClubsAcc_source_home;
create table tmp.FactClubsAcc_source_home(
	[competition_key] character varying(10) NOT NULL,
	[club_id] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc_source_away;
--truncate tmp.FactClubsAcc_source_away;
create table tmp.FactClubsAcc_source_away(
	[competition_key] character varying(10) NOT NULL,
	[club_id] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc_source_home_join;
--truncate tmp.FactClubsAcc_source_home_join;
create table tmp.FactClubsAcc_source_home_join(
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc_source_away_join;
--truncate tmp.FactClubsAcc_source_away_join;
create table tmp.FactClubsAcc_source_away_join(
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc_final;
--truncate tmp.FactClubsAcc_final;
create table tmp.FactClubsAcc_final(
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc_final_tmp;
--truncate tmp.FactClubsAcc_final_tmp;
create table tmp.FactClubsAcc_final_tmp(
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubsAcc;
--truncate tmp.FactClubsAcc;
create table tmp.FactClubsAcc(
	[competition_key] character varying(10) NOT NULL,
	[club_key] int NOT NULL,
	[winCount] int NOT NULL,
	[loseCount] int NOT NULL,
	[drawCount] int NOT NULL,
	[totalPlays] int NOT NULL,
	[awayPlays] int NOT NULL,
	[homePlays] int NOT NULL,
	[goalCount] int NOT NULL,
);

--drop table tmp.FactClubTransactional_final;
--truncate tmp.FactClubTransactional_final;
create table tmp.FactClubTransactional_final(
	[competition_key] character varying(10) NOT NULL, 
	[club_key] int NOT NULL,
    [game_key] int NOT NULL, 
    [time_key] int NOT NULL,
    [type] bit NOT NULL, 
    [goals_scored] int NOT NULL,
	[goals_conceded] int NOT NULL,
);

--drop table tmp.FactClubTransactional_source;
--truncate tmp.FactClubTransactional_source;
create table tmp.FactClubTransactional_source(
	[competition_key] character varying(10) NOT NULL, 
	[club_id] int NOT NULL,
    [game_key] int NOT NULL, 
    [time_key] int NOT NULL,
    [type] bit NOT NULL, 
    [goals_scored] int NOT NULL,
	[goals_conceded] int NOT NULL,
);

--drop table tmp.FactClubTransactional_join;
--truncate tmp.FactClubTransactional_join;
create table tmp.FactClubTransactional_join(
	[competition_key] character varying(10) NOT NULL, 
	[club_key] int NOT NULL,
    [game_key] int NOT NULL, 
    [time_key] int NOT NULL,
    [type] bit NOT NULL, 
    [goals_scored] int NOT NULL,
	[goals_conceded] int NOT NULL,
);