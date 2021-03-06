-- VER 0.2 ISSUE NO:88 COMMENT:16 STARTDATE:15/10/2014 ENDDATE:16/10/2014 DESC:ADDED 2 INPUT FOR SHOWING NO OF PROJECT COUNT & NO OF DAYS WORKED DONE BY:DHIVYA
-- version 0.1 startdate:04/10/2014 enddate:06/10/2014 ISSUE:88 CMT:12 DESC:SP FOR SHOWING DATE,ON THAT DATE WHICH PROJECT USER WORKED DONE BY:DHIVYA

DROP PROCEDURE IF EXISTS SP_PROJECT_REVENUE_BY_EMPLOYEE; 
CREATE PROCEDURE SP_PROJECT_REVENUE_BY_EMPLOYEE(USERNAME VARCHAR(40),USERSTAMP VARCHAR(50),OUT TEMP_PROJECT_EMPLOYEE_REVENUE TEXT,OUT NO_OF_PROJECT INTEGER,OUT NO_OF_DAYS_WORKED INTEGER) 
BEGIN
-- VARIABLE DECLARATION
DECLARE ULDID INTEGER;
DECLARE USERSTAMP_ID INTEGER;
DECLARE PROJECTREVENUE TEXT;
DECLARE MINID INTEGER;
DECLARE MAXID INTEGER;
DECLARE MIN_TEMPID INTEGER;
DECLARE MAX_TEMPID INTEGER;
DECLARE TEMPPROJECT TEXT;
DECLARE TEMP_PROJECT TEXT;
DECLARE PROJECT_ID TEXT;
DECLARE PROJECT_MINID INTEGER;
DECLARE PROJECT_MAXID INTEGER;
DECLARE CHECK_COUNT INTEGER;

-- ROLLBACK STATEMENT
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
SET AUTOCOMMIT=0;
START TRANSACTION;
SET ULDID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=USERNAME);
CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET NO_OF_PROJECT=0;
SET PROJECTREVENUE=(SELECT CONCAT('TEMP_PROJECT_EMPLOYEE_REVENUE','_',SYSDATE()));
SET PROJECTREVENUE=(SELECT REPLACE(PROJECTREVENUE,' ',''));
SET PROJECTREVENUE=(SELECT REPLACE(PROJECTREVENUE,'-',''));
SET PROJECTREVENUE=(SELECT REPLACE(PROJECTREVENUE,':',''));
SET TEMP_PROJECT_EMPLOYEE_REVENUE=(SELECT CONCAT(PROJECTREVENUE,'_',USERSTAMP_ID));
-- DROP QUERY FOR TEMP_TABLE
SET @DROP_QUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_PROJECT_EMPLOYEE_REVENUE));
PREPARE DROP_QUERY_STMT FROM @DROP_QUERY;
EXECUTE DROP_QUERY_STMT;
DEALLOCATE PREPARE DROP_QUERY_STMT;

-- CREATE QUERY FOR TEMP TABLE
SET @CREATE_QUERY=(SELECT CONCAT('CREATE TABLE ',TEMP_PROJECT_EMPLOYEE_REVENUE,'(ID INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,PROJECT_DATE DATE,PROJECT_NAME TEXT)'));
PREPARE CREATE_QUERY_STMT FROM @CREATE_QUERY;
EXECUTE CREATE_QUERY_STMT;

-- INSERT QUERY FOR INSERTING PROJECT DATE FOR EACH DATE
SET @INSERT_QUERY=(SELECT CONCAT('INSERT INTO ',TEMP_PROJECT_EMPLOYEE_REVENUE,'(PROJECT_DATE) SELECT UARD_DATE FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_PDID IS NOT NULL AND ULD_ID=',ULDID));
PREPARE INSERT_QUERY_STMT FROM @INSERT_QUERY;
EXECUTE INSERT_QUERY_STMT;

