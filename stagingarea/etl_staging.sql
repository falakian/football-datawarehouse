CREATE OR ALTER PROCEDURE etl_for_players
AS
BEGIN
  truncate table players

  insert into players
  select  p.[player_id], p.[current_club_id], p.[player_code], p.[country_of_birth],
          p.[city_of_birth], p.[country_of_citizenship], p.[date_of_birth], p.[sub_position],
          p.[position], p.[foot], p.[height_in_cm], p.[contract_expiration_date]
	   from source.dbo.players as p where 
	   ((p.[contract_expiration_date] is not null and p.[current_club_id] is not null )
	   or  (p.[contract_expiration_date] is null and p.[current_club_id] is null)) and
	   (exists (select * from clubs as c where p.current_club_id = c.club_id) or current_club_id is null);
END;
go

CREATE OR ALTER PROCEDURE etl_for_clubs
AS
BEGIN
  truncate table clubs

  insert into clubs
  select w.[club_id], w.[name], w.[domestic_competition_id], w.[squad_size],
        w.[foreigners_number], w.[national_team_players], 
        w.[stadium_name], w.[stadium_seats], w.[net_transfer_record]
  from(select c.[club_id], c.[name], c.[domestic_competition_id], c.[squad_size],
        c.[foreigners_number], c.[national_team_players], 
        c.[stadium_name], c.[stadium_seats], c.[net_transfer_record],
		row_number() over(partition by c.[club_id],c.[domestic_competition_id] order by c.[name]) as rankk
		from source.dbo.clubs as c) as w
  where w.[foreigners_number] < w.[squad_size] and
  w.[national_team_players] < w.[squad_size] and
  w.[foreigners_number] + w.[national_team_players] < w.[squad_size] and
  rankk = 1
  
END;
go

CREATE OR ALTER PROCEDURE etl_for_competitions
AS
BEGIN
  truncate table competitions

  insert into competitions
  select w.[competition_id], w.[name], w.[type], w.[country_name]
  from source.dbo.competitions as w

END;
go

CREATE OR ALTER PROCEDURE etl_for_appearances
AS
BEGIN
  truncate table appearances

  insert into appearances
  select w.[appearance_id], w.[game_id], w.[player_id], w.[yellow_cards],
        w.[red_cards], w.[goals], w.[assists], w.[minutes_played]
  from source.dbo.appearances as w
  where exists(select * from players as p where w.player_id = p.player_id) and
  exists(select * from games as p where w.game_id = p.game_id) and
  isnull(w.goals,0) >= 0 and
  isnull(w.assists,0) >=0 and
  isnull(w.minutes_played,0) >=0 and
  isnull(w.yellow_cards,0) >=0 and
  isnull(w.red_cards,0) >=0;
  
END;
go

CREATE OR ALTER PROCEDURE etl_for_games
AS
BEGIN
  truncate table games

  insert into games
  select w.[game_id], w.[competition_id], w.[season],
        w.[date], w.[home_club_id], w.[away_club_id], w.[home_club_goals],
        w.[away_club_goals], w.[stadium], w.[attendance]
  from source.dbo.games as w
  where exists(select * from competitions as p where w.competition_id = p.competition_id) and
  exists(select * from clubs as c where w.home_club_id = c.club_id) and
  exists(select * from clubs as c where w.away_club_id = c.club_id) and
  isnull(w.attendance , 0) >= 0;
  
END;
go

CREATE OR ALTER PROCEDURE etl_for_game_events
AS
BEGIN
  truncate table game_events

  insert into game_events
  select w.[game_event_id], w.[game_id], w.[minute],
        w.[type], w.[player_id], w.[player_in_id], w.[player_assist_id]
  from source.dbo.game_events as w
  where exists(select * from games as p where w.game_id = p.game_id) and
  (exists(select * from players as p where w.player_id = p.player_id) or w.player_id is null)
  and (exists(select * from players as p where w.player_in_id = p.player_id) or w.player_in_id is null)
  and (exists(select * from players as p where w.player_assist_id = p.player_id) or w.player_assist_id is null)
  and w.[minute] >=0
  
END;
go


CREATE OR ALTER PROCEDURE etl_source_to_stagingArea
AS
BEGIN
	exec etl_for_competitions
	exec etl_for_clubs
	exec etl_for_players
	exec etl_for_games
	exec etl_for_appearances
	exec etl_for_game_events
END;

-- exec etl_source_to_stagingArea;





