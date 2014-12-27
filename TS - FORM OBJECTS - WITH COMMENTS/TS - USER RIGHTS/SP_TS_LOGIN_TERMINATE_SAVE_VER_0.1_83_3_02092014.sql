-- VER 0.1 ISSUE NO:83 COMMENT #3 STARTDATE:02/09/2014 ENDDATE:02/09/2014 DESC:SP FOR LOGIN TERMINATION INSERT. DONE BY:RAJA
DROP PROCEDURE IF EXISTS SP_TS_LOGIN_TERMINATE_SAVE;
CREATE PROCEDURE SP_TS_LOGIN_TERMINATE_SAVE(
IN LOGINID VARCHAR(40),
IN ENDDATE DATE,
IN REASON TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_FLAG INTEGER)
BEGIN
	DECLARE RECVER INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
  	ROLLBACK;
  	SET SUCCESS_FLAG=0;    
	END;
	SET AUTOCOMMIT = 0;
	-- FOR UPDATE USER ACCESS
	IF (LOGINID IS NOT NULL AND ENDDATE IS NOT NULL AND REASON IS NOT NULL AND USERSTAMP IS NOT NULL) THEN
		SET RECVER=(SELECT MAX(UA_REC_VER) FROM USER_ACCESS WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID));
		UPDATE USER_ACCESS SET UA_JOIN=NULL,UA_TERMINATE='X',UA_REASON=REASON,UA_END_DATE=ENDDATE,UA_USERSTAMP=USERSTAMP WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID) AND UA_REC_VER=RECVER;
		SET SUCCESS_FLAG=1;		
	END IF;
	COMMIT;
END;
/*
CALL SP_TS_LOGIN_TERMINATE_SAVE('DEEPANAIDU25@MAIL.COM','2014-05-03','NEW USER','EXPATSINTEGRATED@GMAIL.COM',@SUCCESS_FLAG);
*/