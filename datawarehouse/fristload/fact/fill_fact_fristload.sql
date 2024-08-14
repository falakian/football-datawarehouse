CREATE OR ALTER PROCEDURE fill_fact_frist_load as begin
	exec Fact_Clubs_Acc_First_Load;
	exec Fact_Clubs_Daily_First_Load;
	exec fact_competition_transactional_First_Load;
	exec Fact_Competitions_Acc_First_Load;
	exec Fact_Competitions_Daily_First_Load;
	exec Fact_Players_Acc_First_Load;
	exec Fact_Players_Daily_First_Load;
	exec fact_players_transactional_First_Load;
	exec fact_club_transactional_First_Load;
end