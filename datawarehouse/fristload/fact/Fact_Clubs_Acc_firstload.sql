CREATE OR ALTER PROCEDURE Fact_Clubs_Acc_First_Load
as
begin
  

  DECLARE @currdate DATE;
  DECLARE @startdate DATETIME;
  DECLARE @number INT;

  

 
  set @currdate = CAST('2020-08-01' as date);
    

  set @currdate = DATEADD(day, 1, @currdate);

  SET @number = (SELECT COUNT(*) FROM fact.FactClubsAcc);
  SET @startdate = GETDATE();
  truncate table fact.FactClubsAcc;
  insert into logg.logg values('truncate','FactClubsAcc',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');


  while @currdate < CAST('2020-08-20' as date) begin
	SET @number = (SELECT COUNT(*) FROM tmp.FactClubsAcc_source_home);
	SET @startdate = GETDATE();
  	truncate table tmp.FactClubsAcc_source_home;
	insert into logg.logg values('truncate','FactClubsAcc_source_home',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactClubsAcc_source_away);
	SET @startdate = GETDATE();
	truncate table tmp.FactClubsAcc_source_away;
	insert into logg.logg values('truncate','FactClubsAcc_source_away',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactClubsAcc_source_home_join);
	SET @startdate = GETDATE();
	truncate table tmp.FactClubsAcc_source_home_join;
	insert into logg.logg values('truncate','FactClubsAcc_source_home_join',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactClubsAcc_source_away_join);
	SET @startdate = GETDATE();
	truncate table tmp.FactClubsAcc_source_away_join;
	insert into logg.logg values('truncate','FactClubsAcc_source_away_join',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactClubsAcc);
	SET @startdate = GETDATE();
    truncate table tmp.FactClubsAcc;
	insert into logg.logg values('truncate','FactClubsAcc',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.FactClubsAcc_final_tmp);
	SET @startdate = GETDATE();
	truncate table tmp.FactClubsAcc_final_tmp;
	insert into logg.logg values('truncate','FactClubsAcc_final_tmp',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');
    
	SET @startdate = GETDATE();
    insert into tmp.FactClubsAcc_source_home
    select g.[competition_id], g.[home_club_id], 
	isnull((select count(*) from football.dbo.games as g1 where g.home_club_id = g1.home_club_id and g1.home_club_goals > g1.away_club_goals and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as winCount, 
	isnull((select count(*) from football.dbo.games as g1 where g.home_club_id = g1.home_club_id and g1.home_club_goals < g1.away_club_goals and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as loseCount,
	isnull((select count(*) from football.dbo.games as g1 where g.home_club_id = g1.home_club_id and g1.home_club_goals = g1.away_club_goals and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as drawCount,
	isnull((select count(*) from football.dbo.games as g1 where g.home_club_id = g1.home_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as totalPlays,
	isnull((select count(*) from football.dbo.games as g1 where g.home_club_id = g1.away_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as awayPlays,
	isnull((select count(*) from football.dbo.games as g1 where g.home_club_id = g1.home_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as homePlays,
	isnull((select sum(g1.away_club_goals) from football.dbo.games as g1 where g.home_club_id = g1.home_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0)  as goalCount
	from football.dbo.games as g
    where g.[date] = @currdate
	GROUP BY 
    g.[competition_id], 
	g.[home_club_id];
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc_source_home',@number,@startdate,getdate(), 'insert to table from football.dbo.games');

	SET @startdate = GETDATE();
	insert into tmp.FactClubsAcc_source_away
    select g.[competition_id], g.[away_club_id], 
	isnull((select count(*) from football.dbo.games as g1 where g.away_club_id = g1.away_club_id and g1.away_club_goals > g1.home_club_goals and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as winCount, 
	isnull((select count(*) from football.dbo.games as g1 where g.away_club_id = g1.away_club_id and g1.away_club_goals < g1.home_club_goals and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as loseCount,
	isnull((select count(*) from football.dbo.games as g1 where g.away_club_id = g1.away_club_id and g1.away_club_goals = g1.home_club_goals and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as drawCount,
	isnull((select count(*) from football.dbo.games as g1 where g.away_club_id = g1.away_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as totalPlays,
	isnull((select count(*) from football.dbo.games as g1 where g.away_club_id = g1.away_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as awayPlays,
	isnull((select count(*) from football.dbo.games as g1 where g.away_club_id = g1.home_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as homePlays,
	isnull((select sum(g1.away_club_goals) from football.dbo.games as g1 where g.away_club_id = g1.away_club_id and g1.[date] = @currdate and g1.competition_id = g.competition_id) , 0) as goalCount
	from football.dbo.games as g
    where g.[date] = @currdate
	GROUP BY 
    g.[competition_id], 
	g.[away_club_id];
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc_source_away',@number,@startdate,getdate(), 'insert to table from football.dbo.games');

	SET @startdate = GETDATE();
	insert into tmp.FactClubsAcc_source_home_join
	select ts.[competition_key],
		   dc.[sec_id],
		   ts.[winCount],
		   ts.[loseCount],
		   ts.[drawCount],
		   ts.[totalPlays],
		   ts.[awayPlays],
		   ts.[homePlays],
		   ts.[goalCount]
	from tmp.FactClubsAcc_source_home as ts inner join dim.dimClubs as dc on(ts.club_id = dc.club_id)
	where dc.flag = 1;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc_source_home_join',@number,@startdate,getdate(), 'insert to table from tmp.FactClubsAcc_source_home and dim.dimClubs');

	SET @startdate = GETDATE();
	insert into tmp.FactClubsAcc_source_away_join
	select ts.[competition_key],
		   dc.[sec_id],
		   ts.[winCount],
		   ts.[loseCount],
		   ts.[drawCount],
		   ts.[totalPlays],
		   ts.[awayPlays],
		   ts.[homePlays],
		   ts.[goalCount]
	from tmp.FactClubsAcc_source_away as ts inner join dim.dimClubs as dc on(ts.club_id = dc.club_id)
	where dc.flag = 1;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc_source_home_join',@number,@startdate,getdate(), 'insert to table from tmp.FactClubsAcc_source_away and dim.dimClubs');

	SET @startdate = GETDATE();
    insert into tmp.FactClubsAcc_final_tmp
    select isnull(fs.competition_key, ft.competition_key),
      isnull(fs.club_key, ft.club_key),
	  isnull(fs.winCount, 0) + isnull(ft.winCount, 0),
	  isnull(fs.loseCount, 0) + isnull(ft.loseCount, 0),
	  isnull(fs.drawCount, 0) + isnull(ft.drawCount, 0),
	  isnull(fs.totalPlays, 0) + isnull(ft.totalPlays, 0),
	  isnull(fs.awayPlays, 0) + isnull(ft.awayPlays, 0),
	  isnull(fs.homePlays, 0) + isnull(ft.homePlays, 0),
	  isnull(fs.goalCount, 0) + isnull(ft.goalCount, 0)
    from tmp.FactClubsAcc_source_home_join as fs
      full outer join fact.FactClubsAcc as ft on fs.club_key = ft.club_key
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc_final_tmp',@number,@startdate,getdate(), 'insert to table from tmp.FactClubsAcc_source_home_join and tmp.FactClubsAcc_tmp');

	SET @startdate = GETDATE();
	insert into tmp.FactClubsAcc
    select isnull(fs.competition_key, ft.competition_key),
      isnull(fs.club_key, ft.club_key),
	  isnull(fs.winCount, 0) + isnull(ft.winCount, 0),
	  isnull(fs.loseCount, 0) + isnull(ft.loseCount, 0),
	  isnull(fs.drawCount, 0) + isnull(ft.drawCount, 0),
	  isnull(fs.totalPlays, 0) + isnull(ft.totalPlays, 0),
	  isnull(fs.awayPlays, 0) + isnull(ft.awayPlays, 0),
	  isnull(fs.homePlays, 0) + isnull(ft.homePlays, 0),
	  isnull(fs.goalCount, 0) + isnull(ft.goalCount, 0)
    from tmp.FactClubsAcc_source_away_join as fs
      full outer join tmp.FactClubsAcc_final_tmp as ft on fs.club_key = ft.club_key
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc',@number,@startdate,getdate(), 'insert to table from tmp.FactClubsAcc_source_away_join and tmp.FactClubsAcc_final_tmp');

	SET @number = (SELECT COUNT(*) FROM fact.FactClubsAcc);
	SET @startdate = GETDATE();
    truncate table fact.FactClubsAcc;
	insert into logg.logg values('truncate','FactClubsAcc',@number,@startdate,getdate(), 'truncate table by Fact_Clubs_Acc_First_Load');
    
	SET @startdate = GETDATE();
    insert into fact.FactClubsAcc
    select [competition_key],
		   [club_key],
		   [winCount],
		   [loseCount],
		   [drawCount],
		   [totalPlays],
		   [awayPlays],
		   [homePlays],
		   [goalCount]
    from tmp.FactClubsAcc;
	SET @number = @@ROWCOUNT;
	insert into logg.logg values('insert','FactClubsAcc',@number,@startdate,getdate(), 'insert to table from tmp.FactClubsAcc');

	insert into logg.acclogg values('fact.FactClubsAcc' , DATEADD(day, -1, @currdate));

    set @currdate = DATEADD(day, 1, @currdate);
  end

end