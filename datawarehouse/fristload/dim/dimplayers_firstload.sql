CREATE OR ALTER PROCEDURE dimPlayers_First_Load 
AS 
BEGIN
    
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Truncate the tmp.dimPlayers_final table and log the operation
	SET @number = (SELECT COUNT(*)
 FROM tmp.dimPlayers_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayers_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayers_final',@number,@startdate, GETDATE(), 'truncate table by dimPlayers_First_Load');

	-- Truncate the dim.dimPlayers table and log the operation
	SET @number = (SELECT COUNT(*)
 FROM dim.dimPlayers);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimPlayers;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayers',@number,@startdate, GETDATE(), 'truncate table by dimPlayers_First_Load');

	-- Insert data into tmp.dimPlayers_join from the football.dbo.players table
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayers_final
    SELECT 
        p.[player_id], p.[current_club_id], p.[player_code], p.[country_of_birth],
        p.[city_of_birth], p.[country_of_citizenship], p.[date_of_birth], p.[sub_position],
        p.["position"], p.[foot], p.[height_in_cm], p.[contract_expiration_date], GETDATE(), NULL, 1
    FROM football.dbo.players AS p;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers_final',@number,@startdate, GETDATE(), 'insert to tmp_join from source players');
    
    -- Insert data into dim.dimPlayers from tmp.dimPlayers_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimPlayers
    SELECT
        dp.[id], dp.[player_id], dp.[current_club_id], dp.[player_code], dp.[country_of_birth],
        dp.[city_of_birth], dp.[country_of_citizenship], dp.[date_of_birth], dp.[sub_position],
        dp.[position], dp.[foot], dp.[height_in_cm], dp.[contract_expiration_date],
        dp.[start_date], dp.[end_date], dp.[current_flag]
    FROM tmp.dimPlayers_final AS dp;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayers',@number,@startdate, GETDATE(), 'main dimension is properly filled');
END;