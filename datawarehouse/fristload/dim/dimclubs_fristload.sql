CREATE OR ALTER PROCEDURE dimClubs_First_Load
AS 
BEGIN
    
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

	SET @number = (SELECT COUNT(*) FROM dim.dimClubs);
	SET @startdate = GETDATE();
    -- Truncate the tmp.dimClubs_join table and log the operation
    TRUNCATE TABLE dim.dimClubs;
    INSERT INTO logg.logg VALUES('Truncate', 'dim.dimClubs',@number,@startdate, GETDATE(), 'truncate table by dimClubs_First_Load');

	SET @number = (SELECT COUNT(*) FROM tmp.dimClubs_final);
	SET @startdate = GETDATE();
    -- Truncate the tmp.dimClubs_join table and log the operation
    TRUNCATE TABLE tmp.dimClubs_final;
    INSERT INTO logg.logg VALUES('Truncate', 'tmp.dimClubs_final',@number,@startdate, GETDATE(), 'truncate table by dimClubs_First_Load');

    -- Insert data into tmp.dimClubs_join from the football.dbo.clubs table
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_final
    SELECT 
        c.[club_id], c.[name], c.[domestic_competition_id], c.[squad_size],
        c.[foreigners_number], c.[national_team_players], 
        c.[stadium_name], c.[stadium_seats], c.[net_transfer_record], GETDATE(), NULL, 1
    FROM football.dbo.clubs AS c;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_final',@number,@startdate, GETDATE(), 'insert to table from source clubs');

	INSERT INTO tmp.dimClubs_final(club_id,name,domestic_competition_id,
	squad_size,foreigners_number,national_team_players,stadium_name,
	stadium_seats,net_transfer_record,start_date,end_date,flag)
	VALUES(-1,'Unknown',-1,0,0,0,'Unknown',0,0,'2020-01-01',GETDATE(),1);

	-- Insert data into dim.dimClubs from tmp.dimClubs_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimClubs
    SELECT
        dc.[sec_id], dc.[club_id], dc.[name], dc.[domestic_competition_id], dc.[squad_size],
        dc.[foreigners_number], dc.[national_team_players], dc.[stadium_name],
        dc.[stadium_seats], dc.[net_transfer_record], dc.[start_date], dc.[end_date], dc.[flag]
    FROM tmp.dimClubs_final AS dc;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs',@number,@startdate, GETDATE(), 'main dimension is properly filled');

END;
