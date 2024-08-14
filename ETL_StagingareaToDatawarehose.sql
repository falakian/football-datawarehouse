CREATE OR ALTER PROCEDURE ETL_StagingareaToDatawarehose as begin
	exec fill_dim;
	exec Fill_club_datamart;
	exec Fill_competition_datamart;
	exec Fill_player_datamart;
end