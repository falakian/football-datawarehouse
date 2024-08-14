CREATE OR ALTER PROCEDURE Fact_Competitions_Daily_update
as
begin
  DECLARE @factCount INT;
  DECLARE @tempCount INT;
  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;

  set @factCount = (select count(*) from fact.FactCompetitionsDaily);
  set @tempCount = (select count(*) from tmp.FactCompetitionsDaily);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
        set @currdate = CAST('2020-08-01' as date);
    else
        set @currdate = (SELECT MAX(CONVERT(DATE, CONVERT(CHAR(8), f.[time_key]))) 
						from fact.FactCompetitionsDaily as f)

  set @currdate = DATEADD(day, 1, @currdate);

  SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_tmp);
  SET @startdate = GETDATE();
  truncate table tmp.FactCompetitionsDaily_tmp;
  insert into logg.logg values('truncate','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_update');

  SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily);
  SET @startdate = GETDATE();
  truncate table tmp.FactCompetitionsDaily;
  insert into logg.logg values('truncate','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_update');
  
  SET @startdate = GETDATE();
  insert into tmp.FactCompetitionsDaily_tmp
  select [competition_key],
		 [time_key],
		 [goalCount],
		 [redCardCount],
		 [yellowCardCount],
		 [attendance],
		 [playCount]
  from (select [competition_key],
			   [time_key],
			   [goalCount],
			   [redCardCount],
			   [yellowCardCount],
			   [attendance],
			   [playCount] ,
			   RANK() OVER (PARTITION BY competition_key ORDER BY time_key DESC) as rank_time
  from fact.FactCompetitionsDaily) as res
  where res.rank_time = 1;
  SET @number = @@ROWCOUNT;
  insert into logg.logg values('insert','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'insert to table from fact.FactCompetitionsDaily');
  
  SET @startdate = GETDATE();
  insert into tmp.FactCompetitionsDaily
  select [competition_key],
		 [time_key],
		 [goalCount],
		 [redCardCount],
		 [yellowCardCount],
		 [attendance],
		 [playCount]
  from fact.FactCompetitionsDaily
  SET @number = @@ROWCOUNT;
  insert into logg.logg values('insert','FactCompetitionsDaily',@number,@startdate,getdate(), 'insert to table from fact.FactCompetitionsDaily');

  while @currdate < CAST('2020-08-20' as date) 
  begin
	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_source);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsDaily_source;
	insert into logg.logg values('truncate','FactCompetitionsDaily_source',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_update');

	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_final);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsDaily_final;
	insert into logg.logg values('truncate','FactCompetitionsDaily_final',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_update');
    
	SET @startdate = GETDATE();
    insert into tmp.FactCompetitionsDaily_source
	select g.[competition_id],
	CONVERT(INT, FORMAT(g.[date], 'yyyyMMdd')),
	sum(g.[away_club_goals] + g.[home_club_goals]),
	sum(a.[red_cards]),
	sum(a.[yellow_cards]),
	sum(isnull(g.[attendance],0)),
	count(g.[game_id])
    from football.dbo.appearances as a 
	inner join football.dbo.games as g on a.[game_id] = g.[game_id]
    where g.[date] = @currdate
	GROUP BY 
    g.[competition_id],
    g.[date]; 
	SET @number = @@ROWCOUNT; 
	insert into logg.logg values('insert','FactCompetitionsDaily_source',@number,@startdate,getdate(), 'insert to table from football.dbo.appearances and football.dbo.games');

	SET @startdate = GETDATE();
    insert into tmp.FactCompetitionsDaily_final
    select isnull(fs.competition_key, ft.competition_key),
      isnull(fs.time_key,CONVERT(INT, FORMAT(@currdate, 'yyyyMMdd'))),
      isnull(fs.goalCount, 0) + isnull(ft.goalCount, 0),
	  isnull(fs.redCardCount, 0) + isnull(ft.redCardCount, 0),
	  isnull(fs.yellowCardCount, 0) + isnull(ft.yellowCardCount, 0),
	  isnull(fs.attendance, 0) + isnull(ft.attendance, 0),
	  isnull(fs.playCount, 0) + isnull(ft.playCount, 0)
    from tmp.FactCompetitionsDaily_source as fs
      full outer join tmp.FactCompetitionsDaily_tmp as ft on fs.competition_key = ft.competition_key
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsDaily_final',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily_source and tmp.FactCompetitionsDaily_tmp');

	SET @startdate = GETDATE();
	insert into tmp.FactCompetitionsDaily
	select [competition_key],
		   [time_key],
		   [goalCount],
		   [redCardCount],
		   [yellowCardCount],
		   [attendance],
		   [playCount]
	from tmp.FactCompetitionsDaily_final;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsDaily',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily_final');

	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_tmp);
	SET @startdate = GETDATE();
    truncate table tmp.FactCompetitionsDaily_tmp;
	insert into logg.logg values('truncate','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_update');
    
	SET @startdate = GETDATE();
	insert into tmp.FactCompetitionsDaily_tmp
    select [competition_key],
		   [time_key],
		   [goalCount],
		   [redCardCount],
		   [yellowCardCount],
		   [attendance],
		   [playCount]
    from tmp.FactCompetitionsDaily_final;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily_final');

    set @currdate = DATEADD(day, 1, @currdate);
  end

  SET @number = (SELECT COUNT(*) FROM fact.FactCompetitionsDaily);
  SET @startdate = GETDATE();
  truncate table fact.FactCompetitionsDaily;
  insert into logg.logg values('truncate','FactCompetitionsDaily',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_update');

  SET @startdate = GETDATE();
  insert into fact.FactCompetitionsDaily
  select
    [competition_key],
	[time_key],
	[goalCount],
	[redCardCount],
	[yellowCardCount],
	[attendance],
	[playCount]
  from tmp.FactCompetitionsDaily;
  SET @number = @@ROWCOUNT;
  insert into logg.logg values('insert','fact.FactCompetitionsDaily',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily');

end