CREATE OR ALTER PROCEDURE Fill_competition_datamart as begin
	exec fact_competition_transactional_update;
	exec Fact_Competitions_Acc_update;
	exec Fact_Competitions_Daily_update;
end