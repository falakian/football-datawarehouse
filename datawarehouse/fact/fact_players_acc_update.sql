CREATE OR ALTER PROCEDURE Fact_Players_Acc_update
AS
BEGIN
  
  DECLARE @factCount INT;
  DECLARE @tempCount INT;
  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;

  -- Get the count of records in fact.FactPlayersAcc and tmp.FactPlayersAcc_tmp
  SET @factCount = (SELECT COUNT(*) FROM fact.FactPlayersAcc);
  SET @tempCount = (SELECT COUNT(*) FROM tmp.FactPlayersAcc_tmp);

  -- If fact.FactPlayersAcc is empty and tmp.FactPlayersAcc_tmp is not, return early
  IF (@factCount = 0 AND @tempCount > 0)
    RETURN;

  -- Determine the current date for processing
  IF(@factCount = 0)
    SET @currdate = CAST('2020-08-01' AS DATE);
  ELSE
    SET @currdate = (SELECT MAX(ll.[Date]) from logg.acclogg as ll where ll.targetTable = 'fact.FactPlayersAcc')

  SET @currdate = DATEADD(DAY, 1, @currdate);

  -- Truncate and log truncation of temporary tables
  SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersAcc_tmp);
  SET @startdate = GETDATE();
  TRUNCATE TABLE tmp.FactPlayersAcc_tmp;
  INSERT INTO logg.logg VALUES('truncate','FactPlayersDaily_tmp',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_update');

  -- Insert the latest records into tmp.FactPlayersAcc_tmp from fact.FactPlayersAcc
  SET @startdate = GETDATE();
  INSERT INTO tmp.FactPlayersAcc_tmp
  SELECT [player_key],
		 [competition_key],
		 [club_key],
		 [goalCount],
		 [assistCount],
		 [redCardCount],
		 [yellowCardCount],
		 [playMinute]
	FROM fact.FactPlayersAcc
  SET @number = @@ROWCOUNT;
  INSERT INTO logg.logg VALUES('insert','FactPlayersAcc_tmp',@number,@startdate,GETDATE(), 'insert to table from fact.FactPlayersAcc');

  -- Loop through each day from @currdate to current date
  WHILE @currdate < CAST(getdate() AS DATE)
  BEGIN
    -- Truncate and log truncation of intermediate tables
	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersAcc_source);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersAcc_source;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersAcc_source',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Acc_update');

	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersAcc_join);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersAcc_join;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersAcc_join',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Acc_update');

	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersAcc_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersAcc_final;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersAcc_final',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Acc_update');

    -- Insert daily records into tmp.FactPlayersAcc_source
	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersAcc_source
    SELECT a.[player_id], g.[competition_id],
           CASE WHEN (SELECT COUNT(DP.[current_club_id])
                      FROM DIM.dimPlayers AS DP 
                      WHERE a.[player_id] = DP.[PLAYER_ID] 
                        AND g.[date] > DP.[start_date] 
                        AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL)) = 1 
                THEN (SELECT DP.[current_club_id]
                      FROM DIM.dimPlayers AS DP
                      WHERE a.[player_id] = DP.[PLAYER_ID] 
                        AND g.[date] > DP.[start_date] 
                        AND (g.[date] < DP.[end_date] OR DP.[end_date] IS NULL))
                ELSE -1 
           END AS club_id, 
           SUM(a.goals), SUM(a.assists), SUM(a.red_cards),
		   SUM(a.yellow_cards), SUM(a.minutes_played)
    FROM football.dbo.appearances AS a 
    INNER JOIN football.dbo.games AS g ON a.game_id = g.game_id
    WHERE g.[date] = @currdate
    GROUP BY a.[player_id],
			g.competition_id;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersAcc_source',@number,@startdate,GETDATE(), 'insert to table from source tables');

    -- Insert valid records into tmp.FactPlayersAcc_join
	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersAcc_join
    SELECT d.[id], f.[competition_id], r.[sec_id],
	f.[goals], f.[assists], f.[red_cards], f.[yellow_cards], f.[minutes_played]
    FROM tmp.FactPlayersAcc_source AS f
    INNER JOIN dim.dimPlayers AS d ON f.player_id = d.player_id 
    INNER JOIN dim.dimClubs AS r ON f.club_id = r.club_id
    WHERE d.current_flag = 1 AND r.flag = 1;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersAcc_join',@number,@startdate,GETDATE(), 'insert to with true player_id and club_id');

    -- Insert merged records into tmp.FactPlayersAcc_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersAcc_final
    SELECT ISNULL(fs.player_key, ft.player_key),
           ISNULL(fs.competition_key, ft.competition_key),
		   ISNULL(fs.club_key, ft.club_key),
           ISNULL(fs.goalCount, 0) + ISNULL(ft.goalCount, 0),
           ISNULL(fs.assistCount, 0) + ISNULL(ft.assistCount, 0),
           ISNULL(fs.redCardCount, 0) + ISNULL(ft.redCardCount, 0),
           ISNULL(fs.yellowCardCount, 0) + ISNULL(ft.yellowCardCount, 0),
           ISNULL(fs.playMinute, 0) + ISNULL(ft.playMinute, 0)
    FROM tmp.FactPlayersAcc_join AS fs
    FULL OUTER JOIN tmp.FactPlayersAcc_tmp AS ft ON fs.player_key = ft.player_key;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersAcc_final',@number,@startdate,GETDATE(), 'insert to table from FactPlayersAcc_join and FactPlayersAcc_tmp');

    -- Update tmp.FactPlayersAcc_tmp with final records
	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersAcc_tmp);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersAcc_tmp;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersAcc_tmp',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Acc_update');

	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersAcc_tmp
    SELECT [player_key], [competition_key],
	[club_key], [goalCount], [assistCount], [redCardCount],
	[yellowCardCount], [playMinute]
    FROM tmp.FactPlayersAcc_final;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersAcc_tmp',@number,@startdate,GETDATE(), 'insert to table from FactPlayersAcc_final');

    -- Move to the next date
    SET @currdate = DATEADD(DAY, 1, @currdate);
  END

  -- Truncate and log truncation of the main fact table
  SET @number = (SELECT COUNT(*) FROM fact.FactPlayersAcc);
  SET @startdate = GETDATE();
  TRUNCATE TABLE fact.FactPlayersAcc;
  INSERT INTO logg.logg VALUES('truncate','fact.FactPlayersAcc',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Acc_update');

  -- Insert updated records into the main fact table
  SET @startdate = GETDATE();
  INSERT INTO fact.FactPlayersAcc
  SELECT [player_key], [competition_key],
  [club_key], [goalCount], [assistCount], [redCardCount],
  [yellowCardCount], [playMinute]
  FROM tmp.FactPlayersAcc_tmp;
  SET @number = @@ROWCOUNT;
  INSERT INTO logg.logg VALUES('insert','fact.FactPlayersAcc',@number,@startdate,GETDATE(), 'insert to table from tmp.FactPlayersAcc_tmp');

  insert into logg.acclogg values('fact.FactPlayersAcc' , DATEADD(day, -1, @currdate));

END;
