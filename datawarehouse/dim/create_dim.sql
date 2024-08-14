
--create database datawarehouse;
--drop database datawarehouse;
--use datawarehouse;
--create schema dim;

--drop table dim.dimPlayers;
--truncate table dim.dimPlayers;

create table dim.dimPlayers(
	[id] integer not null ,
	[player_id] integer NOT NULL,
	[current_club_id] integer NOT NULL,
	[player_code] character varying(70) NOT NULL,
	[country_of_birth] character varying(40) NULL,
	[city_of_birth] character varying(70) NULL,
	[country_of_citizenship] character varying(40) NULL,
	[date_of_birth] date NULL,
	[sub_position] character varying(40) NULL,
	[position] character varying(20) NULL,
	[foot] character varying(10) NULL,
	[height_in_cm] integer NULL,
	[contract_expiration_date] date NULL,
	[start_date] date NOT NULL,
	[end_date] date NULL,
	[current_flag] bit NULL,
	PRIMARY KEY(id)
);
go

--drop table dim.dimDate;
--truncate table dim.dimDate;

CREATE TABLE dim.dimDate
	(	[DateKey] INT primary key, 
		[Date] DATETIME,
		[FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
		[FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		[DayOfWeekUSA] CHAR(1),-- First Day Sunday=1 and Saturday=7
		[DayOfWeekUK] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHolidayUSA] BIT,-- Flag 1=National Holiday, 0-No National Holiday
		[IsWeekday] BIT,-- 0=Week End ,1=Week Day
		[HolidayUSA] VARCHAR(50),--Name of Holiday in US
		[IsHolidayUK] BIT Null,-- Flag 1=National Holiday, 0-No National Holiday
		[HolidayUK] VARCHAR(50) Null --Name of Holiday in UK
	);
GO

--drop table dim.dimPlayersRelationship;
--truncate table dim.dimPlayersRelationship;

CREATE TABLE dim.dimPlayersRelationship(
	[Type] INT primary key,
	[TypeDescription] VARCHAR(20) NOT NULL
);
GO
--drop table dim.dimGames;
--truncate table dim.dimGames;

CREATE TABLE dim.dimGames(
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
GO
--drop table dim.dimCompetitions;
--truncate table dim.dimCompetitions;

CREATE TABLE dim.dimCompetitions(
	[competition_id] character varying(10) NOT NULL,
	[competition_name_orginal] character varying(70) NULL,
	[competition_name_current] character varying(70) NOT NULL,
	[effective_date] date NULL,
	["type"] character varying(40) NOT NULL,
	[country_name] character varying(20) NULL,
	PRIMARY KEY(competition_id)
);
GO
--drop table dim.dimClubs;
--truncate table dim.dimClubs;

CREATE TABLE dim.dimClubs(
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