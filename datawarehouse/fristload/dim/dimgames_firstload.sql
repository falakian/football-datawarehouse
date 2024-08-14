CREATE OR ALTER PROCEDURE dimGames_First_Load AS 
BEGIN
    
    DECLARE @startdate DATETIME;
	DECLARE @number INT;
    
	-- Truncate the dim.dimGames table and log the operation
	SET @number = (SELECT COUNT(*)
 FROM dim.dimGames);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimGames;
    INSERT INTO logg.logg VALUES('Truncate', 'dimGames',@number,@startdate, GETDATE(), 'truncate table by dimGames_First_Load');


    -- Insert data into tmp.dimGames_source from the football.dbo.games and football.dbo.competitions tables
	SET @startdate = GETDATE();
    INSERT INTO dim.dimGames
    SELECT 
        g.[game_id], g.[competition_id], c.[name] AS [competition_name],
        c.["type"] AS [competition_type], c.[country_name] AS [competition_country_name],
        g.[season], g.[date], g.[home_club_id], g.[away_club_id], g.[home_club_goals],
        g.[away_club_goals], g.[stadium], g.[attendance]
    FROM football.dbo.games AS g
    INNER JOIN football.dbo.competitions AS c ON g.competition_id = c.competition_id;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimGames',@number,@startdate, GETDATE(), 'insert to tmp_source from source games');
END;
