CREATE PROCEDURE dbo.InsertWatermark
    @FileName VARCHAR(255)
AS
BEGIN
  BEGIN TRANSACTION;
    INSERT INTO dbo.FileWatermark (FileName)
    VALUES (@FileName);
  COMMIT TRANSACTION;
END
