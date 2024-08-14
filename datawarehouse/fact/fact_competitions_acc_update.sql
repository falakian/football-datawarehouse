CREATE OR ALTER PROCEDURE Fact_Competitions_Acc_update
as
begin

  DECLARE @factCount INT;
  DECLARE @tempCount INT;
  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;

  set @factCount = (select count(*) from fact.FactCompetitionsAcc);
  set @tempCount = (select count(*) from tmp.FactCompetitionsAcc_tmp);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
        set @currdate = CAST('2020-08-01' as date);
    else
        set @currdate = (SELECT MAX(ll.[Date]) from logg.acclogg as ll where ll.targetTable = 'fact.FactCompetitionsAcc')

  set @currdate = DATEADD(day, 1, @currdate);

  SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsAcc_tmp);
  SET @startdate = GETDATE();
  truncate table tmp.FactCompetitionsAcc_tmp;
  insert into logg.logg values('truncate','FactCompetitionsAcc_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_update');
  
  SET @startdate = GETDATE();
  insert into tmp.FactCompetitionsAcc_tmp
  select [competition_key],
		 [goalCount],
		 [redCardCount],
		 [yellowCardCount],
		 [attendance],
		 [playCount]
  from fact.FactCompetitionsAcc
  SET @number = @@ROWCOUNT;
  insert into logg.logg values('insert','FactCompetitionsAcc_tmp',@number,@startdate,getdate(), 'insert to table from fact.FactCompetitionsAcc');

  while @currdate < CAST('2020-08-20' as date)
  begin
	
	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsAcc_source);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsAcc_source;
	insert into logg.logg values('truncate','FactCompetitionsAcc_source',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_update');

	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsAcc_final);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsAcc_final;
    insert into logg.logg values('truncate','FactCompetitionsAcc_final',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_update');
    
	SET @startdate = GETDATE();
	insert into tmp.FactCompetitionsAcc_source
    select g.[competition_id],
	sum(g.[away_club_goals] + g.[home_club_goals]),
	sum(a.[red_cards]),
	sum(a.[yellow_cards]),
	sum(isnull(g.[attendance],0)),
	count(g.[game_id])
    from football.dbo.appearances as a 
	inner join football.dbo.games as g on a.[game_id] = g.[game_id]
    where g.[date] = @currdate
	GROUP BY 
    g.[competition_id] 
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsAcc_source',@number,@startdate,getdate(), 'insert to table from football.dbo.appearances and football.dbo.games');
    
	SET @startdate = GETDATE();
	insert into tmp.FactCompetitionsAcc_final
    select isnull(fs.competition_key, ft.competition_key),
      isnull(fs.goalCount, 0) + isnull(ft.goalCount, 0),
	  isnull(fs.redCardCount, 0) + isnull(ft.redCardCount, 0),
	  isnull(fs.yellowCardCount, 0) + isnull(ft.yellowCardCount, 0),
	  isnull(fs.attendance, 0) + isnull(ft.attendance, 0),
	  isnull(fs.playCount, 0) + isnull(ft.playCount, 0)
    from tmp.FactCompetitionsAcc_source as fs
      full outer join tmp.FactCompetitionsAcc_tmp as ft on fs.competition_key = ft.competition_key
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsAcc_final',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsAcc_source and tmp.FactCompetitionsAcc_tmp');
	
	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsAcc_tmp);
	SET @startdate = GETDATE();
	truncate table tmp.FactCompetitionsAcc_tmp;
	insert into logg.logg values('truncate','FactCompetitionsAcc_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_update');
    
	SET @startdate = GETDATE();
	insert into tmp.FactCompetitionsAcc_tmp
    select [competition_key],
		   [goalCount],
		   [redCardCount],
		   [yellowCardCount],
		   [attendance],
		   [playCount]
    from tmp.FactCompetitionsAcc_final;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsAcc_tmp',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsAcc_final');
    
	set @currdate = DATEADD(day, 1, @currdate);
  end

  SET @number = (SELECT COUNT(*) FROM fact.FactCompetitionsAcc);
  SET @startdate = GETDATE();
  truncate table fact.FactCompetitionsAcc;
  insert into logg.logg values('truncate','FactCompetitionsAcc',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_update');
  
  SET @startdate = GETDATE();
  insert into fact.FactCompetitionsAcc
  select
    [competition_key],
	[goalCount],
	[redCardCount],
	[yellowCardCount],
	[attendance],
	[playCount]
  from tmp.FactCompetitionsAcc_tmp;
  SET @number = @@ROWCOUNT;
  insert into logg.logg values('insert','fact.FactCompetitionsAcc',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsAcc_tmp');

  insert into logg.acclogg values('fact.FactCompetitionsAcc' , DATEADD(day, -1, @currdate));

end

