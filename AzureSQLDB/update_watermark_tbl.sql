CREATE PROCEDURE update_watermark_tbl
    @last_load Varchar(200)
AS
BEGIN
    BEGIN TRANSACTION;

	UPDATE [dbo].[watermark_tbl]
	SET last_load_dt = @last_load

END;
