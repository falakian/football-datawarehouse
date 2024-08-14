CREATE OR ALTER PROCEDURE dimGames_update AS 
BEGIN
    
    DECLARE @dimCount INT;
    DECLARE @tempCount INT;
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Get the count of records in dim.dimGames
    SET @dimCount = (SELECT COUNT(*) FROM dim.dimGames);
    
    -- Get the count of records in tmp.dimGames_final
    SET @tempCount = (SELECT COUNT(*) FROM tmp.dimGames_final);
    
    -- If dim.dimGames is empty and tmp.dimGames_final has records, exit the procedure
    IF (@dimCount = 0 AND @tempCount > 0)
        RETURN 0;
    
    -- Truncate the tmp.dimGames_source table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimGames_source);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimGames_source;
    INSERT INTO logg.logg VALUES('Truncate', 'dimGames_source',@number,@startdate, GETDATE(), 'truncate table by dimGames_update');

    -- Truncate the tmp.dimGames_final table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimGames_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimGames_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimGames_final',@number,@startdate, GETDATE(), 'truncate table by dimGames_update');
    
    -- Insert data into tmp.dimGames_source from the football.dbo.games and football.dbo.competitions tables
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimGames_source
    SELECT 
        g.[game_id], g.[competition_id], c.[name] AS [competition_name],
        c.[type] AS [competition_type], c.[country_name] AS [competition_country_name],
        g.[season], g.[date], g.[home_club_id], g.[away_club_id], g.[home_club_goals],
        g.[away_club_goals], g.[stadium], g.[attendance]
    FROM football.dbo.games AS g
    INNER JOIN football.dbo.competitions AS c ON g.competition_id = c.competition_id;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimGames_source',@number,@startdate, GETDATE(), 'insert to tmp_source from source games');
    
    -- Insert data into tmp.dimGames_final from tmp.dimGames_source and dim.dimGames
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimGames_final
    SELECT
        ISNULL(dg.[game_id], g.[game_id]), 
        ISNULL(g.[competition_id], dg.[competition_id]),
        ISNULL(g.[competition_name], dg.[competition_name]),
        ISNULL(g.[competition_type], dg.[competition_type]), 
        ISNULL(g.[competition_country_name], dg.[competition_country_name]), 
        ISNULL(g.[season], dg.[season]),
        ISNULL(g.[date], dg.[date]),
        ISNULL(g.[home_club_id], dg.[home_club_id]),
        ISNULL(g.[away_club_id], dg.[away_club_id]), 
        ISNULL(g.[home_club_goals], dg.[home_club_goals]),
        ISNULL(g.[away_club_goals], dg.[away_club_goals]), 
        ISNULL(g.[stadium], dg.[stadium]),
        ISNULL(g.[attendance], dg.[attendance])
    FROM tmp.dimGames_source AS g
    FULL OUTER JOIN dim.dimGames AS dg ON dg.[game_id] = g.[game_id];
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimGames_final',@number,@startdate, GETDATE(), 'insert to tmp_final from tmp_source');

    -- Truncate the dim.dimGames table and log the operation
	SET @number = (SELECT COUNT(*) FROM dim.dimGames);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimGames;
    INSERT INTO logg.logg VALUES('Truncate', 'dimGames',@number,@startdate, GETDATE(), 'truncate table by dimGames_update');
        
    -- Insert data into dim.dimGames from tmp.dimGames_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimGames
    SELECT
        df.[game_id], df.[competition_id], df.[competition_name],
        df.[competition_type], df.[competition_country_name],
        df.[season], df.[date], df.[home_club_id], df.[away_club_id],
        df.[home_club_goals], df.[away_club_goals], df.[stadium], df.[attendance]
    FROM tmp.dimGames_final AS df;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimGames',@number,@startdate, GETDATE(), 'main dimension is properly filled');
END;
