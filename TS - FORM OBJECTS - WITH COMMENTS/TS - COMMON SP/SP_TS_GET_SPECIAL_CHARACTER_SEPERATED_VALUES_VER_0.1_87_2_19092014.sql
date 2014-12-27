-- VERSION 0.1 STARTDATE:19/09/2014 ENDDATE:19/09/2014 ISSUE NO:87 COMMENT NO:2 DESC:CREATED SP LIKE SAME EI SP. DONE BY :RAJA
DROP PROCEDURE IF EXISTS SP_TS_GET_SPECIAL_CHARACTER_SEPERATED_VALUES;
CREATE PROCEDURE SP_TS_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(IN SPECIAL_CHARACTER VARCHAR(30), IN INPUT_STRING_WITH_COMMAS TEXT, OUT VALUE TEXT, OUT REMAINING_STRING TEXT)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
END;
START TRANSACTION;
SET @LENGTH = 1;
SET @TEMP = INPUT_STRING_WITH_COMMAS;
SET @SPECIAL_CHAR_LENGTH = LENGTH(SPECIAL_CHARACTER);

		SET @POSITION=(SELECT LOCATE(SPECIAL_CHARACTER, @TEMP,@LENGTH));
		IF @POSITION<=0 THEN
			SET VALUE = @TEMP;
		ELSE
			SELECT SUBSTRING(@TEMP,@LENGTH,@POSITION-1) INTO VALUE;
			SET REMAINING_STRING =(SELECT SUBSTRING(@TEMP,@POSITION+ @SPECIAL_CHAR_LENGTH ));
		END IF;
    
 COMMIT;   
END;
/*
CALL SP_TS_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('||','C',@value,@remaining_string);
SELECT @value;
SELECT @remaining_string;

SELECT LOCATE('||', 'A||B||C',1)-- 2 POSITION

SELECT SUBSTRING('A||B||C',1,2 -1) -- A VALUE

SELECT SUBSTRING('A||B||C',2+2)
*/



