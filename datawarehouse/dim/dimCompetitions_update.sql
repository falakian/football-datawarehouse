CREATE OR ALTER PROCEDURE dimCompetitions_update AS 
BEGIN
    
    DECLARE @dimCount INT;
    DECLARE @tempCount INT;
    DECLARE @startdate DATETIME;
	DECLARE @number INT;

    -- Get the count of records in dim.dimCompetitions
    SET @dimCount = (SELECT COUNT(*) FROM dim.dimCompetitions);
    
    -- Get the count of records in tmp.dimCompetitions_final
    SET @tempCount = (SELECT COUNT(*) FROM tmp.dimCompetitions_final);
    
    -- If dim.dimCompetitions is empty and tmp.dimCompetitions_final has records, exit the procedure
    IF (@dimCount = 0 AND @tempCount > 0)
        RETURN 0;
    
    -- Truncate the tmp.dimCompetitions_source table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimCompetitions_source);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimCompetitions_source;
    INSERT INTO logg.logg VALUES('Truncate', 'dimCompetitions_source',@number,@startdate, GETDATE(), 'truncate table by dimCompetitions_update');

    -- Truncate the tmp.dimCompetitions_final table and log the operation
	SET @number = (SELECT COUNT(*) FROM tmp.dimCompetitions_final);
	SET @startdate = GETDATE();
    TRUNCATE TABLE tmp.dimCompetitions_final;
    INSERT INTO logg.logg VALUES('Truncate', 'dimCompetitions_final',@number,@startdate, GETDATE(), 'truncate table by dimCompetitions_update');
    
    -- Insert data into tmp.dimCompetitions_source from the football.dbo.competitions table
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimCompetitions_source
        SELECT 
            c.[competition_id],
            c.[name],
            c.[type],
            c.[country_name]
        FROM football.dbo.competitions AS c;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimCompetitions_source',@number,@startdate, GETDATE(), 'insert to table from source competitions');
    
    -- Insert data into tmp.dimCompetitions_final where competition_id is not in dim.dimCompetitions
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimCompetitions_final
        SELECT
            dc.[competition_id],
            dc.[competition_name_orginal],
            dc.[competition_name_current],
            dc.[effective_date],
            dc.["type"],
            dc.[country_name]
        FROM tmp.dimCompetitions_source AS d
        RIGHT JOIN dim.dimCompetitions AS dc ON d.[competition_id] = dc.[competition_id]
        WHERE d.competition_id IS NULL AND d.name = dc.competition_name_current;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimCompetitions_final',@number,@startdate, GETDATE(), 'insert records that not update in source');

    -- Insert data into tmp.dimCompetitions_final where names are different
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimCompetitions_final
        SELECT
            dc.[competition_id],
            dc.[competition_name_current],
            d.[name],
            GETDATE(),
            dc.["type"],
            dc.[country_name]
        FROM tmp.dimCompetitions_source AS d
        INNER JOIN dim.dimCompetitions AS dc ON d.[competition_id] = dc.[competition_id]
        WHERE d.[name] <> dc.[competition_name_current];
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimCompetitions_final',@number,@startdate, GETDATE(), 'insert records that update in source');

    -- Insert new competitions into tmp.dimCompetitions_final
	SET @startdate = GETDATE();
    INSERT INTO tmp.dimCompetitions_final
        SELECT
            d.[competition_id],
            NULL,
            d.[name],
            GETDATE(),
            d.["type"],
            d.[country_name]
        FROM tmp.dimCompetitions_source AS d
        LEFT JOIN dim.dimCompetitions AS dc ON d.[competition_id] = dc.[competition_id]
        WHERE dc.[competition_id] IS NULL;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimCompetitions_final',@number,@startdate, GETDATE(), 'insert records that new in source');

    -- Truncate the dim.dimCompetitions table and log the operation
	SET @number = (SELECT COUNT(*) FROM dim.dimCompetitions);
	SET @startdate = GETDATE();
    TRUNCATE TABLE dim.dimCompetitions;
    INSERT INTO logg.logg VALUES('Truncate', 'dimCompetitions',@number,@startdate, GETDATE(), 'truncate table by dimCompetitions_update');
        
    -- Insert data into dim.dimCompetitions from tmp.dimCompetitions_final
	SET @startdate = GETDATE();
    INSERT INTO dim.dimCompetitions
        SELECT
            dc.[competition_id],
            dc.[competition_name_orginal],
            dc.[competition_name_current],
            dc.[effective_date],
            dc.["type"],
            dc.[country_name]
        FROM tmp.dimCompetitions_final AS dc;
	SET @number = @@ROWCOUNT;
    INSERT INTO logg.logg VALUES('Insert', 'dimCompetitions',@number,@startdate, GETDATE(), 'main dimension is properly filled');
END
