CREATE OR ALTER PROCEDURE Fact_Competitions_Daily_First_Load
as
begin
  
  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;

  
  set @currdate = CAST('2020-08-01' as date);
   

  set @currdate = DATEADD(day, 1, @currdate);

  SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_tmp);
  SET @startdate = GETDATE();
  truncate table tmp.FactCompetitionsDaily_tmp;
  insert into logg.logg values('truncate','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_First_Load');

  SET @number = (SELECT COUNT(*) FROM fact.FactCompetitionsDaily);
  SET @startdate = GETDATE();
  truncate table fact.FactCompetitionsDaily;
  insert into logg.logg values('truncate','FactCompetitionsDaily',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_First_Load');
  
  

  while @currdate < CAST('2020-08-20' as date) 
  begin
	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_source);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsDaily_source;
	insert into logg.logg values('truncate','FactCompetitionsDaily_source',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsDaily;
	insert into logg.logg values('truncate','FactCompetitionsDaily',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_First_Load');
    
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
    insert into tmp.FactCompetitionsDaily
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
	insert into logg.logg values('insert','FactCompetitionsDaily',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily_source and tmp.FactCompetitionsDaily_tmp');

	SET @startdate = GETDATE();
	insert into fact.FactCompetitionsDaily
	select [competition_key],
		   [time_key],
		   [goalCount],
		   [redCardCount],
		   [yellowCardCount],
		   [attendance],
		   [playCount]
	from tmp.FactCompetitionsDaily;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsDaily',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily');

	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsDaily_tmp);
	SET @startdate = GETDATE();
    truncate table tmp.FactCompetitionsDaily_tmp;
	insert into logg.logg values('truncate','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Daily_First_Load');
    
	SET @startdate = GETDATE();
	insert into tmp.FactCompetitionsDaily_tmp
    select [competition_key],
		   [time_key],
		   [goalCount],
		   [redCardCount],
		   [yellowCardCount],
		   [attendance],
		   [playCount]
    from tmp.FactCompetitionsDaily;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsDaily_tmp',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsDaily');

    set @currdate = DATEADD(day, 1, @currdate);
  end

end