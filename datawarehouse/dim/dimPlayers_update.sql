CREATE OR ALTER PROCEDURE dimPlayers_update 
AS 
BEGIN
    
    DECLARE @dimCount INT;
    DECLARE @tempCount INT;
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Get the count of records in dim.dimPlayers
    SET @dimCount = (SELECT COUNT(*) FROM dim.dimPlayers);
    
    -- Get the count of records in tmp.dimPlayers_final
    SET @tempCount = (SELECT COUNT(*) FROM tmp.dimPlayers_final);
    
    -- If dim.dimPlayers is empty and tmp.dimPlayers_final has records, exit the procedure
    IF (@dimCount = 0 AND @tempCount > 0)
        RETURN 0;
    
    -- Truncate the tmp.dimPlayers_join table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimPlayers_join);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayers_join;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayers_join',@number,@startdate, GETDATE(), 'truncate table by dimPlayers_update');

    -- Truncate the tmp.dimPlayers_active table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimPlayers_active);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayers_active;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayers_active',@number,@startdate, GETDATE(), 'truncate table by dimPlayers_update');

    -- Truncate the tmp.dimPlayers_final table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimPlayers_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayers_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayers_final',@number,@startdate, GETDATE(), 'truncate table by dimPlayers_update');
    
    -- Enable identity insert for tmp.dimPlayers_final
    SET IDENTITY_INSERT tmp.dimPlayers_final ON;

    -- Insert data into tmp.dimPlayers_join from the football.dbo.players table
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_join
    SELECT 
        p.[player_id], p.[current_club_id], p.[player_code], p.[country_of_birth],
        p.[city_of_birth], p.[country_of_citizenship], p.[date_of_birth], p.[sub_position],
        p.[position], p.[foot], p.[height_in_cm], p.[contract_expiration_date]
    FROM football.dbo.players AS p;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_join',@number,@startdate, GETDATE(), 'insert to tmp_join from source players');
    
    -- Insert active records from dim.dimPlayers to tmp.dimPlayers_active
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_active
    SELECT
        dp.[id], dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date], 
        dp.[start_date], dp.[end_date], dp.[current_flag]
    FROM dim.dimPlayers AS dp
    WHERE dp.[current_flag] = 1;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_active',@number,@startdate, GETDATE(), 'insert active record to table');
    
    -- Insert non-active records from dim.dimPlayers to tmp.dimPlayers_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_final
    (
        [id], [player_id], [current_club_id], [player_code], [country_of_birth],
        [city_of_birth], [country_of_citizenship], [date_of_birth], [sub_position],
        [position], [foot], [height_in_cm], [contract_expiration_date],
        [start_date], [end_date], [current_flag]
    )
    SELECT
        dp.[id], dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date],
        dp.[start_date], dp.[end_date], dp.[current_flag]
    FROM dim.dimPlayers AS dp
    WHERE dp.[current_flag] = 0;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_final',@number,@startdate, GETDATE(), 'insert non-active record to table');
    
    -- Insert records into tmp.dimPlayers_final where the player exists in dim but not in tmp.join
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_final
    (
        [id], [player_id], [current_club_id], [player_code], [country_of_birth],
        [city_of_birth], [country_of_citizenship], [date_of_birth], [sub_position],
        [position], [foot], [height_in_cm], [contract_expiration_date],
        [start_date], [end_date], [current_flag]
    )
    SELECT
        dp.[id], dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date],
        dp.[start_date], dp.[end_date], dp.[current_flag]
    FROM tmp.dimPlayers_join AS tdj
    RIGHT JOIN tmp.dimPlayers_active AS dp ON tdj.[player_id] = dp.[player_id]
    WHERE (tdj.[player_id] IS NULL) OR (dp.[current_club_id] = tdj.[current_club_id]);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_final',@number,@startdate, GETDATE(), 'insert record in main dimension but not in tmp_join to table');
    
    -- Insert records into tmp.dimPlayers_final where the player's club has changed
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_final
    (
        [id], [player_id], [current_club_id], [player_code], [country_of_birth],
        [city_of_birth], [country_of_citizenship], [date_of_birth], [sub_position],
        [position], [foot], [height_in_cm], [contract_expiration_date],
        [start_date], [end_date], [current_flag]
    )
    SELECT
        dp.[id], dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date],
        dp.[start_date], GETDATE(), 0
    FROM tmp.dimPlayers_join AS tdj
    INNER JOIN tmp.dimPlayers_active AS dp ON tdj.[player_id] = dp.[player_id]
    WHERE (dp.[current_club_id] != tdj.[current_club_id]);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_final',@number,@startdate, GETDATE(), 'insert record to table that not active now');
    
    -- Disable identity insert for tmp.dimPlayers_final
    SET IDENTITY_INSERT tmp.dimPlayers_final OFF;
    
    -- Insert new active records into tmp.dimPlayers_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_final
    SELECT
        dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date],
        GETDATE(), NULL, 1
    FROM tmp.dimPlayers_join AS dp
    LEFT JOIN tmp.dimPlayers_active AS tda ON dp.[player_id] = tda.[player_id]
    WHERE (tda.[player_id] IS NULL) OR (dp.[current_club_id] != tda.[current_club_id]);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_final',@number,@startdate, GETDATE(), 'insert new active record to table');
    
    -- Truncate the dim.dimPlayers table and log the operation
	SET @number = (SELECT COUNT(*) FROM dim.dimPlayers);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimPlayers;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayers',@number,@startdate, GETDATE(), 'truncate table by dimPlayers_update');
    
    -- Insert data into dim.dimPlayers from tmp.dimPlayers_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimPlayers
    SELECT
        dp.[id], dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date],
        dp.[start_date], dp.[end_date], dp.[current_flag]
    FROM tmp.dimPlayers_final AS dp;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers',@number,@startdate, GETDATE(), 'main dimension is properly filled');
END;
