CREATE OR ALTER PROCEDURE dimCompetitions_First_Load AS 
BEGIN
    
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

	SET @number = (SELECT COUNT(*)
 FROM dim.dimCompetitions);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimCompetitions;
    INSERT INTO logg.logg VALUES('Truncate', 'dimCompetitions',@number,@startdate, GETDATE(), 'truncate table by dimCompetitions_First_Load');
    
    -- Insert data into tmp.dimCompetitions_source from the football.dbo.competitions table
	SET @startdate = GETDATE();
    INSERT INTO dim.dimCompetitions
        SELECT 
            c.[competition_id],
            NULL,
            c.[name],
            GETDATE(),
            c.["type"],
            c.[country_name]
        FROM football.dbo.competitions AS c;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimCompetitions',@number,@startdate, GETDATE(), 'insert to table from source competitions');
    
END
