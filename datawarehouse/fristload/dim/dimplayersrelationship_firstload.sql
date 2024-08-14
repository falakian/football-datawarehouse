CREATE OR ALTER PROCEDURE dimPlayersRelationship_First_Load 
AS 
BEGIN
    
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Truncate the tmp.dimPlayersRelationship_final table and log the operation
	SET @number = (SELECT COUNT(*)
 FROM tmp.dimPlayersRelationship_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimPlayersRelationship_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayersRelationship_final',@number,@startdate, GETDATE(), 'truncate table by dimPlayersRelationship_First_Load');


	-- Truncate the dim.dimPlayersRelationship table and log the operation
	SET @number = (SELECT COUNT(*)
 FROM dim.dimPlayersRelationship);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimPlayersRelationship;
    INSERT INTO logg.logg VALUES('Truncate', 'dimPlayersRelationship',@number,@startdate, GETDATE(), 'truncate table by dimPlayersRelationship_First_Load');
    

    -- Insert data into tmp.dimPlayersRelationship_join from the football.dbo.players table
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimPlayersRelationship_final
    SELECT 
        isnull(p.["position"],'Unknown')
    FROM football.dbo.players AS p
    GROUP BY p.["position"];
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayersRelationship_final',@number,@startdate, GETDATE(), 'insert to tmp_join from source players');
    
    
    -- Insert data into dim.dimPlayersRelationship from tmp.dimPlayersRelationship_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimPlayersRelationship
    SELECT
        dp.[Type], dp.[TypeDescription]
    FROM tmp.dimPlayersRelationship_final AS dp;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimPlayersRelationship',@number,@startdate, GETDATE(), 'main dimension is properly filled');

END;