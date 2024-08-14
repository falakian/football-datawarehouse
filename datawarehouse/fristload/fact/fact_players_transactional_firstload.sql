CREATE OR ALTER PROCEDURE fact_players_transactional_First_Load AS
BEGIN
    
    DECLARE @currdate DATE;
	DECLARE @startdate DATETIME;
	DECLARE @number INT;


    
    SET @currdate = CAST('2020-07-01' AS DATE);
   
    -- Increment the current date by one day
    SET @currdate = DATEADD(DAY, 1, @currdate);

    -- Truncate the temporary final table
	SET @number = (SELECT COUNT(*) FROM fact.FactPlayersTransactional);
	SET @startdate = GETDATE();
    TRUNCATE TABLE fact.FactPlayersTransactional;
    INSERT INTO logg.logg VALUES('Truncate', 'tmpFactPlayersTransactional',@number,@startdate, GETDATE(), 'truncate table by fact_players_transactional_First_Load');

    -- Loop to process data for each date until the current date
    WHILE @currdate < CAST(GETDATE() AS DATE)
    BEGIN
        -- Truncate the source and join temporary tables
		SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersTransactional_source);
		SET @startdate = GETDATE();
        TRUNCATE TABLE tmp.FactPlayersTransactional_source;
        INSERT INTO logg.logg VALUES('Truncate', 'tmpFactPlayersTransactional_source',@number,@startdate, GETDATE(), 'truncate table by fact_players_transactional_First_Load');

		SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersTransactional_join);
		SET @startdate = GETDATE();
        TRUNCATE TABLE tmp.FactPlayersTransactional_join;
        INSERT INTO logg.logg VALUES('Truncate', 'tmpFactPlayersTransactional_join',@number,@startdate, GETDATE(), 'truncate table by fact_players_transactional_First_Load');

        -- Insert data into the source temporary table for types 1 to 4
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactPlayersTransactional_source
            SELECT ge.[player_id] AS player_id, 
                   CASE WHEN ge.[type] = 'Goals' THEN 1
                        WHEN ge.[type] = 'Substitutions' THEN 2
                        WHEN ge.[type] = 'Shootout' THEN 3
                        WHEN ge.[type] = 'Cards' THEN 4
                   END AS type,
                   ge.[minute] AS minute,
                   g.[competition_id] AS competition_key,
                   CASE WHEN (SELECT COUNT(DP.[current_club_id])
                              FROM DIM.dimPlayers AS DP 
                              WHERE ge.[player_id] = DP.[PLAYER_ID] AND
                                    g.[date] > DP.[start_date] AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL)) = 1 
                        THEN (SELECT DP.[current_club_id]
                              FROM DIM.dimPlayers AS DP
                              WHERE ge.[player_id] = DP.[PLAYER_ID] AND
                                    g.[date] > DP.[start_date] AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL))
                        ELSE -1 
                   END AS CLUB_ID,
                   g.[game_id] AS game_key,
                   g.[date] AS time_key
            FROM football.dbo.game_events AS ge
            INNER JOIN football.dbo.games AS g ON g.[game_id] = ge.[game_id]
            WHERE g.date = @currdate;
		SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactPlayersTransactional_source',@number,@startdate, GETDATE(), 'insert to table(type 1,2,3,4) from source game_events,games');

        -- Insert data into the source temporary table for type 5
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactPlayersTransactional_source
            SELECT ge.[player_assist_id] AS player_id,
                   5 AS type,
                   ge.[minute] AS minute,
                   g.[competition_id] AS competition_key,
                   CASE WHEN (SELECT COUNT(DP.[current_club_id])
                              FROM DIM.dimPlayers AS DP 
                              WHERE ge.[player_id] = DP.[PLAYER_ID] AND
                                    g.[date] > DP.[start_date] AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL)) = 1 
                        THEN (SELECT DP.[current_club_id]
                              FROM DIM.dimPlayers AS DP
                              WHERE ge.[player_id] = DP.[PLAYER_ID] AND
                                    g.[date] > DP.[start_date] AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL))
                        ELSE -1 
                   END AS CLUB_ID,
                   g.[game_id] AS game_key,
                   g.date AS time_key
            FROM football.dbo.game_events AS ge
            INNER JOIN football.dbo.games AS g ON g.[game_id] = ge.[game_id]
            WHERE g.date = @currdate AND ge.[type] = 'Goals' AND ge.[player_assist_id] IS NOT NULL;
		SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactPlayersTransactional_source',@number,@startdate, GETDATE(), 'insert to table(type 5) from source game_events,games');

        -- Insert data into the source temporary table for type 6
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactPlayersTransactional_source
            SELECT ge.[player_in_id] AS player_id,
                   6 AS [type],
                   ge.[minute] AS minute,
                   g.[competition_id] AS competition_key,
                   CASE WHEN (SELECT COUNT(DP.[current_club_id])
                              FROM DIM.dimPlayers AS DP 
                              WHERE ge.[player_id] = DP.[PLAYER_ID] AND
                                    g.[date] > DP.[start_date] AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL)) = 1 
                        THEN (SELECT DP.[current_club_id]
                              FROM DIM.dimPlayers AS DP
                              WHERE ge.[player_id] = DP.[PLAYER_ID] AND
                                    g.[date] > DP.[start_date] AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL))
                        ELSE -1 
                   END AS CLUB_ID,
                   g.[game_id] AS game_key,
                   g.[date] AS time_key
            FROM football.dbo.game_events AS ge
            INNER JOIN football.dbo.games AS g ON g.[game_id] = ge.[game_id]
            WHERE g.date = @currdate AND ge.type = 'Substitutions';
		SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactPlayersTransactional_source',@number,@startdate, GETDATE(), 'insert to table(type 6) from source game_events,games');

        -- Insert data into the join temporary table
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactPlayersTransactional_join
            SELECT p.[id] AS player_key,
                   CONVERT(INT, FORMAT(t.[time_key], 'yyyyMMdd')) AS time_key,
                   t.[competition_key] AS competition_key,
                   c.[sec_id] AS club_key,
                   t.[game_key] AS game_key,
                   t.[type] AS type,
                   t.[minute] AS minute
            FROM tmp.FactPlayersTransactional_source AS t
            INNER JOIN dim.dimPlayers AS p ON p.[player_id] = t.[player_id]
            INNER JOIN dim.dimClubs AS c ON c.[club_id] = t.[club_id]
            WHERE p.[current_flag] = 1 AND c.[flag] = 1;
		SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactPlayersTransactional_join',@number,@startdate, GETDATE(), 'insert to table from tmpFactPlayersTransactional_source');

        -- Insert data into the final temporary table
		SET @startdate = GETDATE();
        INSERT INTO fact.FactPlayersTransactional
            SELECT [player_key], [time_key], [competition_key],
                   [club_key], [game_key], [type], [minute]
            FROM tmp.FactPlayersTransactional_join;
		SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactPlayersTransactional',@number,@startdate, GETDATE(), 'insert to table from tmpFactPlayersTransactional_join');

        -- Increment the current date by one day
        SET @currdate = DATEADD(DAY, 1, @currdate);
    END;

END;