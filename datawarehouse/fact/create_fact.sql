--use datawarehouse;
--create schema fact;

create table fact.FactPlayersTransactional(
	[player_key] integer NOT NULL,
	[time_key] integer NOT NULL,
	[competition_key] character varying(10) NOT NULL,
	[club_key] integer NOT NULL,
	[game_key] integer NOT NULL,
	[type] integer NOT NULL,
	[minute] integer NOT NULL
);
go

create table fact.FactCompetitionTransactional(
	[competition_key] character varying(10) NOT NULL,
	[game_key] integer NOT NULL,
	[time_key] integer NOT NULL,
	[TotalNumberEvents] integer NOT NULL,
	[NumberSubstitutions] integer NOT NULL
);
go

--drop table fact.FactPlayersDaily;
--truncate fact.FactPlayersDaily;
create table fact.FactPlayersDaily(
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

--drop table fact.FactCompetitionsDaily;
--truncate fact.FactCompetitionsDaily;
create table fact.FactCompetitionsDaily(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);
go

--drop table fact.FactCompetitionsAcc;
--truncate fact.FactCompetitionsAcc;
create table fact.FactCompetitionsAcc(
	[competition_key] character varying(10) NOT NULL,
	[time_key] int NOT NULL,
	[goalCount] int NOT NULL,
	[redCardCount] int NOT NULL,
	[yellowCardCount] int NOT NULL,
	[attendance] int NOT NULL,
	[playCount] int NOT NULL
);
go

--drop table fact.FactPlayersAcc;
--truncate fact.FactPlayersAcc;
create table fact.FactPlayersAcc(
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

--drop table fact.FactClubsDaily;
--truncate fact.FactClubsDaily;
create table fact.FactClubsDaily(
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

--drop table fact.FactClubsAcc;
--truncate fact.FactClubsAcc;
create table fact.FactClubsAcc(
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

--drop table fact.FactClubTransactional;
--truncate fact.FactClubTransactional;
create table fact.FactClubTransactional(
	[competition_key] character varying(10) NOT NULL, 
	[club_key] int NOT NULL,
    [game_key] int NOT NULL, 
    [time_key] int NOT NULL,
    [type] bit NOT NULL, 
    [goals_scored] int NOT NULL,
	[goals_conceded] int NOT NULL,
);