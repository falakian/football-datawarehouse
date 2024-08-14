CREATE OR ALTER PROCEDURE dimClubs_update 
AS 
BEGIN
    
    DECLARE @dimCount INT;
    DECLARE @tempCount INT;
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Get the count of records in dim.dimClubs
    SET @dimCount = (SELECT COUNT(*) FROM dim.dimClubs);
    
    -- Get the count of records in tmp.dimClubs_final
    SET @tempCount = (SELECT COUNT(*) FROM tmp.dimClubs_final);
    
    -- If dim.dimClubs is empty and tmp.dimClubs_final has records, exit the procedure
    IF (@dimCount = 0 AND @tempCount > 0)
        RETURN 0;
	
	SET @number = (SELECT COUNT(*) FROM tmp.dimClubs_join);
	SET @startdate = GETDATE();
    -- Truncate the tmp.dimClubs_join table and log the operation
    TRUNCATE TABLE tmp.dimClubs_join;
    INSERT INTO logg.logg VALUES('Truncate', 'dimClubs_join',@number,@startdate, GETDATE(), 'truncate table by dimClubs_update');

	SET @number = (SELECT COUNT(*) FROM tmp.dimClubs_active);
	SET @startdate = GETDATE();
    -- Truncate the tmp.dimClubs_active table and log the operation
    TRUNCATE TABLE tmp.dimClubs_active;
    INSERT INTO logg.logg VALUES('Truncate', 'dimClubs_active',@number,@startdate, GETDATE(), 'truncate table by dimClubs_update');

	SET @number = (SELECT COUNT(*) FROM tmp.dimClubs_final);
	SET @startdate = GETDATE();
    -- Truncate the tmp.dimClubs_final table and log the operation
    TRUNCATE TABLE tmp.dimClubs_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimClubs_final',@number,@startdate, GETDATE(), 'truncate table by dimClubs_update');
    
    -- Enable identity insert for tmp.dimClubs_final
    SET IDENTITY_INSERT tmp.dimClubs_final ON;

    -- Insert data into tmp.dimClubs_join from the football.dbo.clubs table
	
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_join
    SELECT 
        c.[club_id], c.[name], c.[domestic_competition_id], c.[squad_size],
        c.[foreigners_number], c.[national_team_players], 
        c.[stadium_name], c.[stadium_seats], c.[net_transfer_record]
    FROM football.dbo.clubs AS c;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_join',@number,@startdate, GETDATE(), 'insert to table from source clubs');
    
    -- Insert active records into tmp.dimClubs_active
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_active
    SELECT
        dc.[sec_id], dc.[club_id], dc.[name], dc.[domestic_competition_id],
        dc.[squad_size], dc.[foreigners_number], dc.[national_team_players], 
        dc.[stadium_name], dc.[stadium_seats], dc.[net_transfer_record], 
        dc.[start_date], dc.[end_date], dc.[flag]
    FROM dim.dimClubs AS dc
    WHERE dc.[flag] = 1;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_active',@number,@startdate, GETDATE(), 'insert active record to table');

    -- Insert non-active records into tmp.dimClubs_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_final
    (
        [sec_id], [club_id], [name], [domestic_competition_id], 
        [squad_size], [foreigners_number], [national_team_players], 
        [stadium_name], [stadium_seats], [net_transfer_record], 
        [start_date], [end_date], [flag]
    )
    SELECT
        dc.[sec_id], dc.[club_id], dc.[name], dc.[domestic_competition_id],
        dc.[squad_size], dc.[foreigners_number], dc.[national_team_players], 
        dc.[stadium_name], dc.[stadium_seats], dc.[net_transfer_record], 
        dc.[start_date], dc.[end_date], dc.[flag]
    FROM dim.dimClubs AS dc
    WHERE dc.[flag] = 0;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_final',@number,@startdate, GETDATE(), 'insert non-active record to table');

    -- Insert records in main dimension but not in tmp.dimClubs_join
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_final
    (
        [sec_id], [club_id], [name], [domestic_competition_id], [squad_size],
        [foreigners_number], [national_team_players], [stadium_name], [stadium_seats],
        [net_transfer_record], [start_date], [end_date], [flag]
    )
    SELECT
        dc.[sec_id], dc.[club_id], dc.[name], dc.[domestic_competition_id],
        dc.[squad_size], dc.[foreigners_number], dc.[national_team_players], 
        dc.[stadium_name], dc.[stadium_seats], dc.[net_transfer_record],
        dc.[start_date], dc.[end_date], dc.[flag]
    FROM tmp.dimClubs_join AS tdj
    RIGHT JOIN tmp.dimClubs_active AS dc ON tdj.[club_id] = dc.[club_id]
    WHERE (tdj.[club_id] IS NULL) OR (dc.[name] = tdj.[name]);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_final',@number,@startdate, GETDATE(), 'insert record in main dimension but not in tmp to table');

    -- Insert records that are not active now
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_final
    (
        [sec_id], [club_id], [name], [domestic_competition_id], [squad_size],
        [foreigners_number], [national_team_players], [stadium_name],
        [stadium_seats], [net_transfer_record], [start_date], [end_date], [flag]
    )
    SELECT
        dc.[sec_id], dc.[club_id], dc.[name], dc.[domestic_competition_id],
        dc.[squad_size], dc.[foreigners_number], dc.[national_team_players], 
        dc.[stadium_name], dc.[stadium_seats], dc.[net_transfer_record],
        dc.[start_date], GETDATE(), 0
    FROM tmp.dimClubs_join AS tdj
    INNER JOIN tmp.dimClubs_active AS dc ON dc.club_id = tdj.club_id
    WHERE (dc.name != tdj.name);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_final',@number,@startdate, GETDATE(), 'insert record to table that not active now');

    -- Disable identity insert for tmp.dimClubs_final
    SET IDENTITY_INSERT tmp.dimClubs_final OFF;
    
    -- Insert new active records into tmp.dimClubs_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimClubs_final
    SELECT
        dc.[club_id], dc.[name], dc.[domestic_competition_id], dc.[squad_size],
        dc.[foreigners_number], dc.[national_team_players], dc.[stadium_name],
        dc.[stadium_seats], dc.[net_transfer_record], GETDATE(), NULL, 1
    FROM tmp.dimClubs_join AS dc
    LEFT JOIN tmp.dimClubs_active AS tda ON dc.[club_id] = tda.[club_id]
    WHERE (tda.[club_id] IS NULL) OR (dc.[name] != tda.[name]);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimClubs_final',@number,@startdate, GETDATE(), 'insert new active record to table');
    
	IF (@dimCount = 0)
		INSERT INTO tmp.dimClubs_final(club_id,name,domestic_competition_id,
		squad_size,foreigners_number,national_team_players,stadium_name,
		stadium_seats,net_transfer_record,start_date,end_date,flag)
		VALUES(-1,'Unknown',-1,0,0,0,'Unknown',0,0,'2020-01-01',GETDATE(),1);

    -- Truncate the dim.dimClubs table and log the operation
	SET @number = (SELECT COUNT(*) FROM dim.dimClubs);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimClubs;
    INSERT INTO logg.logg VALUES('Truncate', 'dimClubs',@number,@startdate, GETDATE(), 'truncate table by dimClubs_update');

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

