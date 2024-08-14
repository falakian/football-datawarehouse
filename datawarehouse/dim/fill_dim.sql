CREATE OR ALTER PROCEDURE fill_dim as begin
	exec dimClubs_update;
	exec dimCompetitions_update;
	exec dimGames_update;
	exec dimPlayers_update;
	exec dimPlayersRelationship_update;
end
