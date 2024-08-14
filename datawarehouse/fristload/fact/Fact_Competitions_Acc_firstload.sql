CREATE OR ALTER PROCEDURE Fact_Competitions_Acc_First_Load
as
begin

  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;


 
  set @currdate = CAST('2020-08-01' as date);
    

  set @currdate = DATEADD(day, 1, @currdate);

  SET @number = (SELECT COUNT(*) FROM fact.FactCompetitionsAcc);
  SET @startdate = GETDATE();
  truncate table fact.FactCompetitionsAcc;
  insert into logg.logg values('truncate','FactCompetitionsAcc',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_First_Load');
  

  while @currdate < CAST('2020-08-20' as date)
  begin
	
	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsAcc_source);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsAcc_source;
	insert into logg.logg values('truncate','FactCompetitionsAcc_source',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactCompetitionsAcc_tmp);
	SET @startdate = GETDATE();
  	truncate table tmp.FactCompetitionsAcc_tmp;
    insert into logg.logg values('truncate','FactCompetitionsAcc_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_First_Load');
    
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
	insert into tmp.FactCompetitionsAcc_tmp
    select isnull(fs.competition_key, ft.competition_key),
      isnull(fs.goalCount, 0) + isnull(ft.goalCount, 0),
	  isnull(fs.redCardCount, 0) + isnull(ft.redCardCount, 0),
	  isnull(fs.yellowCardCount, 0) + isnull(ft.yellowCardCount, 0),
	  isnull(fs.attendance, 0) + isnull(ft.attendance, 0),
	  isnull(fs.playCount, 0) + isnull(ft.playCount, 0)
    from tmp.FactCompetitionsAcc_source as fs
      full outer join fact.FactCompetitionsAcc as ft on fs.competition_key = ft.competition_key
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsAcc_tmp',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsAcc_source and fact.FactCompetitionsAcc');
	
	SET @number = (SELECT COUNT(*) FROM fact.FactCompetitionsAcc);
	SET @startdate = GETDATE();
	truncate table fact.FactCompetitionsAcc;
	insert into logg.logg values('truncate','FactCompetitionsAcc',@number,@startdate,getdate(), 'truncate table by Fact_Competitions_Acc_First_Load');
    
	SET @startdate = GETDATE();
	insert into fact.FactCompetitionsAcc
    select [competition_key],
		   [goalCount],
		   [redCardCount],
		   [yellowCardCount],
		   [attendance],
		   [playCount]
    from tmp.FactCompetitionsAcc_tmp;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactCompetitionsAcc',@number,@startdate,getdate(), 'insert to table from tmp.FactCompetitionsAcc_tmp');
    insert into logg.acclogg values('fact.FactCompetitionsAcc' , DATEADD(day, -1, @currdate));
	set @currdate = DATEADD(day, 1, @currdate);
  end

end