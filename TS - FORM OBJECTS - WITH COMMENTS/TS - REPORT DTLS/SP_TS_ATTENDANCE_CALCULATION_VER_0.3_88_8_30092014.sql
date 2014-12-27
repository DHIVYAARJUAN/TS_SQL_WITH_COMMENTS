-- VERSION 0.3 TARTDATE:30/09/2014 ENDDATE:30/09/2014 ISSUE NO:88 COMMENT NO:8 DESC:DISPLAYED THE WEEKDAYS FOR THE DATES AND RETURN THE NO OF DAYS IN A MONTH. DONE BY :RAJA
-- VERSION 0.2 TARTDATE:27/09/2014 ENDDATE:29/09/2014 ISSUE NO:88 COMMENT NO:4 DESC:SHOWN ALL PERSENT,ABSENT,ONDUTY AND PERMISSION RECORD ON GIVEN MONTH FOR SINGLE USER. DONE BY :RAJA
-- VERSION 0.1 TARTDATE:25/09/2014 ENDDATE:26/09/2014 ISSUE NO:88 COMMENT NO:1 DESC:SP FOR CALCULATE PERSENT,ABSENT,ONDUTY AND PERMISSION. DONE BY :RAJA
DROP PROCEDURE IF EXISTS SP_TS_ATTENDANCE_CALCULATION;
CREATE PROCEDURE SP_TS_ATTENDANCE_CALCULATION(
IN MONTH_YEAR VARCHAR(20),
IN LOGIN_ID VARCHAR(50),
IN USERSTAMP VARCHAR(50),
OUT TEMP_ATTENDANCE_CALCULATION TEXT,
OUT TOTAL_DAYS INT,
OUT TOTAL_WORKINGDAYS INT)
BEGIN
	DECLARE SHORTMONTH VARCHAR(10);
	DECLARE MONTH_STARTDATE DATE;
	DECLARE MONTH_ENDDATE DATE;
	DECLARE TEMP_ATTENDANCECALCULATION TEXT;
	DECLARE USERSTAMP_ID INT(11);
	DECLARE ULDID INT(11);
	DECLARE I INT(2);
	DECLARE N INT(2);
	DECLARE T_PRESENT DECIMAL(3,1);
	DECLARE T_ABSENT DECIMAL(3,1);
	DECLARE T_ONDUTY DECIMAL(3,1);
	DECLARE T_PERMISSION DECIMAL(3,1);
	DECLARE TEMPATTENDANCE TEXT;
	DECLARE TEMP_ATTENDANCE TEXT;
	DECLARE TEMP_ATTENDANCECOUNT TEXT;
	DECLARE TEMP_ATTENDANCE_COUNT TEXT;
	DECLARE TEMP_USERSULDID TEXT;
	DECLARE TEMP_USERS_ULDID TEXT;
	DECLARE US_MIN_ID INT;
	DECLARE US_MAX_ID INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		IF(TEMP_ATTENDANCE_COUNT IS NOT NULL)THEN
			SET @DROP_TEMP_ATTENDANCE_COUNT = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE_COUNT));
			PREPARE DROP_TEMP_ATTENDANCE_COUNT_STMT FROM @DROP_TEMP_ATTENDANCE_COUNT;
			EXECUTE DROP_TEMP_ATTENDANCE_COUNT_STMT;
		END IF;
		IF(TEMP_ATTENDANCE IS NOT NULL)THEN
			SET @DROP_TEMP_ATTENDANCE = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE));
			PREPARE DROP_TEMP_ATTENDANCE_STMT FROM @DROP_TEMP_ATTENDANCE;
			EXECUTE DROP_TEMP_ATTENDANCE_STMT;
		END IF;
		IF(TEMP_USERS_ULDID IS NOT NULL)THEN
			SET @DROP_TEMP_USERS_ULDID = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_USERS_ULDID));
			PREPARE DROP_TEMP_USERS_ULDID_STMT FROM @DROP_TEMP_USERS_ULDID;
			EXECUTE DROP_TEMP_USERS_ULDID_STMT;
		END IF;
	END;
	START TRANSACTION;
	SET I=1;
	SET N=0;
	SET T_PRESENT=0;
	SET T_ABSENT=0;
	SET T_ONDUTY=0;
	SET T_PERMISSION=0;
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULD_ID);
	SET USERSTAMP_ID=@ULD_ID;
	IF(LOGIN_ID='')THEN
		SET LOGIN_ID=NULL;
	END IF;
  
	SET SHORTMONTH=(SELECT SUBSTRING(MONTH_YEAR,1,3));
	SET MONTH_STARTDATE=(SELECT CONCAT(SUBSTRING_INDEX(MONTH_YEAR,'-',-1),'-',(MONTH(STR_TO_DATE(SHORTMONTH,'%b'))),'-01'));
	SET MONTH_ENDDATE=(SELECT LAST_DAY(MONTH_STARTDATE));
	SET TOTAL_DAYS=(SELECT DAY(LAST_DAY(MONTH_STARTDATE)));
  SET TOTAL_WORKINGDAYS=TOTAL_DAYS;
	SELECT COUNT(ROW+1) AS SUNDAYS INTO @SUNDAYCOUNT FROM	(SELECT @ROW := @ROW + 1 AS ROW FROM 
	(SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) T1,
	(SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) T2, (SELECT @ROW:=-1) T3 LIMIT 31) B
	WHERE DATE_ADD(MONTH_STARTDATE, INTERVAL ROW DAY) BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE AND DAYOFWEEK(DATE_ADD(MONTH_STARTDATE, INTERVAL ROW DAY))=1;
	SET TOTAL_WORKINGDAYS=(TOTAL_WORKINGDAYS-@SUNDAYCOUNT);
	SET TOTAL_WORKINGDAYS=(TOTAL_WORKINGDAYS-(SELECT COUNT(*) FROM PUBLIC_HOLIDAY WHERE PH_DATE BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE));

	-- CALCULATE FOR SINGLE USER
	IF(LOGIN_ID IS NOT NULL)THEN
		CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(LOGIN_ID,@ULD_ID);
		SET ULDID=@ULD_ID;
		-- FOR TEMP TABLE FOR SINGLE ULDID
		SET TEMPATTENDANCE=(SELECT CONCAT('TEMP_ATTENDANCE',SYSDATE()));
		SET TEMPATTENDANCE=(SELECT REPLACE(TEMPATTENDANCE,':',''));
		SET TEMPATTENDANCE=(SELECT REPLACE(TEMPATTENDANCE,'-',''));
		SET TEMPATTENDANCE=(SELECT REPLACE(TEMPATTENDANCE,' ',''));
		SET TEMP_ATTENDANCE=(SELECT CONCAT(TEMPATTENDANCE,'_',USERSTAMP_ID));  
		SET @CREATE_TEMP_ATTENDANCE=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE,' (
		ID INT NOT NULL AUTO_INCREMENT,
		REPORT_DATE VARCHAR(20),
		PRESENT CHAR(20),
		ABSENT CHAR(20),
		ONDUTY CHAR(20),
		PERMISSION_HRS DECIMAL(3,1),
		PRIMARY KEY(ID))'));
		PREPARE CREATE_TEMP_ATTENDANCE_STMT FROM @CREATE_TEMP_ATTENDANCE;
		EXECUTE CREATE_TEMP_ATTENDANCE_STMT;
		-- FOR OUT TEMP TABLE FOR SINGLE ULDID
		SET TEMP_ATTENDANCECALCULATION=(SELECT CONCAT('TEMP_ATTENDANCE_CALCULATION',SYSDATE()));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,':',''));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,'-',''));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,' ',''));
		SET TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT(TEMP_ATTENDANCECALCULATION,'_',USERSTAMP_ID));  
		SET @CREATE_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE_CALCULATION,' (
		ID INT NOT NULL AUTO_INCREMENT,
		REPORT_DATE VARCHAR(20),
		PRESENT CHAR(20),
		ABSENT CHAR(20),
		ONDUTY CHAR(20),
		PERMISSION_HRS DECIMAL(3,1),
		PRIMARY KEY(ID))'));
		PREPARE CREATE_TEMP_ATTENDANCE_CALCULATION_STMT FROM @CREATE_TEMP_ATTENDANCE_CALCULATION;
		EXECUTE CREATE_TEMP_ATTENDANCE_CALCULATION_STMT;
		-- FOR TEMP TABLE
		SET TEMP_ATTENDANCECOUNT=(SELECT CONCAT('TEMP_ATTENDANCE_COUNT',SYSDATE()));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,':',''));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,'-',''));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,' ',''));
		SET TEMP_ATTENDANCE_COUNT=(SELECT CONCAT(TEMP_ATTENDANCECOUNT,'_',USERSTAMP_ID));    
		SET @CREATE_TEMP_ATTENDANCE_COUNT=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE_COUNT,' (
		ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		ULD_ID INT NOT NULL,
		PRESENT INT,
		ABSENT INT,
		ONDUTY INT,
		HALFDAY INT,
		HALFOD INT,
		PERMISSION INT)'));
		PREPARE CREATE_TEMP_ATTENDANCE_COUNT_STMT FROM @CREATE_TEMP_ATTENDANCE_COUNT;
		EXECUTE CREATE_TEMP_ATTENDANCE_COUNT_STMT;
		-- INSERT INTO TEMP TABLE
		SET @INSERT_TEMP_ATTENDANCE_COUNT=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE_COUNT,'(ULD_ID,PRESENT,ABSENT,ONDUTY,HALFDAY,HALFOD,PERMISSION) VALUES
		((',ULDID,'),(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=5),
		(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=6),
		(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=7),
		(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2)),
		(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=8 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2)),
		(SELECT COUNT(UARD_PERMISSION) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"','))'));
		PREPARE INSERT_TEMP_ATTENDANCE_COUNT_STMT FROM @INSERT_TEMP_ATTENDANCE_COUNT;
		EXECUTE INSERT_TEMP_ATTENDANCE_COUNT_STMT;

		SET @PRESENT_COUNT=(SELECT CONCAT('SELECT PRESENT,ABSENT,ONDUTY,HALFDAY,HALFOD,PERMISSION INTO @PRSNT,@ABSNT,@OD,@HALFDAYLEAVE,@HALFDAYOD,@PERMSN FROM ',TEMP_ATTENDANCE_COUNT));
		PREPARE PRESENT_COUNT_STMT FROM @PRESENT_COUNT;
		EXECUTE PRESENT_COUNT_STMT;    
		IF(@PRSNT!=0)THEN
			SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,PRESENT)  
			(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"X" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=5)'));
			PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
			EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
		END IF;
		IF(@ABSNT!=0)THEN
			SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,ABSENT)
			(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"X" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=6)'));
			PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
			EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
		END IF;
		IF(@OD!=0)THEN
			SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,ONDUTY)
			(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"X" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=7)'));
			PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
			EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
		END IF;
		IF(@HALFDAYLEAVE!=0)THEN
			WHILE(I<=@HALFDAYLEAVE)DO
				SET @AM_PM_ABSENT=(SELECT CONCAT('SELECT UARD_AM_SESSION,UARD_PM_SESSION INTO @AM,@PM FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2) LIMIT ',N,',1'));
				PREPARE AM_PM_ABSENT_STMT FROM @AM_PM_ABSENT;
				EXECUTE AM_PM_ABSENT_STMT;			
				IF(@AM=1 AND @PM=2)THEN
					SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,PRESENT,ABSENT)
					(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"MORNING PRESENT","AFTERNOON ABSENT" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2) LIMIT ',N,',1)'));
					PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
					EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
				ELSEIF(@AM=2 AND @PM=1)THEN
					SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,PRESENT,ABSENT)
					(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"AFTERNOON PRESENT","MORNING ABSENT" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2) LIMIT ',N,',1)'));
					PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
					EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
				END IF;
				SET N=N+1;
				SET I=I+1;
			END WHILE;
		END IF;
		SET N=0;
		SET I=1;
		IF(@HALFDAYOD!=0)THEN
			WHILE(I<=@HALFDAYOD)DO
				SET @AM_PM_ABSENT=(SELECT CONCAT('SELECT UARD_AM_SESSION,UARD_PM_SESSION INTO @AM_OD,@PM_OD FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=8 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2) LIMIT ',N,',1'));
				PREPARE AM_PM_ABSENT_STMT FROM @AM_PM_ABSENT;
				EXECUTE AM_PM_ABSENT_STMT;
				IF(@AM_OD=1 AND @PM_OD=2)THEN
					SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,PRESENT,ONDUTY)
					(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"MORNING PRESENT","AFTERNOON ONDUTY" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=8 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2) LIMIT ',N,',1)'));
					PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
					EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
				ELSEIF(@AM_OD=2 AND @PM_OD=1)THEN
					SET @INSERT_TEMP_ATTENDANCE=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE,'(REPORT_DATE,PRESENT,ONDUTY)
					(SELECT DATE_FORMAT(UARD_DATE,"%d-%m-%Y,%a"),"AFTERNOON PRESENT","MORNING ONDUTY" FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=8 AND UARD_AM_SESSION IN (1,2) AND UARD_PM_SESSION IN (1,2) LIMIT ',N,',1)'));
					PREPARE INSERT_TEMP_ATTENDANCE_STMT FROM @INSERT_TEMP_ATTENDANCE;
					EXECUTE INSERT_TEMP_ATTENDANCE_STMT;
				END IF;
				SET N=N+1;
				SET I=I+1;
			END WHILE;
		END IF;
		SET N=0;
		SET I=1;
		IF(@PERMSN!=0)THEN
			SET @UPDATE_TEMP_ATTENDANCE=(SELECT CONCAT('UPDATE ',TEMP_ATTENDANCE,' X 
			INNER JOIN (SELECT UARD.UARD_DATE,AC.AC_DATA FROM USER_ADMIN_REPORT_DETAILS UARD,ATTENDANCE_CONFIGURATION AC 
			WHERE UARD.ULD_ID=',ULDID,' AND UARD.UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' 
			AND UARD.UARD_PERMISSION IS NOT NULL AND UARD.UARD_PERMISSION=AC.AC_ID) Y ON X.REPORT_DATE=DATE_FORMAT(Y.UARD_DATE,"%d-%m-%Y,%a") SET X.PERMISSION_HRS=Y.AC_DATA'));
			PREPARE UPDATE_TEMP_ATTENDANCE_STMT FROM @UPDATE_TEMP_ATTENDANCE;
			EXECUTE UPDATE_TEMP_ATTENDANCE_STMT;
		END IF;

		-- INSERT INTO MAIN TEMP TABLE
		SET @INSERT_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE_CALCULATION,' (REPORT_DATE,PRESENT,ABSENT,ONDUTY,PERMISSION_HRS)
		SELECT REPORT_DATE,PRESENT,ABSENT,ONDUTY,PERMISSION_HRS FROM ',TEMP_ATTENDANCE,' ORDER BY REPORT_DATE'));
		PREPARE INSERT_TEMP_ATTENDANCE_CALCULATION_STMT FROM @INSERT_TEMP_ATTENDANCE_CALCULATION;
		EXECUTE INSERT_TEMP_ATTENDANCE_CALCULATION_STMT;
		SET @DROP_TEMP_ATTENDANCE = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE));
		PREPARE DROP_TEMP_ATTENDANCE_STMT FROM @DROP_TEMP_ATTENDANCE;
		EXECUTE DROP_TEMP_ATTENDANCE_STMT;
		SET @DROP_TEMP_ATTENDANCE_COUNT = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE_COUNT));
		PREPARE DROP_TEMP_ATTENDANCE_COUNT_STMT FROM @DROP_TEMP_ATTENDANCE_COUNT;
		EXECUTE DROP_TEMP_ATTENDANCE_COUNT_STMT;
	END IF;

	-- CALCULATE FOR ALL USERS
	IF (LOGIN_ID IS NULL) THEN
		-- FOR OUT TEMP TABLE FOR ALL
		SET TEMP_ATTENDANCECALCULATION=(SELECT CONCAT('TEMP_ATTENDANCE_CALCULATION',SYSDATE()));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,':',''));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,'-',''));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,' ',''));
		SET TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT(TEMP_ATTENDANCECALCULATION,'_',USERSTAMP_ID));  
		SET @CREATE_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE_CALCULATION,' (
		ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		LOGINID VARCHAR(50) NOT NULL,
		NO_OF_DAYS INTEGER NOT NULL,
		NO_OF_PRESENT DECIMAL(3,1) NOT NULL,
		NO_OF_ABSENT DECIMAL(3,1) NOT NULL,
		NO_OF_ONDUTY DECIMAL(3,1) NOT NULL,
		PERMISSION_HRS DECIMAL(3,1) NOT NULL)'));
		PREPARE CREATE_TEMP_ATTENDANCE_CALCULATION_STMT FROM @CREATE_TEMP_ATTENDANCE_CALCULATION;
		EXECUTE CREATE_TEMP_ATTENDANCE_CALCULATION_STMT;
		-- TEMP TABLE FOR ALL USERS
		SET TEMP_USERSULDID=(SELECT CONCAT('TEMP_USERS_ULDID',SYSDATE()));
		SET TEMP_USERSULDID=(SELECT REPLACE(TEMP_USERSULDID,':',''));
		SET TEMP_USERSULDID=(SELECT REPLACE(TEMP_USERSULDID,'-',''));
		SET TEMP_USERSULDID=(SELECT REPLACE(TEMP_USERSULDID,' ',''));
		SET TEMP_USERS_ULDID=(SELECT CONCAT(TEMP_USERSULDID,'_',USERSTAMP_ID));
		SET @CREATE_USERSULDID=(SELECT CONCAT('CREATE TABLE ',TEMP_USERS_ULDID,' (ID INT AUTO_INCREMENT PRIMARY KEY,ULD_ID INTEGER)'));
		PREPARE CREATE_USERSULDID_STMT FROM @CREATE_USERSULDID;
		EXECUTE CREATE_USERSULDID_STMT;
		SET @INSERT_USERSULDID=(SELECT CONCAT('INSERT INTO ',TEMP_USERS_ULDID,'(ULD_ID) SELECT DISTINCT ULD_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"'));
		PREPARE INSERT_USERSULDID_STMT FROM @INSERT_USERSULDID;
		EXECUTE INSERT_USERSULDID_STMT;
		SET @USMINID=(SELECT CONCAT('SELECT MIN(ID) INTO @USMIN_ID FROM ',TEMP_USERS_ULDID));
		PREPARE USMINID_STMT FROM @USMINID;
		EXECUTE USMINID_STMT;
		SET @USMAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @USMAX_ID FROM ',TEMP_USERS_ULDID)); 
		PREPARE USMAXID_STMT FROM @USMAXID;
		EXECUTE USMAXID_STMT;
		SET US_MIN_ID=@USMIN_ID;
		SET US_MAX_ID=@USMAX_ID;
		-- FOR TEMP TABLE
		SET TEMP_ATTENDANCECOUNT=(SELECT CONCAT('TEMP_ATTENDANCE_COUNT',SYSDATE()));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,':',''));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,'-',''));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,' ',''));
		SET TEMP_ATTENDANCE_COUNT=(SELECT CONCAT(TEMP_ATTENDANCECOUNT,'_',USERSTAMP_ID));    
		SET @CREATE_TEMP_ATTENDANCE_COUNT=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE_COUNT,' (
		ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		ULD_ID INT NOT NULL,
		PRESENT INT,
		ABSENT INT,
		ONDUTY INT,
		HALFDAY INT,
		HALFOD INT,
		PERMISSION INT)'));
		PREPARE CREATE_TEMP_ATTENDANCE_COUNT_STMT FROM @CREATE_TEMP_ATTENDANCE_COUNT;
		EXECUTE CREATE_TEMP_ATTENDANCE_COUNT_STMT;

		WHILE(US_MIN_ID<=US_MAX_ID)DO
			SET @SELECT_USER_ULDID = (SELECT CONCAT('SELECT ULD_ID INTO @UID FROM ',TEMP_USERS_ULDID,' WHERE ID=',US_MIN_ID));
			PREPARE SELECT_USER_ULDID_STMT FROM @SELECT_USER_ULDID;
			EXECUTE SELECT_USER_ULDID_STMT;
			SET @SELECT_LOGINID_ULDID = (SELECT CONCAT('SELECT ULD_ID,ULD_LOGINID INTO @U_ID,@LOGID FROM USER_LOGIN_DETAILS WHERE ULD_ID=@UID'));
			PREPARE SELECT_LOGINID_ULDID_STMT FROM @SELECT_LOGINID_ULDID;
			EXECUTE SELECT_LOGINID_ULDID_STMT;
			SET ULDID=@U_ID;
			SET LOGIN_ID=@LOGID;
			-- INSERT INTO TEMP TABLE
			SET @INSERT_TEMP_ATTENDANCE_COUNT=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE_COUNT,'(ULD_ID,PRESENT,ABSENT,ONDUTY,HALFDAY,HALFOD,PERMISSION) VALUES
			((',ULDID,'),(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=5),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=6),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=7),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=8),
			(SELECT COUNT(UARD_PERMISSION) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"','))'));
			PREPARE INSERT_TEMP_ATTENDANCE_COUNT_STMT FROM @INSERT_TEMP_ATTENDANCE_COUNT;
			EXECUTE INSERT_TEMP_ATTENDANCE_COUNT_STMT;

			SET @PRESENT_COUNT=(SELECT CONCAT('SELECT PRESENT,ABSENT,ONDUTY,HALFDAY,HALFOD,PERMISSION INTO @PRSNT,@ABSNT,@OD,@HALFDAYLEAVE,@HALFDAYOD,@PERMSN FROM ',TEMP_ATTENDANCE_COUNT));
			PREPARE PRESENT_COUNT_STMT FROM @PRESENT_COUNT;
			EXECUTE PRESENT_COUNT_STMT;
			SET T_PRESENT=@PRSNT;
			SET T_ABSENT=@ABSNT;
			SET T_ONDUTY=@OD;
			IF(@HALFDAYLEAVE!=0)THEN
				WHILE(I<=@HALFDAYLEAVE)DO
					SET T_PRESENT=(SELECT SUM(T_PRESENT+0.5));
					SET T_ABSENT=(SELECT SUM(T_ABSENT+0.5));
					SET I=I+1;
				END WHILE;
			END IF;
			SET I=1;
			IF(@HALFDAYOD!=0)THEN
				WHILE(I<=@HALFDAYOD)DO
					SET T_PRESENT=(SELECT SUM(T_PRESENT+0.5));
					SET T_ONDUTY=(SELECT SUM(T_ONDUTY+0.5));
					SET I=I+1;
				END WHILE;
			END IF;
			SET I=1;
			IF(@PERMSN=0)THEN
				SET T_PERMISSION=@PERMSN;
			ELSE
				SET @TOTAL_PERMISSION=(SELECT CONCAT('SELECT SUM(AC.AC_DATA) INTO @TOTALPERMSN FROM USER_ADMIN_REPORT_DETAILS UARD,ATTENDANCE_CONFIGURATION AC 
				WHERE UARD.ULD_ID=',ULDID,' AND UARD.UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD.UARD_PERMISSION IS NOT NULL AND UARD.UARD_PERMISSION=AC.AC_ID'));
				PREPARE TOTAL_PERMISSION_STMT FROM @TOTAL_PERMISSION;
				EXECUTE TOTAL_PERMISSION_STMT;
				SET T_PERMISSION=@TOTALPERMSN;
			END IF;
		  
			-- INSERT INTO MAIN TEMP TABLE
			SET @INSERT_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE_CALCULATION,'(LOGINID,NO_OF_DAYS,NO_OF_PRESENT,NO_OF_ABSENT,NO_OF_ONDUTY,PERMISSION_HRS) VALUES
			(','"',LOGIN_ID,'"',',',TOTAL_WORKINGDAYS,',',T_PRESENT,',',T_ABSENT,',',T_ONDUTY,',',T_PERMISSION,')'));
			PREPARE INSERT_TEMP_ATTENDANCE_CALCULATION_STMT FROM @INSERT_TEMP_ATTENDANCE_CALCULATION;
			EXECUTE INSERT_TEMP_ATTENDANCE_CALCULATION_STMT;
			SET @TRUNC_TEMP_USERS_ULDID = (SELECT CONCAT('TRUNCATE TABLE ',TEMP_ATTENDANCE_COUNT));
			PREPARE TRUNC_TEMP_USERS_ULDID_STMT FROM @TRUNC_TEMP_USERS_ULDID;
			EXECUTE TRUNC_TEMP_USERS_ULDID_STMT;
			SET US_MIN_ID=US_MIN_ID+1;
		END WHILE;
		SET TOTAL_WORKINGDAYS=NULL;
		SET @DROP_TEMP_ATTENDANCE_COUNT = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE_COUNT));
		PREPARE DROP_TEMP_ATTENDANCE_COUNT_STMT FROM @DROP_TEMP_ATTENDANCE_COUNT;
		EXECUTE DROP_TEMP_ATTENDANCE_COUNT_STMT;
		SET @DROP_TEMP_USERS_ULDID = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_USERS_ULDID));
		PREPARE DROP_TEMP_USERS_ULDID_STMT FROM @DROP_TEMP_USERS_ULDID;
		EXECUTE DROP_TEMP_USERS_ULDID_STMT;
	END IF;
	COMMIT;
END;
/*
CALL SP_TS_ATTENDANCE_CALCULATION('JULY-2014','','dhandapani.sattanathan@ssomens.com',@TEMP_ATTENDANCE_CALCULATION,@TOTAL_DAYS,@TOTAL_WORKINGDAYS);
SELECT @TOTAL_DAYS,@TOTAL_WORKINGDAYS;
*/