-- GETTING MINID FOR THE TEMP_TABLE
SET @SET_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',TEMP_PROJECT_EMPLOYEE_REVENUE));
PREPARE SET_MINID_STMT FROM @SET_MINID;
EXECUTE SET_MINID_STMT;
DEALLOCATE PREPARE SET_MINID_STMT;
SET MINID=@MIN_ID;

-- GETTING MAXID FOR THE TEMP_TABLE
SET @SET_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',TEMP_PROJECT_EMPLOYEE_REVENUE));
PREPARE SET_MAXID_STMT FROM @SET_MAXID;
EXECUTE SET_MAXID_STMT;
DEALLOCATE PREPARE SET_MAXID_STMT;
SET MAXID=@MAX_ID;
	WHILE MINID<=MAXID DO
		-- GETTING PROJECT DATE FOR EACH ID
		SET @SET_UARD_DATE=(SELECT CONCAT('SELECT PROJECT_DATE INTO @PROJECTDATE FROM ',TEMP_PROJECT_EMPLOYEE_REVENUE,' WHERE ID=',MINID));
		PREPARE SET_UARD_DATE_STMT FROM @SET_UARD_DATE;
		EXECUTE SET_UARD_DATE_STMT;
		-- GETTING PD_ID FOR THE PROJECT_DATE
		SET @SET_PDID=(SELECT CONCAT('SELECT UARD_PDID INTO @PDID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_DATE=@PROJECTDATE AND ULD_ID=',ULDID));
		PREPARE SET_PDID_STMT FROM @SET_PDID;
		EXECUTE SET_PDID_STMT;
		SET PROJECT_ID=@PDID;
		-- UPDATE QUERY FOR UPDATING PROJECT NAME IN TEMP TABLE
		SET @UPDATE_PROJECT_NAME=(SELECT CONCAT('UPDATE ',TEMP_PROJECT_EMPLOYEE_REVENUE,' SET PROJECT_NAME=','(SELECT GROUP_CONCAT(PD_PROJECT_NAME) FROM PROJECT_DETAILS WHERE PD_ID IN (',PROJECT_ID,')) WHERE ID=',MINID));
		PREPARE UPDATE_PROJECT_NAME_STMT FROM @UPDATE_PROJECT_NAME;
		EXECUTE UPDATE_PROJECT_NAME_STMT;
		SET @PDID=NULL;
		SET MINID=MINID+1;
	END WHILE;
	SET PROJECT_MINID=(SELECT MIN(PD_ID) FROM PROJECT_DETAILS);
	SET PROJECT_MAXID=(SELECT MAX(PD_ID) FROM PROJECT_DETAILS);
	WHILE PROJECT_MINID<=PROJECT_MAXID DO 
		SET @SET_PROJECT_COUNT=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT FROM USER_ADMIN_REPORT_DETAILS WHERE ((UARD_PDID LIKE ','"','%,',PROJECT_MINID,',%','"',') OR (UARD_PDID LIKE ','"','%,',PROJECT_MINID,'"',') OR (UARD_PDID=',PROJECT_MINID,')) AND ULD_ID=',ULDID));
		PREPARE SET_PROJECT_COUNT_STMT FROM @SET_PROJECT_COUNT;
		EXECUTE SET_PROJECT_COUNT_STMT;
		SET CHECK_COUNT=@COUNT;
		IF CHECK_COUNT>0 THEN
			SET NO_OF_PROJECT=NO_OF_PROJECT+1;
		END IF;
		SET PROJECT_MINID=PROJECT_MINID+1;
	END WHILE;
	SET NO_OF_DAYS_WORKED=(SELECT COUNT(*) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=ULDID AND UARD_PDID IS NOT NULL);
COMMIT;
END;
/*call SP_PROJECT_REVENUE_BY_EMPLOYEE('dhivya.arjunan@ssomens.com','dhivya.arjunan@ssomens.com',@TEMP_PROJECT_EMPLOYEE_REVENUE,@NO_OF_PROJECT,@NO_OF_DAYS_WORKED);
select @TEMP_PROJECT_EMPLOYEE_REVENUE,@NO_OF_PROJECT,@NO_OF_DAYS_WORKED;
