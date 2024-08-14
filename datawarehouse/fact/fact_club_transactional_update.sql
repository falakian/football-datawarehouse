CREATE OR ALTER PROCEDURE fact_club_transactional_update AS
BEGIN
    
    DECLARE @factCount INT;
    DECLARE @tempCount INT;
    DECLARE @currdate DATE;
	DECLARE @startdate DATETIME;
	DECLARE @number INT;
    
    -- Get the count of records in the fact table
    SET @factCount = (SELECT COUNT(*) FROM fact.FactClubTransactional);
    
    -- Get the count of records in the temporary final table
    SET @tempCount = (SELECT COUNT(*) FROM tmp.FactClubTransactional_final);
    
    -- If the fact table is empty and the temporary table has records, exit the procedure
    IF (@factCount = 0 AND @tempCount > 0)
        RETURN 0;
    
    -- Set the current date based on the records in the fact table
    IF (@factCount = 0)
        SET @currdate = CAST('2020-08-01' AS DATE);
    ELSE
        SET @currdate = (SELECT MAX(CONVERT(DATE, CONVERT(CHAR(8), f.[time_key]))) 
                         FROM fact.FactClubTransactional AS f);

    -- Truncate the temporary final table and log the action
	SET @number = (SELECT COUNT(*) FROM tmp.FactClubTransactional_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactClubTransactional_final;
    INSERT INTO logg.logg VALUES('Truncate', 'FactClubTransactional_final',@number,@startdate, GETDATE(), 'truncate table by FactClubTransactional_final');

    -- Loop to process data for each date until the current date
    WHILE @currdate <= CAST(GETDATE() AS DATE)
    BEGIN
        -- Truncate the source temporary table and log the action
		SET @number = (SELECT COUNT(*) FROM tmp.FactClubTransactional_source);
		SET @startdate = GETDATE();
        TRUNCATE TABLE tmp.FactClubTransactional_source;
        INSERT INTO logg.logg VALUES('Truncate', 'FactClubTransactional_source',@number,@startdate, GETDATE(), 'truncate table by FactClubTransactional_source');

		SET @number = (SELECT COUNT(*) FROM tmp.FactClubTransactional_join);
		SET @startdate = GETDATE();
		TRUNCATE TABLE tmp.FactClubTransactional_join;
        INSERT INTO logg.logg VALUES('Truncate', 'tmpFactClubTransactional_join',@number,@startdate, GETDATE(), 'truncate table by FactClubTransactional_join');

        -- Insert data into the source temporary table -- hometeam
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactClubTransactional_source
            SELECT 
                g.[competition_id] AS competition_key,
                g.[home_club_id] AS club_id,
				g.[game_id] AS game_key,
                CONVERT(INT, FORMAT(g.[date], 'yyyyMMdd')) AS time_key,
				0 AS [type], -- hometeam
                g.[home_club_goals] AS goals_scored,
				g.[away_club_goals] AS goals_conceded 
            FROM football.dbo.games AS g
            WHERE g.date = @currdate
        SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactClubTransactional_source',@number,@startdate, GETDATE(), 'insert to table from source game -- hometeam');

		 -- Insert data into the source temporary table -- awayteam
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactClubTransactional_source
            SELECT 
                g.[competition_id] AS competition_key,
                g.[away_club_id] AS club_id,
				g.[game_id] AS game_key,
                CONVERT(INT, FORMAT(g.[date], 'yyyyMMdd')) AS time_key,
				1 AS [type], -- awayteam
                g.[away_club_goals] AS goals_scored,
				g.[home_club_goals] AS goals_conceded 
            FROM football.dbo.games AS g
            WHERE g.date = @currdate
        SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactClubTransactional_source',@number,@startdate, GETDATE(), 'insert to table from source game -- awayteam');

		-- Insert data into the join temporary table
		SET @startdate = GETDATE();
		INSERT INTO tmp.FactClubTransactional_join
            SELECT 
                t.[competition_key] AS competition_key,
                c.[sec_id] AS club_key,
				t.[game_key] AS game_key,
                t.[time_key] AS time_key,
				t.[type] AS [type],
                t.[goals_scored],
				t.[goals_conceded] 
            FROM tmp.FactClubTransactional_source AS t
			INNER JOIN dim.dimClubs AS c ON c.[club_id] = t.[club_id]
            WHERE c.[flag] = 1;
		SET @number = @@ROWCOUNT;
		INSERT INTO logg.logg VALUES('Insert', 'tmpFactClubTransactional_join',@number,@startdate, GETDATE(), 'insert to table from tmpFactClubTransactional_source');

        -- Insert data into the final temporary table
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactClubTransactional_final
            SELECT 
                [competition_key], 
				[club_key],
                [game_key], 
                [time_key],
                [type], 
                [goals_scored],
				[goals_conceded]
            FROM tmp.FactClubTransactional_join;
        SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactClubTransactional_final',@number,@startdate, GETDATE(), 'insert to table from tmpFactClubTransactional_join');

        -- Increment the current date by one day
        SET @currdate = DATEADD(DAY, 1, @currdate);
    END;
        
    -- Insert data into the fact table from the final temporary table
	SET @startdate = GETDATE();
    INSERT INTO fact.FactClubTransactional
        SELECT 
            [competition_key], 
			[club_key],
            [game_key], 
            [time_key],
            [type], 
            [goals_scored],
			[goals_conceded]
        FROM tmp.FactClubTransactional_final;
    SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'FactClubTransactional',@number,@startdate, GETDATE(), 'insert to table from tmpFactClubTransactional_final');
END;
