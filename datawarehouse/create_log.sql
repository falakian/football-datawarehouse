use datawarehouse;

--create schema logg;
--go
-- drop table logg.logg;
--truncate table logg.logg;

create table logg.logg(
	[Action] varchar(20) NOT NULL,
	[TargetTable] varchar(50) NOT NULL,
	[NumberRows] integer NOT NULL,
	[StartDate] datetime NOT NULL,
	[EndDate] datetime NOT NULL,
	[Description] varchar(100) NULL
);

create table logg.acclogg(
	[TargetTable] varchar(50) NOT NULL,
	[Date] date NOT NULL,
);
