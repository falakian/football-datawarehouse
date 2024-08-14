CREATE OR ALTER PROCEDURE Fill_player_datamart as begin
	exec Fact_Players_Acc_update;
	exec Fact_Players_Daily_update;
	exec fact_players_transactional_update;
end