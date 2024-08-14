CREATE OR ALTER PROCEDURE Fact_Players_Daily_First_Load
AS
BEGIN
  
  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;

 
  SET @currdate = CAST('2020-07-01' AS DATE);
  

  SET @currdate = DATEADD(DAY, 1, @currdate);

  -- Truncate and log truncation of temporary tables
  SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersDaily_tmp);
  SET @startdate = GETDATE();
  TRUNCATE TABLE tmp.FactPlayersDaily_tmp;
  INSERT INTO logg.logg VALUES('truncate','FactPlayersDaily_tmp',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_First_Load');

  SET @number = (SELECT COUNT(*) FROM fact.FactPlayersDaily);
  SET @startdate = GETDATE();
  TRUNCATE TABLE fact.FactPlayersDaily;
  INSERT INTO logg.logg VALUES('truncate','fact.FactPlayersDaily',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_First_Load');


  -- Loop through each day from @currdate to current date
  WHILE @currdate < CAST(GETDATE() AS DATE)
  BEGIN
    -- Truncate and log truncation of intermediate tables
	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersDaily_source);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersDaily_source;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersDaily_source',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersDaily_join);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersDaily_join;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersDaily_join',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersDaily);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersDaily;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersDaily',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_First_Load');

    -- Insert daily records into tmp.FactPlayersDaily_source
	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersDaily_source
    SELECT a.[player_id], g.[date], g.[competition_id],
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
    GROUP BY a.[player_id], g.[date], g.competition_id;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersDaily_source',@number,@startdate,GETDATE(), 'insert to table from source tables');

    -- Insert valid records into tmp.FactPlayersDaily_join
	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersDaily_join
    SELECT d.[id], f.[date], f.[competition_id], r.[sec_id],
	f.[goals], f.[assists], f.[red_cards], f.[yellow_cards], f.[minutes_played]
    FROM tmp.FactPlayersDaily_source AS f
    INNER JOIN dim.dimPlayers AS d ON f.player_id = d.player_id 
    INNER JOIN dim.dimClubs AS r ON f.club_id = r.club_id
    WHERE d.current_flag = 1 AND r.flag = 1;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersDaily_join',@number,@startdate,GETDATE(), 'insert to with true player_id and club_id');

    -- Insert merged records into tmp.FactPlayersDaily_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersDaily
    SELECT ISNULL(fs.player_key, ft.player_key),
           ISNULL(CONVERT(INT, FORMAT(fs.[time_key], 'yyyyMMdd')), CONVERT(INT, FORMAT(@currdate, 'yyyyMMdd'))),
           ISNULL(fs.competition_key, ft.competition_key),
		   ISNULL(fs.club_key, ft.club_key),
           ISNULL(fs.goalCount, 0) + ISNULL(ft.goalCount, 0),
           ISNULL(fs.assistCount, 0) + ISNULL(ft.assistCount, 0),
           ISNULL(fs.redCardCount, 0) + ISNULL(ft.redCardCount, 0),
           ISNULL(fs.yellowCardCount, 0) + ISNULL(ft.yellowCardCount, 0),
           ISNULL(fs.playMinute, 0) + ISNULL(ft.playMinute, 0)
    FROM tmp.FactPlayersDaily_join AS fs
    FULL OUTER JOIN tmp.FactPlayersDaily_tmp AS ft ON fs.player_key = ft.player_key;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersDaily',@number,@startdate,GETDATE(), 'insert to table from FactPlayersDaily_join and FactPlayersDaily_tmp');

    -- Insert final records into tmp.FactPlayersDaily
	SET @startdate = GETDATE();
    INSERT INTO fact.FactPlayersDaily
    SELECT [player_key], [time_key], [competition_key],
	[club_key], [goalCount], [assistCount], [redCardCount],
	[yellowCardCount], [playMinute]
    FROM tmp.FactPlayersDaily;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','fact.FactPlayersDaily',@number,@startdate,GETDATE(), 'insert to table from FactPlayersDaily');

    -- Update tmp.FactPlayersDaily_tmp with final records
	SET @number = (SELECT COUNT(*) FROM tmp.FactPlayersDaily_tmp);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.FactPlayersDaily_tmp;
    INSERT INTO logg.logg VALUES('truncate','FactPlayersDaily_tmp',@number,@startdate,GETDATE(), 'truncate table by Fact_Players_Daily_First_Load');

	SET @startdate = GETDATE();
    INSERT INTO tmp.FactPlayersDaily_tmp
    SELECT [player_key], [time_key], [competition_key],
	[club_key], [goalCount], [assistCount], [redCardCount],
	[yellowCardCount], [playMinute]
    FROM tmp.FactPlayersDaily;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('insert','FactPlayersDaily_tmp',@number,@startdate,GETDATE(), 'insert to table from FactPlayersDaily');

    -- Move to the next date
    SET @currdate = DATEADD(DAY, 1, @currdate);
  END


END;