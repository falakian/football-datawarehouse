CREATE OR ALTER PROCEDURE Fill_club_datamart as begin
	exec Fact_Clubs_Acc_update;
	exec Fact_Clubs_Daily_update;
	exec fact_club_transactional_update;
end