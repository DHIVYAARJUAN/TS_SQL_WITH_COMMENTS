-- VER 0.1 ISSUE NO:83 COMMENT #5 STARTDATE:03/09/2014 ENDDATE:03/09/2014 DESC:SP FOR USER RIGHTS ROLE CREATION-INSERT. DONE BY:RAJA
DROP PROCEDURE IF EXISTS SP_TS_ROLE_CREATION_INSERT;
CREATE PROCEDURE SP_TS_ROLE_CREATION_INSERT(
IN CUSTOM_ROLE VARCHAR(15),
IN BASIC_ROLE TEXT,
IN MENUID TEXT,
IN USERSTAMP VARCHAR(50),
IN DB_NAME VARCHAR(20),
OUT RC_FLAG INTEGER)
BEGIN
	DECLARE MENU_LENGTH INTEGER;
	DECLARE TEMP_MENU TEXT;
	DECLARE MENU INTEGER;
	DECLARE MENU_POSITION INTEGER;
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
		SET RC_FLAG=0;
	END;
	SET AUTOCOMMIT = 0;
	START TRANSACTION;
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF CUSTOM_ROLE IS NOT NULL AND BASIC_ROLE IS NOT NULL THEN
		IF NOT EXISTS (SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME = CUSTOM_ROLE) THEN
			-- INSERT QUERY FOR ROLE_CREATION TABLE
			INSERT INTO ROLE_CREATION(URC_ID,RC_NAME,RC_USERSTAMP) VALUES ((SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA=BASIC_ROLE),CUSTOM_ROLE,USERSTAMP);
			SET RC_FLAG=1;
		END IF;
	END IF;
	IF MENUID IS NOT NULL THEN
    SET TEMP_MENU = MENUID;
    SET MENU_LENGTH = 1;
    loop_label : LOOP
  		SET MENU_POSITION=(SELECT LOCATE(',', TEMP_MENU,MENU_LENGTH));
  		IF (MENU_POSITION<=0) THEN
  			SET MENU=TEMP_MENU;
  		ELSE
  			SELECT SUBSTRING(TEMP_MENU,MENU_LENGTH,MENU_POSITION-1) INTO MENU;
  			SET TEMP_MENU=(SELECT SUBSTRING(TEMP_MENU,MENU_POSITION+1));
  		END IF;
      
		  -- INSERT QUERY FOR USER_MENU_DETAILS
  		INSERT INTO USER_MENU_DETAILS(MP_ID,RC_ID,ULD_ID)VALUES(MENU,(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=CUSTOM_ROLE),USERSTAMP_ID);
		  SET RC_FLAG=1;
		  IF (MENU_POSITION<=0) THEN
  			LEAVE  loop_label;
  		END IF;
  	END LOOP;
	END IF; 
	COMMIT;
END;
/*
CALL SP_TS_ROLE_CREATION_INSERT('USER1','USER','1,2,3,4','dhandapani.sattanathan@ssomens.com','SQL_TEAM',@RC_FLAG);
*/