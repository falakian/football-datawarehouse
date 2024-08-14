CREATE OR ALTER PROCEDURE fill_dim_frist_load as begin
	exec dimClubs_First_Load;
	exec dimCompetitions_First_Load;
	exec dimGames_First_Load;
	exec dimPlayers_First_Load;
	exec dimPlayersRelationship_First_Load;
end
