CREATE OR ALTER PROCEDURE fact_competition_transactional_First_Load AS
BEGIN
    
    DECLARE @currdate DATE;
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    
    SET @currdate = CAST('2020-08-01' AS DATE);
   

    -- Truncate the temporary final table and log the action
	SET @number = (SELECT COUNT(*) FROM fact.FactCompetitionTransactional);
	SET @startdate = GETDATE();
    TRUNCATE TABLE fact.FactCompetitionTransactional;
    INSERT INTO logg.logg VALUES('Truncate', 'FactCompetitionTransactional',@number,@startdate, GETDATE(), 'truncate table by fact_competition_transactional_First_Load');

    -- Loop to process data for each date until the current date
    WHILE @currdate <= CAST(GETDATE() AS DATE)
    BEGIN
        -- Truncate the source temporary table and log the action
		SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionTransactional_source);
		SET @startdate = GETDATE();
        TRUNCATE TABLE tmp.FactCompetitionTransactional_source;
        INSERT INTO logg.logg VALUES('Truncate', 'FactCompetitionTransactional_source',@number,@startdate, GETDATE(), 'truncate table by fact_competition_transactional_First_Load');

        -- Insert data into the source temporary table
		SET @startdate = GETDATE();
        INSERT INTO tmp.FactCompetitionTransactional_source
            SELECT 
                g.[competition_id] AS competition_key,
                g.[game_id] AS game_key,
                CONVERT(INT, FORMAT(g.[date], 'yyyyMMdd')) AS time_key,
                COUNT(ge.[game_event_id]) AS TotalNumberEvents,
                (SELECT COUNT(fge.[game_event_id]) 
                 FROM football.dbo.game_events AS fge 
                 WHERE fge.[game_id] = g.[game_id] AND fge.["type"] = 'Substitutions') AS NumberSubstitutions
            FROM football.dbo.game_events AS ge
            INNER JOIN football.dbo.games AS g ON g.[game_id] = ge.[game_id]
            WHERE g.date = @currdate
            GROUP BY g.[game_id], g.[competition_id], g.[date];
        SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactCompetitionTransactional_source',@number,@startdate, GETDATE(), 'insert to table from source game_event,game');

        -- Insert data into the final temporary table
		SET @startdate = GETDATE();
        INSERT INTO fact.FactCompetitionTransactional
            SELECT 
                [competition_key], 
				[game_key], 
				[time_key],
				[TotalNumberEvents], 
				[NumberSubstitutions]
            FROM tmp.FactCompetitionTransactional_source;
        SET @number = @@ROWCOUNT;
        INSERT INTO logg.logg VALUES('Insert', 'tmpFactCompetitionTransactional',@number,@startdate, GETDATE(), 'insert to table from tmpFactCompetitionTransactional_source');

        -- Increment the current date by one day
        SET @currdate = DATEADD(DAY, 1, @currdate);
    END;
        
    
END;