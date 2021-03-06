-- VERSION:0.2 --SDATE:25/09/2014 --EDATE:25/09/2014 --ISSUE:84 --COMMENTNO#18 --DESC:MOBILRNO HEADER CHANGED --DONE BY:RL
-- VERSION:0.1 --SDATE:05/09/2014 --EDATE:05/09/2014 --ISSUE:84 --COMMENTNO:1 --DESC:TRIGGERS TO UPDATE OLD & NEW VALUE IN TICKLER HISTORY TABLE DONE BY RL

DROP TRIGGER IF EXISTS TRG_TS_EMPLOYEE_DETAILS_UPDATE;
CREATE TRIGGER TRG_TS_EMPLOYEE_DETAILS_UPDATE  
AFTER UPDATE ON EMPLOYEE_DETAILS
FOR EACH ROW
BEGIN 
	
	DECLARE OLD_VALUE TEXT DEFAULT '';
	DECLARE NEW_VALUE TEXT DEFAULT '';
	
	IF ((OLD.EMP_ID!= NEW.EMP_ID) OR (OLD.ULD_ID!= NEW.ULD_ID) OR (OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) OR
		(OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) OR (OLD.EMP_DOB!= NEW.EMP_DOB) OR (OLD.EMP_DESIGNATION!= NEW.EMP_DESIGNATION) OR 
		(OLD.EMP_MOBILE_NUMBER  != NEW.EMP_MOBILE_NUMBER  ) OR (OLD.EMP_NEXT_KIN_NAME!= NEW.EMP_NEXT_KIN_NAME) OR
		(OLD.EMP_RELATIONHOOD IS NULL AND NEW.EMP_RELATIONHOOD IS NOT NULL) OR (OLD.EMP_RELATIONHOOD IS NOT NULL AND NEW.EMP_RELATIONHOOD IS NULL) OR (OLD.EMP_RELATIONHOOD!= NEW.EMP_RELATIONHOOD) OR
		(OLD.EMP_ALT_MOBILE_NO IS NULL AND NEW.EMP_ALT_MOBILE_NO IS NOT NULL) OR (OLD.EMP_ALT_MOBILE_NO IS NOT NULL AND NEW.EMP_ALT_MOBILE_NO IS NULL) OR (OLD.EMP_ALT_MOBILE_NO!= NEW.EMP_ALT_MOBILE_NO)) THEN
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_ID=', OLD.EMP_ID,','); 
	END IF;
	
	IF (OLD.ULD_ID!= NEW.ULD_ID) THEN 
		SET OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
	END IF;
	IF (OLD.ULD_ID!= NEW.ULD_ID) THEN   
		SET NEW_VALUE = CONCAT(NEW_VALUE,'ULD_ID=', NEW.ULD_ID,','); 
	END IF;
	
	IF (OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) THEN  
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_FIRST_NAME=', OLD.EMP_FIRST_NAME,','); 
	END IF;
	IF (OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) THEN  
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_FIRST_NAME=', NEW.EMP_FIRST_NAME,','); 
	END IF;
	
	IF (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) THEN 
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_LAST_NAME=', OLD.EMP_LAST_NAME,','); 
	END IF;
	IF (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) THEN   
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_LAST_NAME=', NEW.EMP_LAST_NAME,','); 
	END IF;
	
	IF (OLD.EMP_DOB!= NEW.EMP_DOB) THEN  
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_DOB=', OLD.EMP_DOB,','); 
	END IF;
	IF (OLD.EMP_DOB!= NEW.EMP_DOB) THEN  
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_DOB=', NEW.EMP_DOB,','); 
	END IF;
	
	IF (OLD.EMP_DESIGNATION!= NEW.EMP_DESIGNATION) THEN  
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_DESIGNATION=', OLD.EMP_DESIGNATION,','); 
	END IF;
	IF (OLD.EMP_DESIGNATION!= NEW.EMP_DESIGNATION) THEN  
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_DESIGNATION=', NEW.EMP_DESIGNATION,','); 
	END IF;
	
	IF (OLD.EMP_MOBILE_NUMBER  != NEW.EMP_MOBILE_NUMBER  ) THEN 
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_MOBILE_NUMBER  =', OLD.EMP_MOBILE_NUMBER  ,','); 
	END IF;
	IF (OLD.EMP_MOBILE_NUMBER  != NEW.EMP_MOBILE_NUMBER  ) THEN   
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_MOBILE_NUMBER  =', NEW.EMP_MOBILE_NUMBER  ,','); 
	END IF;
	
	IF (OLD.EMP_NEXT_KIN_NAME!= NEW.EMP_NEXT_KIN_NAME) THEN  
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_NEXT_KIN_NAME=', OLD.EMP_NEXT_KIN_NAME,','); 
	END IF;
	IF (OLD.EMP_NEXT_KIN_NAME!= NEW.EMP_NEXT_KIN_NAME) THEN  
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_NEXT_KIN_NAME=', NEW.EMP_NEXT_KIN_NAME,','); 
	END IF;
	
	IF (OLD.EMP_RELATIONHOOD IS NULL AND NEW.EMP_RELATIONHOOD IS NOT NULL) THEN
		SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_RELATIONHOOD=','<NULL>,');
		SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_RELATIONHOOD=',NEW.EMP_RELATIONHOOD,',');
	ELSEIF(OLD.EMP_RELATIONHOOD IS NOT NULL AND NEW.EMP_RELATIONHOOD IS NULL) THEN
		SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_RELATIONHOOD=',OLD.EMP_RELATIONHOOD,',');
		SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_RELATIONHOOD=','<NULL>,');
	ELSEIF (OLD.EMP_RELATIONHOOD!= NEW.EMP_RELATIONHOOD) THEN 
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_RELATIONHOOD=', OLD.EMP_RELATIONHOOD,','); 
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_RELATIONHOOD=', NEW.EMP_RELATIONHOOD,','); 
	END IF;
	
	IF (OLD.EMP_ALT_MOBILE_NO IS NULL AND NEW.EMP_ALT_MOBILE_NO IS NOT NULL) THEN
		SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_ALT_MOBILE_NO=','<NULL>,');
		SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_ALT_MOBILE_NO=',NEW.EMP_ALT_MOBILE_NO,',');
	ELSEIF(OLD.EMP_ALT_MOBILE_NO IS NOT NULL AND NEW.EMP_ALT_MOBILE_NO IS NULL) THEN
		SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_ALT_MOBILE_NO=',OLD.EMP_ALT_MOBILE_NO,',');
		SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_ALT_MOBILE_NO=','<NULL>,');
	ELSEIF (OLD.EMP_ALT_MOBILE_NO!= NEW.EMP_ALT_MOBILE_NO) THEN 
		SET OLD_VALUE = CONCAT(OLD_VALUE,'EMP_ALT_MOBILE_NO=', OLD.EMP_ALT_MOBILE_NO,','); 
		SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_ALT_MOBILE_NO=', NEW.EMP_ALT_MOBILE_NO,','); 
	END IF;
	
	IF ((OLD.EMP_ID!= NEW.EMP_ID) OR (OLD.ULD_ID!= NEW.ULD_ID) OR (OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) OR
		(OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) OR (OLD.EMP_DOB!= NEW.EMP_DOB) OR (OLD.EMP_DESIGNATION!= NEW.EMP_DESIGNATION) OR 
		(OLD.EMP_MOBILE_NUMBER  != NEW.EMP_MOBILE_NUMBER  ) OR (OLD.EMP_NEXT_KIN_NAME!= NEW.EMP_NEXT_KIN_NAME) OR
		(OLD.EMP_RELATIONHOOD IS NULL AND NEW.EMP_RELATIONHOOD IS NOT NULL) OR (OLD.EMP_RELATIONHOOD IS NOT NULL AND NEW.EMP_RELATIONHOOD IS NULL) OR (OLD.EMP_RELATIONHOOD!= NEW.EMP_RELATIONHOOD) OR
		(OLD.EMP_ALT_MOBILE_NO IS NULL AND NEW.EMP_ALT_MOBILE_NO IS NOT NULL) OR (OLD.EMP_ALT_MOBILE_NO IS NOT NULL AND NEW.EMP_ALT_MOBILE_NO IS NULL) OR (OLD.EMP_ALT_MOBILE_NO!= NEW.EMP_ALT_MOBILE_NO)) THEN
		IF (OLD.EMP_USERSTAMP_ID!= NEW.EMP_USERSTAMP_ID) THEN SET 
			OLD_VALUE = CONCAT(OLD_VALUE,'EMP_USERSTAMP_ID=', OLD.EMP_USERSTAMP_ID,','); 
		END IF;
		IF (OLD.EMP_TIMESTAMP!= NEW.EMP_TIMESTAMP) THEN SET 
			OLD_VALUE = CONCAT(OLD_VALUE,'EMP_TIMESTAMP=', OLD.EMP_TIMESTAMP,','); 
		END IF;
	END IF;
	
	IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
		IF(OLD_VALUE!=NEW_VALUE)THEN
			SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
			SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
			INSERT INTO TICKLER_HISTORY(TP_ID,ULD_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,TH_USERSTAMP_ID)VALUES
			((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
			(SELECT ULD_ID FROM EMPLOYEE_DETAILS WHERE ULD_ID=NEW.ULD_ID AND EMP_ID=NEW.EMP_ID),
			(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EMPLOYEE_DETAILS'),OLD_VALUE,NEW_VALUE,
			(SELECT EMP_USERSTAMP_ID FROM EMPLOYEE_DETAILS WHERE EMP_ID=NEW.EMP_ID));
		END IF;
	END IF;
END;