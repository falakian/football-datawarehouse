CREATE OR ALTER PROCEDURE dimPlayersRelationship_update 
AS 
BEGIN
    
    DECLARE @dimCount INT;
    DECLARE @tempCount INT;
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Get the count of records in dim.dimPlayersRelationship
    SET @dimCount = (SELECT COUNT(*) FROM dim.dimPlayersRelationship);
    
    -- Get the count of records in tmp.dimPlayersRelationship_final
    SET @tempCount = (SELECT COUNT(*) FROM tmp.dimPlayersRelationship_final);
    
    -- If dim.dimPlayersRelationship is empty and tmp.dimPlayersRelationship_final has records, exit the procedure
    IF (@dimCount = 0 AND @tempCount > 0)
        RETURN 0;
    
    -- Truncate the tmp.dimPlayersRelationship_join table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimPlayersRelationship_join);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayersRelationship_join;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayersRelationship_join',@number,@startdate, GETDATE(), 'truncate table by dimPlayersRelationship_update');

    -- Truncate the tmp.dimPlayersRelationship_final table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimPlayersRelationship_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayersRelationship_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayersRelationship_final',@number,@startdate, GETDATE(), 'truncate table by dimPlayersRelationship_update');
    
    -- Enable identity insert for tmp.dimPlayersRelationship_final
    SET IDENTITY_INSERT tmp.dimPlayersRelationship_final ON;

    -- Insert data into tmp.dimPlayersRelationship_join from the football.dbo.players table
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayersRelationship_join
    SELECT 
        isnull(p.[position],'Unknown')
    FROM football.dbo.players AS p
    GROUP BY p.[position];
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayersRelationship_join',@number,@startdate, GETDATE(), 'insert to tmp_join from source players');
    
    -- Insert records from dim.dimPlayersRelationship to tmp.dimPlayersRelationship_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayersRelationship_final
    (
        [Type], [TypeDescription]
    )
    SELECT
        dp.[Type], dp.[TypeDescription]
    FROM dim.dimPlayersRelationship AS dp;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayersRelationship_final',@number,@startdate, GETDATE(), 'Insert records from dim.dimPlayersRelationship');
    
    -- Disable identity insert for tmp.dimPlayersRelationship
    SET IDENTITY_INSERT tmp.dimPlayersRelationship_final OFF;
    
    -- Insert new records into tmp.dimPlayersRelationship_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayersRelationship_final
	SELECT dp.[TypeDescription]
	FROM tmp.dimPlayersRelationship_join AS dp
	WHERE dp.[TypeDescription] NOT IN (SELECT d.[TypeDescription] FROM tmp.dimPlayersRelationship_final AS d);
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayersRelationship_final',@number,@startdate, GETDATE(), 'insert new record to table');
    
    -- Truncate the dim.dimPlayersRelationship table and log the operation
	SET @number = (SELECT COUNT(*) FROM dim.dimPlayersRelationship);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimPlayersRelationship;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayersRelationship',@number,@startdate, GETDATE(), 'truncate table by dimPlayersRelationship_update');
    
    -- Insert data into dim.dimPlayersRelationship from tmp.dimPlayersRelationship_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimPlayersRelationship
    SELECT
        dp.[Type], dp.[TypeDescription]
    FROM tmp.dimPlayersRelationship_final AS dp;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayersRelationship',@number,@startdate, GETDATE(), 'main dimension is properly filled');

END;
