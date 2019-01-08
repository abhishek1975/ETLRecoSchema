-- MySQL dump 10.13  Distrib 8.0.13, for Win64 (x86_64)
--
-- Host: localhost    Database: reco
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'reco'
--
/*!50003 DROP FUNCTION IF EXISTS `levenshtein` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` FUNCTION `levenshtein`( s1 text, s2 text) RETURNS int(11)
    DETERMINISTIC
BEGIN 
    DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT; 
    DECLARE s1_char CHAR; 
    DECLARE cv0, cv1 text; 
    SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0; 
    IF s1 = s2 THEN 
      RETURN 0; 
    ELSEIF s1_len = 0 THEN 
      RETURN s2_len; 
    ELSEIF s2_len = 0 THEN 
      RETURN s1_len; 
    ELSE 
      WHILE j <= s2_len DO 
        SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1; 
      END WHILE; 
      WHILE i <= s1_len DO 
        SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = UNHEX(HEX(i)), j = 1; 
        WHILE j <= s2_len DO 
          SET c = c + 1; 
          IF s1_char = SUBSTRING(s2, j, 1) THEN  
            SET cost = 0; ELSE SET cost = 1; 
          END IF; 
          SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost; 
          IF c > c_temp THEN SET c = c_temp; END IF; 
            SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1; 
            IF c > c_temp THEN  
              SET c = c_temp;  
            END IF; 
            SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1; 
        END WHILE; 
        SET cv1 = cv0, i = i + 1; 
      END WHILE; 
    END IF; 
    RETURN c; 
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `levenshtein_ratio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` FUNCTION `levenshtein_ratio`(`s1` VARCHAR(255) CHARACTER SET utf8, `s2` VARCHAR(255) CHARACTER SET utf8) RETURNS tinyint(3) unsigned
    NO SQL
    DETERMINISTIC
    COMMENT 'Levenshtein ratio between strings'
BEGIN
    DECLARE s1_len TINYINT UNSIGNED DEFAULT CHAR_LENGTH(s1);
    DECLARE s2_len TINYINT UNSIGNED DEFAULT CHAR_LENGTH(s2);
    RETURN ((levenshtein(s1, s2) / IF(s1_len > s2_len, s1_len, s2_len)) * 100);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `soundex_match` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` FUNCTION `soundex_match`(
   needle varchar(128), haystack text, splitChar varchar(1)) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
     declare spacePos int;
     declare searchLen int default 0;
     declare curWord varchar(128) default '';
     declare tempStr text default haystack;
     declare tmp text default '';
     declare soundx1 varchar(64) default '';
     declare soundx2 varchar(64) default '';    

    set searchLen = length(haystack);
     set spacePos  = locate(splitChar, tempStr);
     set soundx1   = soundex(needle);

    while searchLen > 0 do
       if spacePos = 0 then
         set tmp = tempStr;
         select soundex(tmp) into soundx2;
         if soundx1 = soundx2 then
           return 1;
         else
           return 0;
         end if;
       else
         set tmp = substr(tempStr, 1, spacePos-1);
         set soundx2 = soundex(tmp);
         if soundx1 = soundx2 then
           return 1;
         end if;

        set tempStr = substr(tempStr, spacePos+1);
         set searchLen = length(tempStr);
       end if;      

      set spacePos = locate(splitChar, tempStr);
     end while;  

    return 0;
 END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `soundex_match_all` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` FUNCTION `soundex_match_all`(needle varchar(128), haystack text, splitChar varchar(1)) RETURNS tinyint(4)
BEGIN
     /* find the first instance of the splitting character */ 
     DECLARE comma  INT  DEFAULT 0;  
     DECLARE word   TEXT; 

    SET comma = LOCATE(splitChar, needle);
     SET word = TRIM(needle);

    if LENGTH(haystack) = 0 then
         return 0;
     elseif comma = 0 then 
         /* one word search term */ 
         return soundex_match(word, haystack, splitChar);
     end if;

    SET word = trim(substr(needle, 1, comma));

    /* Insert each split variable into the word variable */ 
     REPEAT
         if soundex_match(word, haystack, splitChar) = 0 then 
             return 0;
         end if;

        /* get the next word */
         SET needle = trim(substr(needle, comma));
         SET comma  = LOCATE(splitChar, needle); 
         if comma = 0 then 
             /* last word */
             return soundex_match(needle, haystack, splitChar);
         end if;

        SET word = trim(substr(needle, 1, comma));
     UNTIL length(word) = 0
     END REPEAT; 

    return 0; 
 END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC12_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC12_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN
DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
    INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'Error occurred in generation of Derived Columns. Error:' + @error_string ;

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
	-- derive multiple dataset. Example:WITHDRAWAL TRANSFER--TRANSFER TO 54018777714                           T V S MOTOR COMPANY LT-
    -- extract: DC3=VENDOR NAME, DC12=Account number
	update t_intrecords 
	set derivedCol_12= case when referenceText_11 like '%TRANSFER TO%' THEN substring_index( substring_index(referenceText_11, 'TRANSFER TO ', -1),' ', 1) end ,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where referenceText_11 like 'WITHDRAWAL TRANSFER%'
		and jobId = vJobId
		and relationshipId = vRelationshipId
		and processingStatus = vProcessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC12_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
  
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	COMMIT;
    
 	--
    
    update t_intrecords 
	set derivedCol_12= substring_index( substring_index(referenceText_11, 'SWEEP FROM ', -1),'-', 1) ,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where referenceText_11 LIKE '%SWEEP FROM%'
		and jobId = vJobId
		and relationshipId = vRelationshipId
		and processingStatus = vProcessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC12_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
  
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	COMMIT;
    
    
    
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN

DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
    update reco.t_intrecords
	set derivedCol_1 = referenceText_11,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 REGEXP  '^[0-9]*$'
		and length(referenceText_11) <=7
		and processingStatus = vprocessingStatus
        and jobId=vJobId
        and relationshipId=vrelationshipId
        and isDeleted='N';            
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 
 
	-- DATA: CHEQUE DEPOSIT--TRANSFER TO 34020627015--885054
    -- DATA: CHEQUE DEPOSIT--196343 -SARRADA MOTORS-ZTS9 10260

	update reco.t_intrecords
	set derivedCol_1 = REGEXP_SUBSTR(referenceText_11, '[0-9]{6}'),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 REGEXP  '[0-9]{6}'
        and referenceText_11 like '%CHEQUE DEPOSIT%'
		and processingStatus = vprocessingStatus
        and jobId=vJobId
        and relationshipId=vrelationshipId
        and isDeleted='N';            
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC1_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- 
    

	update reco.t_intrecords
	set derivedCol_1 = referenceText_5,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_5 REGEXP  '^[0-9]*$'
		and length(referenceText_5) <=8
		and processingStatus = vprocessingStatus
        and jobId=vJobId
        and relationshipId=vrelationshipId
        and isDeleted='N';            
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC1_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	
	update reco.t_intrecords
	set derivedCol_1 = referenceText_9,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_9 REGEXP  '^[0-9]*$'
		and length(referenceText_9) < 7		--  length of a cheque number
		and processingStatus = vprocessingStatus
		and jobId=vJobId
		and relationshipId=vrelationshipId
		and isDeleted='N';            
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC1_4 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- Check if Cheque number is present in any of the ERP String.
	drop temporary table if exists temp_group_dc_1;    
	create temporary table temp_group_dc_1   
	select q1.intrecordsid, q2.extrecordsId, q2.derivedCol_1 BankCheque , q1.ReferenceText ERPCheque, 
    q2.BankAmount, q1.ERPAmount 
	from
	(
		select intrecordsid, referenceText_11 as ReferenceText, debitAmount, creditAmount, amount_1 as ERPAmount
		from t_intrecords 
		where  (referenceText_11 like '%CHEQUE%')
			and jobid= vJobId              
			and relationshipid= vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
		union 
		select intrecordsid, referenceText_5 as ReferenceText, debitAmount, creditAmount, amount_1 as ERPAmount
		from t_intrecords 
		where (referenceText_5 regexp  '^[0-9]*$' and length(referenceText_5) <=7) 
			and jobid= vJobId             
			and relationshipid= vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		union 
		select intrecordsid, referenceText_11 as ReferenceText, debitAmount, creditAmount, amount_1 as ERPAmount
		from t_intrecords 
		where referenceText_11  regexp  '[0-9]{6}$'
			and jobid= vJobId             
			and relationshipid= vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
	) q1 
	inner join 
	(
		select extRecordsId, derivedCol_1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount, count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_1)
		where 
			(derivedCol_1 regexp  '[0-9]{6}$')               
			and jobid= vJobId
			and relationshipid= vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by extRecordsId,derivedCol_1	
        having count(*) =1
	) q2 
	on instr(q1.ReferenceText, q2.derivedCol_1) >0   -- Check if cheque number is mentioned in the ERP Text
    and q1.ERPAmount = q2.BankAmount;
	     
    update t_intrecords i
		inner join temp_group_dc_1 t 
			on t.intrecordsid = i.intrecordsid
    set i.derivedCol_1 = t.BankCheque
	where jobid= vJobId
		and relationshipid= vRelationshipid
		and processingStatus in ('New', 'Open') 
		and isDeleted='N';
		
     
    SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC1_5 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	 drop temporary table if exists temp_group_dc_1;      
 
 	COMMIT;
	SET vReturn = 1;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC2_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC2_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN
DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
    
    -- PATTERN : 1    
    --  DATA: BY TRANSFER-NEFT*P18071075380521*10246AZTS9*NELLAI
	-- 	DATA: BY TRANSFER-NEFT*UTIB0002470*AXSC182080883147**CYB
    -- 	DC2=UTR, DC11=UNIQCODE, DC10=IFSC CODE
	update t_intrecords 
	set derivedCol_2 = 
		CASE 
			when length(REGEXP_SUBSTR(referenceText_11, '[A-Z]{4}[0-9]{12}'))>0 then REGEXP_SUBSTR(referenceText_11, '[A-Z]{4}[0-9]{12}')
			when length(REGEXP_SUBSTR(referenceText_11, '[A-Z]{5}[0-9]{11}'))>0 then REGEXP_SUBSTR(referenceText_11, '[A-Z]{5}[0-9]{11}')
		end,
		derivedCol_10=REGEXP_SUBSTR(referenceText_11, '[A-Z]{4}00[0-9]{5}'),
		derivedCol_11=REGEXP_SUBSTR(referenceText_11, '[0-9]{5}[A-Z]{4}[0-9]{1}'),    
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 like 'BY TRANSFER-NEFT%'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 
	-- PATTERN:2 
	--  DATA: NOSCR52018071800041747
    -- 	DC2=UTR 
	update t_intrecords 
	set derivedCol_2 = REGEXP_SUBSTR(referenceText_11, '[A-Z]{5}[0-9]*$'),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 regexp '^[A-Z]{5}[0-9].'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- PATTERN:3
    -- DATA: ICICR22018072600577661
 	update t_intrecords 
	set derivedCol_2 = REGEXP_SUBSTR(referenceText_3, '[A-Z]{5}[0-9]*$'),			
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_3 regexp '^[A-Z]{5}[0-9].'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- PATTERN:4
	-- DATA: PUNBR5201807211271
    -- DATA: BKIDN1820546074
    update t_intrecords 
	set derivedCol_2 = REGEXP_SUBSTR(referenceText_4, '[A-Z]{5}[0-9]*$'),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where  referenceText_4 regexp '^[A-Z]{5}[0-9].'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_4 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- PATTERN: 5
	-- DATA: SIBLN18206177184
    
	update t_intrecords 
	set derivedCol_2 = referenceText_5,
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_5 regexp '^[A-Z]{5}[0-9].'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_5 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;


	-- PATTERN: 6
	-- DATA: N211180595415538
    
	update t_intrecords 
	set derivedCol_2 = referenceText_11,
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 regexp '^[A-Z]{1}[0-9]*$' 
		and length(referenceText_11) <=16
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_6 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	
	-- PATTERN: 7
	-- DATA: LVBN18186400765
    
	update t_intrecords 
	set derivedCol_2 = referenceText_11,
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 regexp '^[A-Z]{4}[0-9]*$'
		and length(referenceText_11) between 15 and 16
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_7 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	-- PATTERN 8
	update t_intrecords 
	set derivedCol_2 =  trim(replace(replace(replace(REGEXP_SUBSTR(referenceText_11, '([A-Z]{4,5}[0-9]{10,20})[-| |*]'), '-',''), '-', ''), '*','')),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 REGEXP '[A-Z]{4,5}[0-9]{10,20}[-| |*]'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_8 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	--
    -- PATTERN: 9
	update t_intrecords 
	set derivedCol_2 =  trim(replace(replace(replace(REGEXP_SUBSTR(referenceText_11, '([A-Z]{4,5}[0-9]{10,20})'), '-',''), '-', ''), '*','')),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_11 REGEXP '[A-Z]{4,5}[0-9]{10,20}'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_9 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
	--
	-- PATTERN: 10
    update t_intRecords i
	inner join t_extRecords e
		on instr(i.referenceText_11, e.derivedCol_2) > 0 
        and i.referenceDateTime_1 = e.referenceDateTime_1
		and i.amount_1 = e.amount_1 		
	set i.derivedCol_2 = e.derivedCol_2,
		i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vupdateToken    
	where 
		i.jobid= vJobId
		and i.relationshipid= vrelationshipId
		and i.processingStatus = vprocessingStatus
		and i.isDeleted='N'		
		and e.processingStatus = vprocessingStatus
		and e.jobid= vJobId
		and e.relationshipid= vrelationshipId	
		and i.referenceText_11 is not null 
		and e.derivedCol_2 is not null ;
    
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC2_10 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;


 	COMMIT;
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC3_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC3_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN
DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
        
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
    
     
	update t_intrecords 
	set derivedCol_3 = ltrim(rtrim(referenceText_8)),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_8 is not null 
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC3_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 

	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'Mr.' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'Mr' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'M/S' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'M/s' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'M/s.' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'Y/s' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'Mrs.' ,'') where derivedCol_3 is not null;
    update t_intrecords set derivedcol_3 = replace (derivedCol_3, 'Mrs' ,'') where derivedCol_3 is not null;
	update t_intrecords set derivedcol_3 = trim(derivedcol_3);
    

 	COMMIT;
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC4_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC4_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
   
    -- PATTERN:1 
	-- sample record: 0999918GC0905465 00713611000001TF80102768062-TRANS
    -- split into 2 parts

	update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4 =  substring_index( substring_index(referencetext_11, ' ', 1),'-', 2),
		derivedCol_11 = substring_index( substring_index(referencetext_11, ' ', -1),'-', 1),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE referenceText_11  LIKE ('09999%')		
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC4_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
   
   -- PATTERN: 2
   -- DATA:  0999914BG0000974
	update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4= substring_index( substring_index(referencetext_3, ' ', -1),' ', 1) ,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE referenceText_3  LIKE ('09999%')		
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC4_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
	
	-- PATTERN: 3
    -- DATA: 0999918AP0000328
    
    update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4= substring_index( substring_index(referencetext_5, ' ', -1),' ', 1),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE referenceText_5  LIKE ('09999%')		
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC4_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	
   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
   
   
	-- PATTERN: 4
	-- DATA: 0999918TVSIRNO46      
	update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4 =  REGEXP_SUBSTR(referenceText_4, '[0-9]{7}[A-Z]*[0-9]*'),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE referenceText_4  LIKE ('09999%')
		-- and derivedCol_4 is not null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC4_4 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 

	--
    -- PATTERN: 5
	-- DATA: TO TRANSFER-: 0999918FP0040530 02201627000001TF801      
	update reco.t_intrecords  
	set derivedCol_4 =  REGEXP_SUBSTR(referenceText_4, '09999.{8,12}'),
		derivedCol_11 = substring_index( substring_index(referencetext_4, ' ', -1),' ', 1),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE referenceText_4  LIKE ('%09999%')  
		-- and derivedCol_4 is not null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC4_5 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 

	-- PATTERN: 6
	-- DATA: TO TRANSFER-: 0999918FP0040530 02201627000001TF801      
	update reco.t_intrecords  
	set derivedCol_4 =  REGEXP_SUBSTR(referenceText_11, '09999.{8,12}'),
		derivedCol_11 = substring_index( substring_index(referencetext_11, ' ', -1),' ', 1),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE referenceText_11  LIKE ('%09999%')
		-- and derivedCol_4 is not null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC4_6 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 


	update t_intrecords set derivedCol_11 = null 
    where derivedCol_4 = derivedCol_11 
		and jobId = vJobId
		and relationshipId = vrelationshipId
        and isDeleted='N';
        
	/*
    update t_intrecords set derivedCol_11 = null 
    where length(derivedCol_11) <25 
		and jobId = vJobId
		and relationshipId = vrelationshipId
        and isDeleted='N';
	*/
	UPDATE T_INTRECORDS SET DERIVEDCOL_4 = TRIM(DERIVEDCOL_4), DERIVEDCOL_11 = TRIM(DERIVEDCOL_11)
    where 
		jobId = vJobId
		and relationshipId = vrelationshipId
        and isDeleted='N';
    
    
 	COMMIT;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC5_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC5_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	-- PATTERN: 1
    -- DATA: CM21148758
    update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5=substr(referenceText_11,instr(referenceText_11,'CM2'),10),
	lastUpdatedBy = vUserName ,
	lastUpdatedDt = vupdateToken    
    WHERE 
		(referenceText_11  LIKE ('CM2%'))
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC5_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- PATTERN: 2
    -- DATA: CM21148758
    update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5=substr(referenceText_5,instr(referenceText_5,'CM2'),10),
	lastUpdatedBy = vUserName ,
	lastUpdatedDt = vupdateToken    
    WHERE 
		(referenceText_5 like ('CM2%') )
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC5_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 
    -- PATTERN 3
	update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5= referenceText_11,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
    WHERE 
		(referenceText_11 regexp '^C[A-Z]{2}[0-9]{7}$')
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC5_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
     -- PATTERN 4
     -- 
	update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5= referenceText_5,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
    WHERE 
		(referenceText_5 regexp '^C[A-Z]{2}[0-9]{7}$')
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC5_4 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- Pattern 5 
    -- DATA: BY TRANSFER- AMSARAJ TVS CASH AND CARRY CTD2523986
    update reco.t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5= REGEXP_SUBSTR( referenceText_11 , 'C[A-Z]{2}[0-9]{7}'),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
    WHERE 
		referenceText_11 regexp 'C[A-Z]{2}[0-9]{7}'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC5_5 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

      
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_ERP_DC7_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_ERP_DC7_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;



DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
	
    -- DATA: CE02395257
	update t_intrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_7= REGEXP_SUBSTR(referenceText_11, 'CE0[0-9]{7}'),
    	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where
        (referenceText_11  REGEXP 'CE0[0-9].' )
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_ERP_DC7_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC12_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC12_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN
DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
	-- derive multiple values. Example:WITHDRAWAL TRANSFER--TRANSFER TO 54018777714                           T V S MOTOR COMPANY LT-
    -- extract: DC3=VENDOR NAME, DC12=Account number
	update t_extrecords 
	set derivedCol_12= 
			case 	when referenceText_1 like '%TRANSFER TO%' 	THEN substring_index( substring_index(referenceText_1, 'TRANSFER TO ', -1),' ', 1) 
					when referenceText_2 like 'TRANSFER TO%' 	THEN substring_index( substring_index(referenceText_2, 'TRANSFER TO ', -1),' ', 1)
            end,
		derivedCol_3=trim(trailing '-' from substring(referenceText_1, 72, 200))   ,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where referenceText_1 like 'WITHDRAWAL TRANSFER%'
		and jobId = vJobId
		and relationshipId = vRelationshipId
		and processingStatus = vProcessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC12_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
  
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;


	--
    update t_extrecords 
	set derivedCol_12= 
		case 
			when referenceText_1 like '%SWEEP FROM%' THEN substring_index( substring_index(referenceText_1, ' ', -1),'-', 1) 
		end ,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where referenceText_1 like 'TRANSFER CREDIT%'
		and jobId = vJobId
		and relationshipId = vRelationshipId
		and processingStatus = vProcessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC12_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
  
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;



	--
    update t_extrecords 
	set derivedCol_12= 
			substring_index( substring_index(referenceText_2, 'SWEEP FROM ', -1),' ', 1),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where referenceText_2 like 'SWEEP FROM%'
		and jobId = vJobId
		and relationshipId = vRelationshipId
		and processingStatus = vProcessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC12_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
  
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	--
    
    
    
	COMMIT;
    
 	
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN

DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
    RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
    update reco.t_extrecords
	set derivedCol_1 = referenceText_2,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_2 regexp '^[0-9]*$'
    and length(referenceText_2) >0
		and processingStatus = vprocessingStatus
        and jobId=vJobId
        and relationshipId=vrelationshipId
        and isDeleted='N';            
            
    
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 
	--
    
	update reco.t_extrecords
	set derivedCol_1 = trim(substring_index( substring_index(referenceText_1, '-', -1),'-',1 )),
		derivedCol_3 = trim(substring( substring_index( substring_index(referenceText_1, 'TO CLEARING-',  -1),'-', 1),4,200)),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_2 regexp '^[0-9]*$'
    and referenceText_1 like 'TO CLEARING%'
		and processingStatus = vprocessingStatus
        and jobId=vJobId
        and relationshipId=vrelationshipId
        and isDeleted='N';            
            
    
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC1_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 
 	COMMIT;
	SET vReturn = 1;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC2_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC2_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN
DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vupdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- derive multiple dataset. Example:BY TRANSFER-NEFT*HDFC0000001*N182180574749113*10087AZTS1*S K J-TRANSFER FROM 3199677044304-
    -- extract: DC2 = UTR number, DC10=IFSC Code, DC11=UniqCode, DC12=Account number
	update t_extrecords 
	set derivedCol_2= trim(substring_index( substring_index(referenceText_1, '*', -3),'*', 1)),
    -- trim(substring(referenceText_1,locate('NEFT',referenceText_1)+17,((locate('*',referenceText_1,35))-(locate('NEFT',referenceText_1)+17)))),
		derivedCol_10=trim(substring_index( substring_index(referenceText_1, '*', -4),'*', 1)),    
        derivedCol_11= trim(substring_index( substring_index(referenceText_1, '*', -2),'*', 1)),
        derivedCol_12=trim( TRAILING '-' FROM  trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) + 14, 15 )) ),
    	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
	where referenceText_1 like 'BY TRANSFER-NEFT*%'	
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 	COMMIT;
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC2_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC2_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN

DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- derive multiple dataset. Example:TO TRANSFER-INB NEFT UTR NO: SBIN118183999381-NEFT INB: AO50211404                              TRANSFER TO 3197944044306-CASTROL INDIA LIMITED
    -- DC#2 = UTR NUMBER, DC11=UNIQCODE, DC#12=ACCOUNT NUMBER, DC#3=VENDOR NAME
	UPDATE t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	SET derivedCol_2= trim(replace( substring_index(substring_index(referenceText_1, ':', -2),':', 1), '-NEFT INB', '')),
		derivedCol_11 = trim(substring_index( substring_index(referenceText_1, ': ', -1),' ', 1)), 
        derivedCol_12 = trim(substring_index( substring_index(referenceText_1, 'TRANSFER TO ', -1),'-', 1)),
        derivedCol_3 = trim(substring_index(referenceText_1, '-', -1)),
    	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	WHERE  referenceText_1 like 'TO TRANSFER-INB NEFT UTR NO:%'
		AND jobId = vJobId
		AND relationshipId = vrelationshipId
		AND processingStatus = vProcessingStatus
		AND isDeleted='N';
        
	-- SELECT '	ROWS UPDATED:' , CONCAT(ROW_COUNT()), '	TIME:', NOW();   
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 	COMMIT;
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC2_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC2_3`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;


	START TRANSACTION;
    SET vupdateToken = now();
	
    -- data: BY TRANSFER-RTGS UTR NO: UTIBR52018070200651162-TRANSFER FROM 3199859044307-SHREE KRISHNA AGENCIES
    -- data: TO TRANSFER-RTGS UTR NO: SBINR52018070200009748-TRANSFER TO 4599110044305-MICRO PARK LOGISTICS PVT LTD
    
	update t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_2= trim(substring_index( substring_index(referenceText_1, ': ', -1),'-', 1)),
		derivedCol_12=
			case when referenceText_1 like 'BY TRANSFER%' then
				trim(substring_index( substring_index(referenceText_1, 'TRANSFER FROM ', -1),'-', 1))
			when referenceText_1 like 'TO TRANSFER%' then
				trim(substring_index( substring_index(referenceText_1, 'TRANSFER TO ', -1),'-', 1))
		end,
        derivedCol_3=trim(substring_index(referenceText_1, '-', -1)),
    	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_1 like '%RTGS UTR NO%' 
		-- and referenceText_1 not like '%RTGS UTR NO:%'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 	COMMIT;
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC2_4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC2_4`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;


	START TRANSACTION;
    SET vupdateToken = now();
	-- data:BY TRANSFER-RTGS UCBAR52018073100047255  A11243AZTS1-TRANSFER FROM 3199859044307-
    
	update t_extrecords  -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_2= trim(trim(trailing '-TRANSFER' FROM substring_index( substring_index(referenceText_1, ' ', 3),' ', -1))),
		derivedCol_11= CASE WHEN LENGTH(substring_index( substring_index(referenceText_1, '-', 2),' ', -1)) <12 THEN substring_index( substring_index(referenceText_1, '-', 2),' ', -1) ELSE NULL END,
        derivedCol_12 =
			case when referenceText_1 like 'BY TRANSFER%' then
				trim(trailing '-TRANSFER' FROM substring_index( substring_index(referenceText_1, 'TRANSFER FROM ', -1),'-', 1))
			when referenceText_1 like 'TO TRANSFER%' then
				trim(substring_index( substring_index(referenceText_1, 'TRANSFER TO ', -1),'-', 1))
			end,
    	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_1 like 'BY TRANSFER-RTGS%' 
		and referenceText_1 not like '%UTR NO%' 
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_4 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- data: 'BY TRANSFER-INB IMPS818308884703/8754891888/XX7441/TCF_180603-MAC000135276714          MAC000135276714          TRANSFER FROM 4897955162097-'
    update t_extrecords  -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_2= REGEXP_SUBSTR(referenceText_1, 'IMPS[0-9]{12}'),
        derivedCol_12 =replace(substring_index(referenceText_1, ' ',  -1), '-', ''),
    	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_1 like '%IMPS%' 
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_4 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- data: BY TRANSFER-RTGS CNRBR52018070200685099  A10231AZTS1-TRANSFER FROM 3199860044304-
    update t_extrecords 
	set derivedCol_2 =  replace(replace(replace(REGEXP_SUBSTR(referenceText_1, '([A-Z]{4,5}[0-9]{10,20})[-| |*]'), '-',''), '-', ''), '*',''),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_1 REGEXP '[A-Z]{4,5}[0-9]{10,20}[-| |*]'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_5 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- data: BY TRANSFER-RTGS CNRBR52018070200685099  A10231AZTS1-TRANSFER FROM 3199860044304-
    update t_extrecords 
	set derivedCol_2 =  replace(replace(replace(REGEXP_SUBSTR(referenceText_1, '([A-Z]{4,5}[0-9]{10,20})'), '-',''), '-', ''), '*',''),
      	lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
	where referenceText_1 REGEXP '[A-Z]{4,5}[0-9]{10,20}'
		and derivedCol_2 is null
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC2_6 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 
 	COMMIT;
	SET vReturn = 1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC3_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC3_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	 ROLLBACK;
	 RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
    
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'Mr.' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'Mr' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'M/S' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'M/s' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'M/s.' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'Y/s' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'Mrs.' ,'') where derivedCol_3 is not null;
    update t_extrecords set derivedcol_3 = replace (derivedCol_3, 'Mrs' ,'') where derivedCol_3 is not null;
	update t_extrecords set derivedcol_3 = trim(derivedcol_3);
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC4_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC4_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`, `endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- sample record: TO TRANSFER-: 0999914BG0000974 01825244000001TF80102768062-TRANSFER TO 4599903099999-
    -- split into 3 parts
	update reco.t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4=trim(substr(referenceText_1,instr(referenceText_1,'09999'),16)),
		derivedCol_11 = trim(substr(referenceText_1,32,27)),
		derivedCol_12=trim(replace(substr(referenceText_1,72,20),'-','')),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
    WHERE referenceText_1  LIKE ('TO TRANSFER-: 09999%')		
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC4_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	-- 2 ND PATTERN
    -- DATA: CORR WDL TFR-: 0999918GC0904928 01111257000001TF80102768062-TRANSFER TO 97960099993-
	-- DATA: CORR CREDIT-: 0999918GC0906630 00713106000001TF--
	-- DATA: CORR WDL TFR-IMLB: 0999918US0030915 00402405000001TRADE FIN-TRANSFER TO 97695011114-


	update reco.t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4 =  
			case when referenceText_1 like 'CORR WDL TFR-:%' THEN 
					substring_index( substring_index(referenceText_1, ' ', -4),' ', 1)
				when referenceText_1 like 'CORR WDL TFR-%' THEN 
					substring_index( substring_index(referenceText_1, ' ', -5),' ', 1)
				when referenceText_1 like 'CORR CREDIT-:%' THEN 
					substring_index( substring_index(referenceText_1, ' ', -2),' ', 1)
			end,
		derivedCol_11 = 
			case when referenceText_1 like 'CORR WDL TFR-:%' THEN 
				substring_index( substring_index(referenceText_1, ' ', -3),'-', 1)
			when referenceText_1 like 'CORR WDL TFR-%' THEN 
				substring_index( substring_index(referenceText_1, ' ', -4),' ', 1)
			when referenceText_1 like 'CORR CREDIT-:%' THEN 
				substring_index( substring_index(referenceText_1, ' ', -1),'-', 1)
			end,
		derivedCol_12 = 
			case when referenceText_1 like 'CORR WDL TFR-:%' THEN 
				substring_index( substring_index(referenceText_1, ' ', -1),'-', 1)
			when referenceText_1 like 'CORR WDL TFR-%' THEN 
				substring_index( substring_index(referenceText_1, ' ', -1),'-', 1)
			end,
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vUpdateToken    
    WHERE  referenceText_1 like 'CORR%'	
		and jobId = vJobId
		and relationshipId = vrelationshipId
		-- and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC4_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

	-- PATTERN: 3
	 -- DATA: DEBIT-: 0999918GC0904905 00713106000001TF80102768062--
    -- DATA: CREDIT-: 0999918GC0905059 00901000000001TF80102768062--
	update t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_4	=  substring_index( substring_index(referenceText_1, ' ', -2),' ', 1) ,
		derivedCol_11 	= trim(TRAILING '--' FROM substring_index( substring_index(referenceText_1, ' ', -1),' ', 1)), 
    lastUpdatedBy = vUserName ,
	lastUpdatedDt = vupdateToken    
	where
		(referencetext_1 like 'CREDIT%' OR referencetext_1 like 'DEBIT%')
        and referenceText_1 like '%09999%'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC4_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
	update t_extrecords set derivedCol_11 = null 
    where derivedCol_4 = derivedCol_11 
		and jobId = vJobId
		and relationshipId = vrelationshipId
        and isDeleted='N';
	/*
    update t_extrecords set derivedCol_11 = null 
    where length(derivedCol_11) <25 
		and jobId = vJobId
		and relationshipId = vrelationshipId
        and isDeleted='N';
     */
     
	UPDATE T_EXTRECORDS SET DERIVEDCOL_4 = TRIM(DERIVEDCOL_4), DERIVEDCOL_11 = TRIM(DERIVEDCOL_11)
    where 
		jobId = vJobId
		and relationshipId = vrelationshipId
        and isDeleted='N';
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC5_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC5_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vupdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`, `endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- DATA :BY TRANSFER-INB --3000657243CM20511035               TRANSFER FROM 37574857707                         M S ARYA ASSOCIATES-
	-- DC#5=CM2[0-9], DC#3=VENDOR NAME, DC#12=ACCOUNT NUMBER
    
    update reco.t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5=substr(referenceText_1,instr(referenceText_1,'CM2'),10),
	derivedCol_3 = 
		case when instr(referenceText_1,'BY TRANSFER-INB --') >0 then 
				trim(TRAILING '-' FROM trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) + 25, length(referenceText_1))) ) 
			when instr(referenceText_1,'BY TRANSFER-INB -') >0  then 
				trim( TRAILING '-' FROM  trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) +25, length(referenceText_1))) )
		end,
	derivedCol_12= 
			case when instr(referenceText_1,'BY TRANSFER-INB --') >0 then 
				trim(TRAILING '-' FROM trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) +14 , 11 )) ) 
			when instr(referenceText_1,'BY TRANSFER-INB -') >0  then 
				trim( TRAILING '-' FROM  trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) + 14, 11 )) )
		end 
    WHERE referenceText_1  LIKE ('%CM2%') 
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC5_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
	
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC5_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC5_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN

DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vupdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`, `endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- DATA: BY TRANSFER-INB TVSM OIL ACC-CTD2469106               TRANSFER FROM 30191734234                         BALASANKA MOTOR PRIVAT-
    
	update reco.t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5= trim(substr(referenceText_1,(REGEXP_INSTR(referenceText_1,('C[:alpha:][A-Z][0-9]{6}'))),10)),
	derivedCol_3 = 
		case when instr(referenceText_1,'BY TRANSFER-INB ') >0 then 
				trim(TRAILING '-' FROM trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) + 25, length(referenceText_1))) ) 
			when instr(referenceText_1,'BY TRANSFER-INB-') >0  then 
				trim( TRAILING '-' FROM  trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) +25, length(referenceText_1))) )
		end,
	derivedCol_12= 
			case when instr(referenceText_1,'BY TRANSFER-INB ') >0 then 
				trim(TRAILING '-' FROM trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) +14 , 11 )) ) 
			when instr(referenceText_1,'BY TRANSFER-INB-') >0  then 
				trim( TRAILING '-' FROM  trim(substr(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ' ) + 14, 11 )) )
		end 
    WHERE referenceText_1 regexp ('C[:alpha:][A-Z][0-9]{6}') 
		and (referenceText_1 like 'BY TRANSFER-INB%' )
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC5_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
	
    -- Pattern 2
    -- DATA: CTE7149967               TRANSFER FROM 30729927558                         CRV MOTORS / 
    update reco.t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5= REGEXP_SUBSTR( referenceText_2 , 'C[A-Z]{2}[0-9]{7}'),
		lastUpdatedBy = vUserName ,
		lastUpdatedDt = vupdateToken    
    WHERE 
		referenceText_2 regexp 'C[A-Z]{2}[0-9]{7}'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC5_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	   
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

  
  
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC5_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC5_3`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN

DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vupdateToken = now();
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`, `endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- DATA: TO TRANSFER-INB-1800453802CKG4366787               TRANSFER TO 33864828288                           TELANGANA STATE CYBER-
    
	update reco.t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_5= trim(substr(referenceText_1,(REGEXP_INSTR(referenceText_1,('C[A-Z]{2}[0-9]{7}'))),10)),
	derivedCol_12 = 
		case when referenceText_1 like 'BY TRANSFER%' then
			trim(TRAILING '-' FROM substring(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ') + 14, 15))
		when referenceText_1 like 'TO TRANSFER%' then
			trim(TRAILING '-' FROM substring(referenceText_1, instr(referenceText_1, 'TRANSFER TO ') + 12, 15))
		end,
	derivedCol_3= 
			case when referenceText_1 like 'BY TRANSFER%' then
				trim(TRAILING '-' FROM trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ') + 14 + 15, 200))) 
			when referenceText_1 like 'TO TRANSFER%' then
				trim(TRAILING '-' FROM trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER TO ') + 12 + 15, 200))) 
			end 
    where
		referenceText_1 like 'TO TRANSFER-INB%'
		and referenceText_1  regexp 'C[A-Z]{2}[0-9]{7}'
		and referenceText_1 not like '%CMP0000000%'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC5_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
	
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC7_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC7_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	update t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_7=trim(substring(referenceText_1, locate('CE',referenceText_1),10)),
    derivedCol_12=
		case when referenceText_1 like 'BY TRANSFER%' then
			trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ') + 14, 15))
		when referenceText_1 like 'TO TRANSFER%' then
			trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER TO ') + 12, 15))
		end, 
	derivedCol_3= 
		case when referenceText_1 like 'BY TRANSFER%' then
			trim(TRAILING '-' FROM trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ') + 14 + 15, 200))) 
		when referenceText_1 like 'TO TRANSFER%' then
			trim(TRAILING '-' FROM trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER TO ') + 12 + 15, 200))) 
		end,
	lastUpdatedBy = vUserName ,
	lastUpdatedDt = vupdateToken    
	where
		-- referenceText_1 regexp ' CE[0-9]'
        referenceText_1 like 'TO TRANSFER-INB Reversal%'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
		and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC7_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_DC_SBI_DC8_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_DC_SBI_DC8_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;



DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in generation of Derived Columns. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
    
	-- data: BY TRANSFER-INB SUNDARAM CLAYTON LIMITED-CMP00000000058361196AO52112651               TRANSFER FROM 10130459063                         SUNDARAM CLAYTON LIMIT-
    -- data: TO TRANSFER-INB TVS MOTOR COMPANY LIMITED-CMP00000000056065033AO50210695               TRANSFER TO 11083986469                           PPG ASIAN PAINTS PRIVA-
    -- DC#8=VENDOR NAME, DC#12=ACCOUNT NUMBER
    
	update t_extrecords -- FORCE INDEX (IDX_TER_1_1)
	set derivedCol_8 = trim(substring(referenceText_1, instr(referenceText_1, 'CMP000000'), 30)),
    derivedCol_3=
		case when referenceText_1 like 'BY TRANSFER%' then
			trim(TRAILING '-' FROM trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ') + 14 + 15, 200))) 
		when referenceText_1 like 'TO TRANSFER%' then
			trim(TRAILING '-' FROM trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER TO ') + 12 + 15, 200))) 
		end,
    derivedCol_12= 
		case when referenceText_1 like 'BY TRANSFER%' then
			trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER FROM ') + 14, 15))
		when referenceText_1 like 'TO TRANSFER%' then
			trim(substring(referenceText_1, instr(referenceText_1, 'TRANSFER TO ') + 12, 15))
		end,
	lastUpdatedBy = vUserName ,
	lastUpdatedDt = vupdateToken    
	where
		referenceText_1 like '%CMP000000000%'
		and jobId = vJobId
		and relationshipId = vrelationshipId
		and processingStatus = vprocessingStatus
        and isDeleted='N';
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_DC_SBI_DC8_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;
 
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_LD_ERP_1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_LD_ERP_1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN



DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION 
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;
	ROLLBACK;
	RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;
SET vupdateToken = now();

	-- Check if records in STG for similar Transaction Date (DocDate) exists in the DB (t_intrecords table). If exists, exit the procedure after  logging an error
    IF NOT EXISTS (select count(*) from  stg_importsourceint where jobid=vJobId and isDeleted='N' and processingStatus ='New')
	THEN
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'No records available in Staging tables for import (ERP). Please reload the file into the Staging!!'   ;
		
		SET vReturn = -1;  
	ELSEIF NOT EXISTS
    (
		select iq.jobimportid, sum(RowCount) from 
		(
			select  jobimportid, txnDate , count(*) RowCount
			from 
			(
				select 	STR_TO_DATE( concat( substring(referenceDateTime_1, char_length(referenceDateTime_1)-3), ',', substring(referenceDateTime_1, char_length(referenceDateTime_1) -6, 2), ',', replace(substring(referenceDateTime_1, 1,2), '-','') ), "%Y,%m,%d") txnDate,
				jobImportId
				from stg_importsourceint where jobid=vJobId and isDeleted='N' and processingStatus ='New'
                and amount_2 is not null
			) q where txnDate is not null group by jobimportid, txnDate 
		) iq
		left outer join 
		(
			SELECT distinct referenceDateTime_1 as txnDate FROM reco.t_intrecords where jobid=vJobId and isDeleted='N'
		) eq 
		on iq.txnDate = eq.txnDate
		where eq.txnDate is  null	
    ) THEN 

        
        INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Records already exists in the ERP Transaction Table for the given date range!!'   ;
        
        -- CALL P_RECOTOOLS_UPDATE_EXECUTIONDETAILS (vExecutionId,   vUserName, 'ERROR');
        SET vReturn = -1;     
        
    ELSE
    
		START TRANSACTION;
		SET vupdateToken = now();
		
		insert into t_intrecords
		(jobId,jobImportId, organizationId, jobExecutionId, relationshipId, recordType, processingStatus, processingDateTime, currencyId, 
		referenceText_1, referenceText_2, referenceText_3, referenceText_4,
		referenceText_5, referenceText_6, referenceText_7,  referenceText_8,
		referenceText_9, referenceText_10, referenceText_11, referenceText_12,
		referenceDateTime_1, 
		referenceDateTime_2, 
		referenceDateTime_3, 	
		debitAmount,
		creditAmount,
		amount_1, 
		isDeleted, createdDateTime, createdByUser, sourceRowId)

		select jobId, jobImportId,  organizationId, vjobExecutionId, relationshipId, recordType, "New", vupdateToken, currencyId, 
		case when length(trim(referenceText_1)) >0 then trim(referenceText_1) else null end, 
		case when length(trim(referenceText_2)) >0 then trim(referenceText_2) else null end, 
		case when length(trim(referenceText_3)) >0 then trim(referenceText_3) else null end, 
		case when length(trim(referenceText_4)) >0 then trim(referenceText_4) else null end, 
		case when length(trim(referenceText_5)) >0 then trim(referenceText_5) else null end, 
		case when length(trim(referenceText_6)) >0 then trim(referenceText_6) else null end, 
		case when length(trim(referenceText_7)) >0 then trim(referenceText_7) else null end, 
		case when length(trim(referenceText_8)) >0 then trim(referenceText_8) else null end, 
		case when length(trim(referenceText_9)) >0 then trim(referenceText_9) else null end, 
		case when length(trim(referenceText_10)) >0 then trim(referenceText_10) else null end, 
		case when length(trim(referenceText_11)) >0 then trim(referenceText_11) else null end, 
		case when length(trim(referenceText_12)) >0 then trim(referenceText_12) else null end, 
		STR_TO_DATE( concat( substring(referenceDateTime_1, char_length(referenceDateTime_1)-3), ',', substring(referenceDateTime_1, char_length(referenceDateTime_1) -6, 2), ',', replace(substring(referenceDateTime_1, 1,2), '-','') ), "%Y,%m,%d"),
		STR_TO_DATE( concat( substring(referenceDateTime_2, char_length(referenceDateTime_2)-3), ',', substring(referenceDateTime_2, char_length(referenceDateTime_2) -6, 2), ',', replace(substring(referenceDateTime_2, 1,2), '-','') ), "%Y,%m,%d"),
		STR_TO_DATE( concat( substring(referenceDateTime_3, char_length(referenceDateTime_3)-3), ',', substring(referenceDateTime_3, char_length(referenceDateTime_3) -6, 2), ',', replace(substring(referenceDateTime_3, 1,2), '-','') ), "%Y,%m,%d"),
		CASE 
			WHEN cast(replace(replace(amount_2,'"', ''),',','') as  decimal) =0 THEN  NULL 
			WHEN cast(replace(replace(amount_2,'"', ''),',','') as  decimal(13,2)) < 0 THEN cast(replace(replace(amount_2,'"', ''),',','')  as  decimal(13,2))
		END debitAmount,
		CASE 
			WHEN cast(replace(replace(amount_2,'"', ''),',','') as  decimal(13,2)) =0  THEN  NULL 
			WHEN cast(replace(replace(amount_2,'"', ''),',','') as  decimal(13,2)) > 0 THEN cast(replace(replace(amount_2,'"', ''),',','')  as  decimal(13,2))
		END creditAmount,   
		CASE 
			WHEN cast(replace(replace(amount_2,'"', ''),',','') as  decimal(13,2)) =0  THEN  NULL 
			ELSE cast(replace(replace(replace(amount_2,'"', ''),',',''),'-','') as  decimal(13,2)) 
		END amount_1,      
		'N',vupdateToken, 1,importSourceIntId
		from  stg_importsourceint FORCE INDEX (IDX_ISI_LOAD)
		where processingStatus='New'
			and jobId= vjobId
			and relationshipId=vrelationshipId
			and length(trim(referencedatetime_1))>1
			and recordType='Transaction'
			and isDeleted='N';            
			
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_LD_ERP_1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
		
		update stg_importsourceint
		set processingStatus = 'Processed', processingDateTime = vupdateToken
		where processingStatus = 'New' 
			and jobId= vjobId
			and relationshipId= vrelationshipId;
					
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'P_0001_LD_ERP_1_1';

		COMMIT;
		SET vReturn = 1;
	END IF;
 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_LD_SBI_1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_LD_SBI_1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;

DECLARE EXIT  HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
		
		ROLLBACK;
		-- RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;
SET vUpdateToken = now();

	IF NOT EXISTS (select count(*) from  stg_importsourceext where jobid=vJobId and isDeleted='N' and processingStatus ='New')
	THEN
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'No records available in Staging tables for import (Bank). Please reload the file into the Staging!!'   ;
		
		 SET vReturn = -1;  
	ELSEIF NOT EXISTS
		(
			select iq.jobimportid, sum(RowCount) from 
			(
				select  jobimportid, txnDate , count(*) RowCount
				from 
				(
					select 	
					STR_TO_DATE( concat('20', substring(referenceDateTime_1, char_length(referenceDateTime_1)-1), ',', substring(referenceDateTime_1, char_length(referenceDateTime_1) -5, 3), ',', replace(substring(referenceDateTime_1, 1,2), '-','') ) , "%Y,%M,%d") txndate,
					jobImportId
					from stg_importsourceext where jobid=vJobId and isDeleted='N' and processingStatus ='New'
					and length(referenceDateTime_1)>=8
					and amount_2 is not null
				) q where txnDate is not null group by jobimportid, txnDate 
			) iq
			left outer join 
			(
				SELECT distinct referenceDateTime_1 as txnDate FROM reco.t_extrecords 
				where jobid=vJobId and isDeleted='N'
			) eq 
			on iq.txnDate = eq.txnDate
			where eq.txnDate is null	
		) THEN 
	        
		select iq.jobimportid, sum(RowCount) from 
			(
				select  jobimportid, txnDate , count(*) RowCount
				from 
				(
					select 	
					STR_TO_DATE( concat('20', substring(referenceDateTime_1, char_length(referenceDateTime_1)-1), ',', substring(referenceDateTime_1, char_length(referenceDateTime_1) -5, 3), ',', replace(substring(referenceDateTime_1, 1,2), '-','') ) , "%Y,%M,%d") txndate,
					jobImportId
					from stg_importsourceext where jobid=vJobId and isDeleted='N' and processingStatus ='New'
					and length(referenceDateTime_1)>=8
					and amount_2 is not null
				) q where txnDate is not null group by jobimportid, txnDate 
			) iq
			left outer join 
			(
				SELECT distinct referenceDateTime_1 as txnDate FROM reco.t_extrecords 
				where jobid=vJobId and isDeleted='N'
			) eq 
			on iq.txnDate = eq.txnDate
			where eq.txnDate is null	;
            
        INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Records already exists in the Bank Transaction Table for the given date range!!!'   ;
        
        SET vReturn = -1;  
        
	ELSE
    
		START TRANSACTION;
		
		select 1;
        
		insert into t_extrecords
		(jobId,jobImportId, jobExecutionId, organizationId, relationshipId, recordType, processingStatus, 
		processingDateTime, currencyId, 
		referenceText_1, 
		referenceText_2, 
		referenceText_3, 
		referenceText_4,
		referenceDateTime_1, 
		referenceDateTime_2, 
		debitAmount, 
		creditAmount,
		amount_1,
		amount_2,
		isDeleted, createdDateTime, createdByUser, sourceRowId)

		select jobId, jobImportId, vjobExecutionId,  organizationId, relationshipId, recordType, "New", 
		vUpdateToken, currencyId, 
		case when length(trim(referenceText_1)) >0 then trim(referenceText_1) else null end, 
		case when length(trim(referenceText_2)) >0 then replace(replace(referenceText_2, '- / -', ''), '- / ', '')  else null end,  
		case when length(trim(referenceText_3)) >0 then trim(referenceText_3) else null end,  
		case when length(trim(referenceText_4)) >0 then trim(referenceText_4) else null end,   
		case when referenceDateTime_1 is not null then 
			STR_TO_DATE( concat('20', substring(referenceDateTime_1, char_length(referenceDateTime_1)-1), ',', substring(referenceDateTime_1, char_length(referenceDateTime_1) -5, 3), ',', replace(substring(referenceDateTime_1, 1,2), '-','') ) , "%Y,%M,%d")
		end,
        case when referenceDateTime_2 is not null then 
			STR_TO_DATE( concat('20', substring(referenceDateTime_2, char_length(referenceDateTime_2)-1), ',', substring(referenceDateTime_2, char_length(referenceDateTime_2) -5, 3), ',', replace(substring(referenceDateTime_2, 1,2), '-','') ) , "%Y,%M,%d")
		end,		
		case when trim(replace(replace(debitAmount,'"', ''),',',''))  REGEXP  '^[0-9]+\\.?[0-9]*$'  
			then  cast(replace(replace(debitAmount,'"', ''),',','')*(-1) as decimal(13,2))  
		end debitAmount,    		
		
		case when trim(replace(replace(creditAmount,'"', ''),',',''))  REGEXP  '^[0-9]+\\.?[0-9]*$'  
			then  cast(replace(replace(creditAmount,'"', ''),',','') as decimal(13,2))  
		end creditAmount,
		case 	when trim(replace(replace(debitAmount,'"', ''),',',''))  REGEXP  '^[0-9]+\\.?[0-9]*$'  
					then cast(replace(replace(debitAmount,'"', ''),',','') as decimal(13,2))  
				when trim(replace(replace(creditAmount,'"', ''),',',''))  REGEXP  '^[0-9]+\\.?[0-9]*$'  
					then cast(replace(replace(creditAmount,'"', ''),',','') as decimal(13,2))     
		end amount_1, 
		case 	when trim(replace(replace(replace(replace(amount_2,'"', ''),',',''),'(',''),')',''))  REGEXP  '^[0-9]+\\.?[0-9]*$'  
					then cast(replace(replace(replace(replace(amount_2,'"', ''),',',''),'(',''),')','') as decimal(13,2))     
		end,        
		'N', vUpdateToken, vUserName , importSourceExtId
		from  stg_importsourceext FORCE INDEX (IDX_ISE_LOAD)
		where processingStatus='New'
			and jobId= vjobId
			and relationshipId= vrelationshipId  
			and recordType='Transaction'
			and isDeleted='N'
			and length(trim(referenceDateTime_1))>0;            
			
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_LD_SBI_1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
		
		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) ;

		update stg_importsourceext
		set processingStatus = 'Processed', processingDateTime = vUpdateToken
		where processingStatus = 'New' 
			and jobId= vjobId
			and relationshipId=vrelationshipId;

		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'STAGING_UPDATE_EXT';
                
		COMMIT;
		SET vReturn = 1;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
	
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		`ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)	
    select q2.intRecordsId, q1.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vupdateToken, vUserName, 'R10.1'  , vJobExecutionId,vRelationshipId
	from 
	(
		select e.jobId, e.relationshipId, e.extRecordsId,  eq1.BankUniqCode1, eq1.BankUniqCode2, e.amount_1 as BankAmount 
		from t_extrecords e 
		inner join 
		(
			select referenceDateTime_1 as BankUniqCode1, referenceText_1 as BankUniqCode2 
			from t_extrecords 
			where   referenceDateTime_1 is not null 
				and referenceText_1 is not null 
				and processingStatus in ('New', 'Open')
				and jobId = vJobId
				and relationshipId = vRelationShipId
                and isDeleted = 'N'
			group by referenceDateTime_1 , referenceText_1 
			having count(*) = 1
		) eq1 on (eq1.BankUniqCode1) = (e.referenceDateTime_1) 
			and (eq1.BankUniqCode2) = (e.referenceText_1)			 
			and e.jobId = vJobId
			and e.relationshipId= vRelationshipId
	) q1 
	inner join
	(
		select i.jobId, i.relationshipId, i.intRecordsId, iq1.ERPUniqCode1 , iq1.ERPUniqCode2, i.amount_1 as ERPAmount
		from t_intrecords i 
		inner join  
		(
			select referenceDateTime_1 as ERPUniqCode1, referenceText_11 as ERPUniqCode2  
			from t_intrecords 
			where referenceDateTime_1 is not null
				and referenceText_11 is not null
				and jobId = vJobId
				and relationshipId = vRelationShipId
                and isDeleted = 'N'
				and processingStatus IN ('New','Open')
			group by referenceDateTime_1, referenceText_11
			having count(*) = 1
		) iq1 on (iq1.ERPUniqCode1) = (i.referenceDateTime_1)
			and (iq1.ERPUniqCode2) = (i.referenceText_11)			 
			and i.jobId = vJobId
			and i.relationshipId= vRelationshipId
	) q2 
	on  
		(q1.BankUniqCode1) = (q2.ERPUniqCode1)
		and instr( q1.BankUniqCode2, q2.ERPUniqCode2)
		and q1.BankAmount = q2.ERPAmount
		and q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId;
    

	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULTS  R10.1' ;

	--
	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vUpdateToken,
		i.jobExecutionId = vjobExecutionId,
		i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vUpdateToken    
	where	
		i.jobId = vJobId
		and i.relationshipId = vrelationshipId	
		and r.processedDt = vUpdateToken
        and i.isDeleted='N';      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R10.1' ;

	-- 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vUpdateToken,
		e.jobExecutionId = vjobExecutionId,
		e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vUpdateToken    
	where	
		e.jobId = vJobId
		and e.relationshipId = vrelationshipId	
		and r.processedDt = vUpdateToken
        and e.isDeleted='N';   
    
	SET iRowCount = ROW_COUNT();	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R10.1' ;

	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_1_BAK` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_1_BAK`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
	
    GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in executing Matching Rule. Error:' + @error_string;


	 ROLLBACK;
	 RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
	-- Do a generic match between the ERP (multiple columns) and string search in Bank (reference 1)
    
    INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		`ruleReference`,
        `jobExecutionId`,
        `relationshipId`
	)
	select q.intRecordsId, q.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vUpdateToken, vUserName, 'R10.1'  , vJobExecutionId,vRelationshipId
    from
    (
		SELECT  e.extRecordsId, i.intRecordsId  
		FROM t_intrecords i 
        inner join t_extrecords e 
			on  i.amount_1 = e.amount_1
		where i.processingStatus in ('New', 'Open') 
        and e.processingStatus in ('New', 'Open') 
		and e.isDeleted='N'		
		and i.isDeleted='N'				 
		and e.jobId = vJobId
		and e.relationshipId= vRelationshipId
		and i.jobId = vJobId
		and i.relationshipId= vRelationshipId
        and 
		(
			instr(e.referenceText_1, i.referenceText_4) > 0 
			or
			instr(e.referenceText_1, i.referenceText_5) > 0 
			or 
			instr(e.referenceText_1, i.referenceText_11) > 0 
		)
		group by  e.extRecordsId, i.intRecordsId 
		having count(*)=1
	) q; 

	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS';


	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vUpdateToken,
		i.jobExecutionId = vjobExecutionId,
        i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vUpdateToken    
	where	
		i.jobId = vJobId
		and i.relationshipId = vRelationshipId	
		and r.processedDt = vUpdateToken;      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY' ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r 
		on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vUpdateToken,
		e.jobExecutionId = vjobExecutionId,
        e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vUpdateToken    
	where	
		e.jobId = vJobId
		and e.relationshipId = vRelationshipId	
		and r.processedDt = vUpdateToken;   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY';


	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (Uniqcode)
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_10_g_1;    
    create temporary table temp_group_10_g_1    
    select q1.ERPUniqCode1,  ERPUniqCode2, q1.ERPAmount, 
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1, q1.ERPUniqCode2)   + @iMyRank  as GroupRank
	from
	(		
		SELECT  referenceText_11 as ERPUniqCode1 , referenceDateTime_1 as ERPUniqCode2, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and referenceText_11 is not null
		group by referenceText_11, referenceDateTime_1 
		having count(*) >= 1 		
	) q1 inner join 
	(
		select referenceText_1 as BankUniqCode1, referenceDateTime_1 as BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_4)
		where 
			referenceText_1 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by referenceText_1, referenceDateTime_1 
		having count(*) = 1  
	) q2 
	on 	 
		instr(q2.BankUniqCode1,q1.ERPUniqCode1) >0
        and q1.ERPUniqCode2 = q2.BankUniqCode2
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_G_AM_1-> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R10_G_AM_1' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R10G_AM_1'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_10_g_1;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_10_G_AM_1-> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R10_G_AM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_10_g_1 g
			on g.ERPUniqCode1 = i.referenceText_11
            and g.ERPUniqCode2= i.referenceDateTime_1
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N'
            and processingStatus in ('New', 'Open') ;      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R10_G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_10_g_1 g
			on g.BankUniqCode1 = e.referenceText_1
			and g.BankUniqCode2= e.referenceDateTime_1
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N'
            and processingStatus in ('New', 'Open') ;
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R10_G_AM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_10_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_10_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_G_AM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_G_AM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (Uniqcode)
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_10_g_2;    
    create temporary table temp_group_10_g_2    
    select q1.ERPUniqCode1,  ERPUniqCode2, q1.ERPAmount, 
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1, q1.ERPUniqCode2)   + @iMyRank  as GroupRank
	from
	(		
		SELECT  referenceText_4 as ERPUniqCode1 , referenceDateTime_1 as ERPUniqCode2, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and referenceText_4 is not null
		group by referenceText_4, referenceDateTime_1 
		having count(*) >= 1 		
	) q1 inner join 
	(
		select referenceText_1 as BankUniqCode1, referenceDateTime_1 as BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_4)
		where 
			referenceText_1 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by referenceText_1, referenceDateTime_1 
		having count(*) = 1  
	) q2 
	on 	 
		instr(q2.BankUniqCode1,q1.ERPUniqCode1) >0
        and q1.ERPUniqCode2 = q2.BankUniqCode2
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_G_AM_2-> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R10_G_AM_2' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R10G_AM_1'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_10_g_2;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_10_G_AM_2-> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R10_G_AM_2' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_10_g_2 g
			on g.ERPUniqCode1 = i.referenceText_4
            and g.ERPUniqCode2= i.referenceDateTime_1
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N'
            and processingStatus in ('New', 'Open') ;      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R10_G_AM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_10_g_2 g
			on g.BankUniqCode1 = e.referenceText_1
			and g.BankUniqCode2= e.referenceDateTime_1
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N'
            and processingStatus in ('New', 'Open') ;
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R10_G_AM_2' ;

		select @iMaxRank:=max(GroupRank) from temp_group_10_g_2;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_10_g_2;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_G_AM_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_G_AM_3`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (Uniqcode)
     -- FOREX TRANSACTIONS
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_10_g_3;    
    create temporary table temp_group_10_g_3    
    select q1.ERPUniqCode1, q1.ERPAmount, 
    q2.BankUniqCode1,  q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1)   + @iMyRank  as GroupRank
	from
	(		
		SELECT  referenceDateTime_1 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and referenceText_5 like '%FOREX%'
		group by referenceDateTime_1 
		having count(*) >= 1 		
	) q1 inner join 
	(
		select referenceDateTime_1 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords  
		where 
			referenceText_1 like '%Forex%'                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by referenceDateTime_1 
		having count(*) >= 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_G_AM_3-> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R10_G_AM_3' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R10_G_AM_3'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_10_g_3;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_10_G_AM_3-> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R10_G_AM_3' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_10_g_3 g
			on  g.ERPUniqCode1= i.referenceDateTime_1
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N'
            and referenceText_5 like '%FOREX%'
            and processingStatus in ('New', 'Open') ;      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R10_G_AM_3' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_10_g_3 g
			on  g.BankUniqCode1= e.referenceDateTime_1
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N'
            and e.referenceText_1 like '%Forex%'   
            and processingStatus in ('New', 'Open') ;
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R10_G_AM_3' ;

		select @iMaxRank:=max(GroupRank) from temp_group_10_g_3;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_10_g_3;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles 1:1 combinations (ERP:Bank). Nearest Matching (text match). Combination of (referenceText_1 & ReferenceDateTime) 
     -- 1: Populate a temp table with all  (1:1)  Combinations
     -- 2: Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_10_g_1; 
    create temporary table temp_group_10_g_1
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  referenceText_11 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords  
		where 
			jobid = vJobId
			and relationshipid = vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and referenceText_11 is not null         
		group by (referenceText_11)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select referenceText_1 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords  
		where 
			referenceText_1 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by (referenceText_1) , referenceDateTime_1 
		having count(*) =1			
	) q2 
    on 
		instr(q2.BankUniqcode1 , q1.ERPUniqcode1) >0
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount <> q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 10_G_NM_1';

	IF iRowCount >0 then    
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_10_g_1 g 
				on g.ERPUniqCode1 = i.referenceText_11 
				and i.referenceDateTime_1  = g.ERPUniqCode2 
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank,
			i.transactionType = 'AMOUNT-VARIANCE'
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 10_G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_10_g_1 g 
				on g.BankUniqCode1 = e.referenceText_1  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank,
			e.transactionType = 'AMOUNT-VARIANCE'
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 10_G_NM_1' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_10_g_1;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_10_g_1;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_10_G_NM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_10_G_NM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:1 combinations (ERP:Bank). Nearest Matching (text match). Combination of (referenceText_4 & ReferenceDateTime) 
     -- 1: Populate a temp table with all  (1:1)  Combinations
     -- 2: Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_10_g_2; 
    create temporary table temp_group_10_g_2
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  referenceText_4 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords  
		where 
			jobid = vJobId
			and relationshipid = vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and referenceText_4 is not null         
		group by (referenceText_4)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select referenceText_1 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords  
		where 
			referenceText_1 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by (referenceText_1) , referenceDateTime_1 
		having count(*) =1			
	) q2 
    on 
		instr(q2.BankUniqcode1 , q1.ERPUniqcode1) >0
		and q1.ERPUniqcode2 <> q2.BankUniqcode2
		and q1.ERPAmount = q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_10_G_NM_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 10_G_NM_2';

	IF iRowCount >0 then    
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_10_g_2 g 
				on g.ERPUniqCode1 = i.referenceText_4 
				and i.referenceDateTime_1  = g.ERPUniqCode2 
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank,
            i.transactionType = 'DATE-VARIANCE'
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 10_G_NM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_10_g_2 g 
				on g.BankUniqCode1 = e.referenceText_1  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank,
			e.transactionType = 'DATE-VARIANCE'
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 10_G_NM_2' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_10_g_2;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_10_g_2;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_11_1_BAK` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_11_1_BAK`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in executing Matching Rule. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		`ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)	
        
	select q2.intRecordsId, q1.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vupdateToken, vUserName, 'R11.1'   , vJobExecutionId,vRelationshipId
	 from 
	(
		select  @row_number:=
			CASE
			WHEN @VendorName = oq1.VendorName THEN @row_number + 1
			ELSE 1
			END AS num,
			@VendorName:=VendorName as VendorName
			,oq1.amount, oq1.extRecordsId
		from 
		(
			select e.extRecordsId, e.derivedCol_2 as UTR, e.derivedCol_8 as VendorName, e.amount_1 as Amount
			from t_extrecords e
			inner join 
			(
				select  derivedCol_2 as UTR,  derivedCol_8 as VendorName, amount_1 as Amount, count(*) 
                from t_extrecords 
				where 
					processingStatus in ('New' , 'Open')
					and derivedCol_8 is not null   
					and derivedCol_2 is not null
					and jobId = vJobId
					and relationshipId = vrelationshipId 
                    and isDeleted = 'N'
				group by  derivedCol_2 ,  derivedCol_8 , amount_1 
				having count(*) =1 order by derivedCol_8
			)iq1 
			on e.derivedCol_2 = iq1.UTR 
            and e.derivedCol_8 = iq1.VendorName
			and e.amount_1 = iq1.Amount
		)oq1
	) q1
	inner join 
	(
		select  
		@row_number:=
			CASE
				WHEN @VendorName = oq2.VendorName THEN @row_number + 1
			ELSE 1
			END AS num,
		@VendorName:=VendorName as VendorName,
		oq2.Amount, oq2.intRecordsId
		from 
		(
			select i.intRecordsId,  replace(replace(i.derivedCol_8,'"',''),'.,','') as VendorName, i.referenceText_9, i.amount_1 as Amount
			from t_intrecords i 
            inner join 
			(
				select derivedCol_8 as VendorName,referenceText_9 AS CheckNumber, amount_1 AS Amount 
				from t_intrecords 
                where length(derivedCol_8) > 0 
					and length(referenceText_9) >0 
					and processingStatus in ('New' , 'Open')
                    and jobId = vJobId
					and relationshipId = vrelationshipId 
                    and isDeleted = 'N'
				GROUP BY derivedCol_8, referenceText_9,amount_1
				HAVING COUNT(*) =1 ORDER BY derivedCol_8
			)iq2 
            on i.derivedCol_8 = iq2.VendorName 
				and i.referenceText_9 = iq2.CheckNumber 
				and i.amount_1 = iq2.Amount
			where i.processingStatus = 'New'
		) oq2 
	)q2 on q1.VendorName = q2.VendorName and q1.Amount = q2.Amount;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_11_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS';

	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vupdateToken,
		i.jobExecutionId = vjobExecutionId
	where	
	i.jobId = vJobId
	and i.relationshipId = vrelationshipId	
    and r.processedDt = vupdateToken;      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY' ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vupdateToken,
		e.jobExecutionId = vjobExecutionId
	where	
	e.jobId = vJobId
	and e.relationshipId = vrelationshipId	
    and r.processedDt = vupdateToken;   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY';


	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	 ROLLBACK;
	 RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
	-- match cheque numbers (unique combination of cheque number & amount)
	INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		`ruleReference`,
        `jobExecutionId`,
        `relationshipId`
	)

	select q1.intRecordsId, q2.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vUpdateToken, vUserName, 'R1.1'  , vJobExecutionId,vRelationshipId
	from
    (
		select  intRecordsId,  i.jobId, i.relationshipId, i.derivedCol_1 as Cheque, i.amount_1 as Amount 
		from t_intrecords i force index (IDX_ITR_1)
        inner join 
		(	SELECT  derivedCol_1 ,  count(*) 
			FROM reco.t_intrecords 
			where 
				jobid=vJobId
				and relationshipid=vRelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
                and derivedCol_1 is not null 
			group by derivedCol_1  
			having count(*) =1 
		) iq1 
        on 
			iq1.derivedCol_1 = i.derivedCol_1 			 
            and i.jobId = vJobId
            and i.relationshipId= vRelationshipId
		where
			i.processingStatus in ('New', 'Open') 
			and i.isDeleted='N'			
	) q1 inner join 
	(
		select extRecordsId, jobId, e.relationshipId, e.derivedCol_1 as Cheque, e.amount_1 as Amount 
		from t_extrecords e FORCE INDEX (IDX_TER_1)
        inner join 
		(
			select derivedCol_1  , count(*) from reco.t_extrecords 
			where 
				derivedCol_1 is not null 
				and jobid=vJobId                
				and relationshipid=vRelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_1  
            having count(*) =1 
		) eq1
		on 
			eq1.derivedCol_1 = e.derivedCol_1			 
            and e.jobId = vJobId
            and e.relationshipId= vRelationshipId
        where
			e.processingStatus in ('New', 'Open') 
			and e.isDeleted='N'			
	) q2 
    on 
		q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId
		and q1.Cheque = q2.Cheque
		and q1.Amount=q2.Amount;

	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS R1.1';

	
	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vUpdateToken,
		i.jobExecutionId = vjobExecutionId,
        i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vUpdateToken    
	where	
		i.jobId = vJobId
		and i.relationshipId = vRelationshipId	
		and r.processedDt = vUpdateToken;      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R1.1'  ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r 
		on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vUpdateToken,
		e.jobExecutionId = vjobExecutionId,
        e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vUpdateToken    
	where	
		e.jobId = vJobId
		and e.relationshipId = vRelationshipId	
		and r.processedDt = vUpdateToken;   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY R1.1';

	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_1_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_1_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). 
     -- 1: Find all the ERP Records which are cheque numbers (included in referenceText_11 or referenceText_5). Refer BANK records and use derivedCol_1 column for Checque numbers. Store these combinations of ERP & BANK  in a Temp Table
	 -- 2: If records are found: Insert into RecoResults Table. Update the ERP & BANK Records with the GroupId's
     -- 3: Update the last generated GroupId in the recosettings table.
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_g_1;    
	create temporary table temp_group_g_1   
	   
    select q1.ERPUniqCode1, q1.ERPAmount, q2.BankUniqCode1, q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1)  +  @iMyRank  as GroupRank
	from
	(		
			SELECT  derivedCol_1 as ERPUniqCode1, 
			sum(case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			 end
			) as ERPAmount , count(*)  as ERPRowCount
			FROM reco.t_intrecords 
			where 
				jobid= vJobId              
				and relationshipid= vRelationshipid
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'		
				and derivedCol_1 is not null
			group by derivedCol_1
			having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_1 as BankUniqCode1, sum(case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			 end
			) as BankAmount, count(*)  as BankRowCount
			from reco.t_extrecords FORCE INDEX (IDX_TER_2)
			where 
				derivedCol_1 is not null                
				and jobid= vJobId
				and relationshipid= vRelationshipid
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_1 
			having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount = q2.BankAmount;
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_1_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R1G_AM_1' ;

	IF iRowCount >0 then  
       -- add to recoresults 1:Many matching.  
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select null, null , 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
				vUpdateToken, vUserName, 'R1_G_AM_1' , vJobExecutionId , vRelationShipId, GroupRank
		from temp_group_g_1;

		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_1_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULTS (1:Many) R1_G_AM_1' ;


		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
			inner  join temp_group_g_1 g on g.ERPUniqCode1=i.derivedCol_1			 
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vJobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
		i.jobId = vJobId
		and i.relationshipId = vRelationShipId;
 
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R1_G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
	 
		update t_extRecords e
			inner  join temp_group_g_1 g on g.BankUniqCode1 = e.derivedCol_1			 
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vJobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken   
		where	
			e.jobId = vJobId
			and e.relationshipId = vRelationShipId;
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R1_G_AM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_g_1;		
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId'; 
        
       
		
    END IF;
    
    drop temporary table temp_group_g_1;
 
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_1_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_1_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Nearest Match: Amount mismatch 
     -- 1: Find all the ERP Records which are cheque numbers (included in referenceText_11 or referenceText_5). Refer BANK records and use derivedCol_1 column for Checque numbers. Store these combinations of ERP & BANK  in a Temp Table
	 -- 2: If records are found: Insert into RecoResults Table. Update the ERP & BANK Records with the GroupId's
     -- 3: Update the last generated GroupId in the recosettings table.
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_g_1;    
	create temporary table temp_group_g_1   
	   
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q2.BankUniqCode1,  q2.BankUniqCode2, q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1)  +  @iMyRank  as GroupRank
	from
	(		
			SELECT  referenceText_11 as ERPUniqCode1, referenceDateTime_1 as ERPUniqCode2, 
			sum(case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			 end
			) as ERPAmount , count(*) as ERPRowCount 
			FROM reco.t_intrecords 
			where 
				jobid= vJobId              
				and relationshipid= vRelationshipid
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'		
				and referenceText_11 is not null
			group by referenceText_11
			having count(*) >= 1 		
	) q1 inner join 
	(
		select derivedCol_1 as  BankUniqCode1, referenceDateTime_1 as BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			 end
			) as BankAmount, count(*) 
			from reco.t_extrecords FORCE INDEX (IDX_TER_2)
			where 
				derivedCol_1 is not null                
				and jobid= vJobId
				and relationshipid= vRelationshipid
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_1 
			having count(*) >= 1  
	) q2 
	on 	 
		(			 
			instr(q1.ERPUniqCode1, q2.BankUniqCode1)>0
            or 
            instr( q2.BankUniqCode1, q1.ERPUniqCode1)>0
        )
        and  q2.BankUniqCode2 = q1.ERPUniqCode2
		and q1.ERPAmount = q2.BankAmount;

	SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R1_G_NM_1' ;


	IF iRowCount >0 then 		

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
			inner  join temp_group_g_1 g on g.ERPUniqCode1=i.referenceText_11	
            and g.ERPUniqCode2 = i.referenceDateTime_1
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vJobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vRelationShipId
			and i.processingStatus in ('New', 'Open') ;
	 
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R1_G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
	 
		update t_extRecords e
			inner  join temp_group_g_1 g on g.BankUniqCode1 = e.derivedCol_1	
            and g.BankUniqCode2 = e.referenceDateTime_1
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vJobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken   
		where	
			e.jobId = vJobId
			and e.relationshipId = vRelationShipId
            and e.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R1_G_NM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_g_1;		
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId'; 
        
       
		
    END IF;
    
    drop temporary table temp_group_g_1;
 
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_2_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_2_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		 `ruleReference`,
         `jobExecutionId`,
        `relationshipId`
	)	
        
	select q1.intRecordsId, q2.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vupdateToken, vUserName, 'R2.1'  , vJobExecutionId,vRelationshipId
	from
    (
		select  intRecordsId,  i.jobId, i.relationshipId, i.derivedCol_2 as UTR, i.amount_1 as Amount 
		from t_intrecords i force index (IDX_ITR_2)
        inner join 
		(	SELECT  derivedCol_2, count(*) 
			FROM reco.t_intrecords 
			where 
				jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'		
                and derivedCol_2 is not null
			group by derivedCol_2 
			having count(*) =1 
		) iq1 
        on 
			iq1.derivedCol_2 = i.derivedCol_2  
            and i.jobId = vJobId
            and i.relationshipId= vRelationshipId
		where
			i.processingStatus in ('New', 'Open') 
			and i.isDeleted='N'			
	) q1 inner join 
	(
		select extRecordsId, jobId, e.relationshipId, e.derivedCol_2 as UTR, e.amount_1 as Amount 
		from t_extrecords e FORCE INDEX (IDX_TER_2)
        inner join 
		(
			select derivedCol_2 ,  count(*) from reco.t_extrecords 
			where 
				derivedCol_2 is not null 
				and jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_2 
            having count(*) =1 
		) eq1
		on 
			eq1.derivedCol_2 = e.derivedCol_2 			
            and e.jobId = vJobId
            and e.relationshipId= vRelationshipId
        where
			e.processingStatus in ('New', 'Open') 
			and e.isDeleted='N'			
	) q2 
    on 
		q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId
		and q1.UTR = q2.UTR
		and q1.Amount=q2.Amount;

	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_2_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS R2.1';

	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vupdateToken,
		i.jobExecutionId = vjobExecutionId,
        i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vupdateToken    
	where	
	i.jobId = vJobId
	and i.relationshipId = vrelationshipId	
    and r.processedDt = vupdateToken;      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R2.1' ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vupdateToken,
		e.jobExecutionId = vjobExecutionId,
        e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vupdateToken    
	where	
	e.jobId = vJobId
	and e.relationshipId = vrelationshipId	
    and r.processedDt = vupdateToken;   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY R2.1';


	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_2_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_2_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (UTR)
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_2_g_1;    
    create temporary table temp_group_2_g_1    
    select q1.ERPUniqCode1  ,  q1.ERPAmount, 
    q2.BankUniqCode1  , q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_2 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_2 is not null
		group by derivedCol_2  
		having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_2 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_2 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_2 
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_2_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R2G_AM_1' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R2_G_AM_1'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_2_g_1;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_2_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R2_G_AM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_2_g_1 g
			on g.ERPUniqCode1 = i.derivedCol_2
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R2_G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_2_g_1 g
			on g.BankUniqCode1 = e.derivedCol_2
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N';
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R2G_AM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_2_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_2_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_2_G_AM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_2_G_AM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match. Search ERP Text for the UTR number. 
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_2_g_2;    
    create temporary table temp_group_2_g_2	
	select q1.ERPUniqCode1 , q1.ERPUniqCode2, q1.ERPAmount, q1.ERPRowCount,
    q2.BankUniqCode1 , q2.BankUniqCode2, q2.BankAmount, q2.BankRowCount ,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  referenceText_11 as ERPUniqCode1, referenceDateTime_1 as ERPUniqCode2,
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) as  ERPRowCount
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_2 is not null             
		group by referenceText_11  , referenceDateTime_1  
		having count(*) >= 1 		
	) q1 inner join 
	(
		select derivedCol_2 as BankUniqCode1 ,  referenceDateTime_1 BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*)  as BankRowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_2 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
            -- and derivedCol_2 ='BARBT18211581070'
		group by derivedCol_2 , referenceDateTime_1  
		having count(*) = 1  
	) q2 
	on 	 
		instr(q1.ERPUniqCode1, q2.BankUniqCode1) > 0
        and q1.ERPUniqCode2 = q2.BankUniqCode2
		and q1.ERPAmount = q2.BankAmount; 
		
	SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R2_G_AM_2' ;
		

	IF iRowCount >0 then  
			INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R2_G_AM_2'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_2_g_2;
	

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		
        update t_intrecords i
		inner join temp_group_2_g_2 t 
			on i.referenceText_11 = t.ERPUniqCode1
			and i.referenceDateTime_1 = t.ERPUniqCode2
		set i.groupid = t.GroupRank,
			i.lastUpdatedDt= vUpdateToken, 
			i.lastUpdatedBy = vUserName,
			i.processingStatus='Open',
            i.processingDateTime=vUpdateToken
		where i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N';   
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R2_G_AM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_2_g_2 t 
			on e.derivedCol_2 = t.BankUniqCode1
			and e.referenceDateTime_1 = t.BankUniqCode2	
		set e.groupid = t.GroupRank, 
			e.lastUpdatedDt= vUpdateToken, 
			e.lastUpdatedBy = vUserName,
            e.processingStatus='Open',
            e.processingDateTime=vUpdateToken
		where e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N';
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R2_G_AM_2' ;

		select @iMaxRank:=max(GroupRank) from temp_group_2_g_2;	
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON.
        
        drop temporary table temp_group_2_g_2;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_2_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_2_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (UTR)
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_2_g_1;    
    create temporary table temp_group_2_g_1    
    select q1.ERPUniqCode1 ,  q1.ERPAmount, 
    q2.BankUniqCode1  , q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_2 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_2 is not null
		group by derivedCol_2  
		having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_2 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_2 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_2 
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount <> q2.BankAmount;    

		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_2_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R2G_NM_1' ;


	IF iRowCount>0 then	
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_2_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R2G_NM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_2_g_1 g
			on g.ERPUniqCode1 = i.derivedCol_2
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R2G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_2_g_1 g
			on g.BankUniqCode1 = e.derivedCol_2
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N';
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R2G_NM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_2_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_2_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_2_G_NM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_2_G_NM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Nearest Match. Amount Variance. 
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_2_g_2;    
    create temporary table temp_group_2_g_2	
	select q1.ERPUniqCode1,  q1.ERPUniqCode2, q1.ERPAmount, q1.ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2 , q2.BankAmount, q2.BankRowCount,
	Rank () Over (Order by  q1.ERPUniqCode1, q1.ERPUniqCode2 )   + @iMyRank  as GroupRank
	from
	(		
		select  derivedCol_2 as ERPUniqCode1, referenceDateTime_1 ERPUniqCode2,
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) as  ERPRowCount
		from reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_2 is not null             
		group by derivedCol_2  , referenceDateTime_1  
		having count(*) >= 1 		
	) q1 inner join 
	(
		select derivedCol_2 as BankUniqCode1 ,  referenceDateTime_1 BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*)  as BankRowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_2 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
            -- and derivedCol_2 ='BARBT18211581070'
		group by derivedCol_2 , referenceDateTime_1  
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
        and q1.ERPUniqCode2 = q2.BankUniqCode2
		and q1.ERPAmount <> q2.BankAmount; 
		
	SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R2_G_NM_2' ;
		

	IF iRowCount >0 then    	
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		
        update t_intrecords i
		inner join temp_group_2_g_2 t 
			on i.derivedCol_2 = t.ERPUniqCode1
			and i.referenceDateTime_1 = t.ERPUniqCode2
		set i.groupid = t.GroupRank,
			i.lastUpdatedDt= vUpdateToken, 
			i.lastUpdatedBy = vUserName,
			i.processingStatus='Open',
            i.processingDateTime=vUpdateToken
		where i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N';   
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R2_G_NM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_2_g_2 t 
			on e.derivedCol_2 = t.BankUniqCode1
			and e.referenceDateTime_1 = t.BankUniqCode2	
		set e.groupid = t.GroupRank, 
			e.lastUpdatedDt= vUpdateToken, 
			e.lastUpdatedBy = vUserName,
            e.processingStatus='Open',
            e.processingDateTime=vUpdateToken
		where e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N';
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R2_G_NM_2' ;

		select @iMaxRank:=max(GroupRank) from temp_group_2_g_2;	
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON.
        
        drop temporary table temp_group_2_g_2;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_2_G_NM_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_2_G_NM_3`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Nearest Match. Date Variance. 
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_2_g_2;    
    create temporary table temp_group_2_g_2	
	select q1.ERPUniqCode1 , q1.ERPUniqCode2, q1.ERPAmount, q1.ERPRowCount,
    q2.BankUniqCode1 , q2.BankUniqCode2, q2.BankAmount, q2.BankRowCount ,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_2 as ERPUniqCode1, referenceDateTime_1 as ERPUniqCode2,
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) as  ERPRowCount
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_2 is not null             
		group by derivedCol_2  , referenceDateTime_1  
		having count(*) = 1 		
	) q1 inner join 
	(
		select derivedCol_2 as BankUniqCode1 ,  referenceDateTime_1 BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*)  as BankRowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_2 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
            -- and derivedCol_2 ='BARBT18211581070'
		group by derivedCol_2 , referenceDateTime_1  
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
        and q1.ERPUniqCode2 <> q2.BankUniqCode2
		and q1.ERPAmount = q2.BankAmount; 
		
	SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R2_G_NM_3' ;
		

	IF iRowCount >0 then    	
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		
        update t_intrecords i
		inner join temp_group_2_g_2 t 
			on i.derivedCol_2 = t.ERPUniqCode1
			and i.referenceDateTime_1 = t.ERPUniqCode2
		set i.groupid = t.GroupRank,
			i.lastUpdatedDt= vUpdateToken, 
			i.lastUpdatedBy = vUserName,
			i.processingStatus='Open',
            i.processingDateTime=vUpdateToken
		where i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N';   
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R2_G_NM_3' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_2_g_2 t 
			on e.derivedCol_2 = t.BankUniqCode1
			and e.referenceDateTime_1 = t.BankUniqCode2	
		set e.groupid = t.GroupRank, 
			e.lastUpdatedDt= vUpdateToken, 
			e.lastUpdatedBy = vUserName,
            e.processingStatus='Open',
            e.processingDateTime=vUpdateToken
		where e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N';
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R2_G_NM_3' ;

		select @iMaxRank:=max(GroupRank) from temp_group_2_g_2;	
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON.
        
        drop temporary table temp_group_2_g_2;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_3_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_3_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT; 
        
	ROLLBACK;    
	RESIGNAL;
	
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		 `ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)	
        
	select q1.intRecordsId, q2.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vupdateToken, vUserName, 'R3.1'  , vJobExecutionId,vRelationshipId
	from
    (
		select  intRecordsId,  i.jobId, i.relationshipId, i.derivedCol_3 as VendorName, i.referenceDateTime_1, 
        i.amount_1 as Amount , Soundex1
		from t_intrecords i  FORCE INDEX (IDX_ITR_3)
        inner join 
		(	SELECT  derivedCol_3 , referenceDateTime_1, amount_1, soundex(derivedCol_3) as Soundex1,  count(*) 
			FROM reco.t_intrecords FORCE INDEX (IDX_ITR_3)
			where 
				jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'				 
			group by soundex(derivedCol_3) , referenceDateTime_1, amount_1
			having count(*) =1 
		) iq1 
        on 
			iq1.derivedCol_3 = i.derivedCol_3
            and iq1.referenceDateTime_1 = i.referenceDateTime_1
			and iq1.amount_1 = i.amount_1   
            and i.jobId = vJobId
            and i.relationshipId= vRelationshipId
		where
			i.processingStatus in ('New', 'Open') 
			and i.isDeleted='N'			
	) q1 inner join 
	(
		select extRecordsId, jobId, e.relationshipId, e.derivedCol_3 as VendorName, e.amount_1 as Amount , 
        e.referenceDateTime_1, Soundex1
		from t_extrecords e FORCE INDEX (IDX_TER_3)
        inner join 
		(
			select derivedCol_3 ,referenceDateTime_1,  amount_1, soundex(derivedCol_3) as Soundex1, count(*) 
            from reco.t_extrecords FORCE INDEX (IDX_TER_3)
			where 
				derivedCol_3 is not null 
				and jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by soundex(derivedCol_3),referenceDateTime_1, amount_1 
            having count(*) =1 
		) eq1
		on 
			eq1.derivedCol_3 = e.derivedCol_3 
            and eq1.referenceDateTime_1 = e.referenceDateTime_1
			and eq1.amount_1 = e.amount_1
            and e.jobId = vJobId
            and e.relationshipId= vRelationshipId
        where
			e.processingStatus in ('New', 'Open') 
			and e.isDeleted='N'			
	) q2 
    on 
		q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId
        and ( instr(q1.Soundex1, q2.Soundex1) >0 or instr(q2.Soundex1, q1.Soundex1) >0)
        -- and (substring(q1.soundex1, 1,5) = substring(q2.soundex1, 1,5)  )  -- more aggressive match - Factor 5
		and q1.referenceDateTime_1 = q2.ReferenceDateTime_1
		and q1.Amount=q2.Amount;

	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_3_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS R3.1';

	IF iRowCount >0 THEN
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vupdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken         
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and r.processedDt = vupdateToken
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R3.1' ;
	 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vupdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId	
			and r.processedDt = vupdateToken
			and e.isDeleted='N';     
		
		SET iRowCount = ROW_COUNT();
		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY R3.1';

	END IF;
	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_3_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_3_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Auto Matching. Combination of (derivedCol_3 & ReferenceDateTime, Amount) and Text Pattern Matching using levenshtein_ratio.
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_3_G_1; 
    create temporary table temp_group_3_G_1
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  derivedCol_3 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2, soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_3)
		where 
			jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_3 is not null         
		group by soundex(derivedCol_3)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select derivedCol_3 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
        soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_3)
		where 
			derivedCol_3 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by soundex(derivedCol_3) , referenceDateTime_1 
		having count(*) >=1			
	) q2 
    on 
		(
			levenshtein_ratio(q1.ERPUniqcode1, q2.BankUniqcode1) <60
			and
			substring(q1.soundex1,1,5) = substring(q2.soundex1,1,5)
		)
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount = q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_3_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP R3G_AM_1';

	IF iRowCount >0 then    
    	
		-- Update RecoResults with 1:1 combination (ReferenceDateTime, Amount & Uniqcode1 Pattern)
        INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
            `groupId`
		)        
		select null, null,  'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , 
        vupdateToken, vUserName, 'R3G_AM_1'  , vJobExecutionId,vRelationshipId, groupRank
        from temp_group_3_G_1 t;
        
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_3G_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECO RESULTS R3G_AM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_3_G_1 g 
				on g.ERPUniqCode1 = i.derivedCol_3  
				and i.referenceDateTime_1  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_3 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R3G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_3_G_1 g 
				on g.BankUniqCode1 = e.derivedCol_3  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_3 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R3G_AM_1' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_3_G_1;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_3_G_1;
        
	
	END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_3_G_AM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_3_G_AM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Auto Matching. Combination of (derivedCol_3 & ReferenceDateTime, Amount) and Text Pattern Matching using levenshtein_ratio.
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_3_g_2; 
    create temporary table temp_group_3_g_2
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  derivedCol_3 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2, soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_3)
		where 
			jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_3 is not null         
		group by soundex(derivedCol_3)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select derivedCol_3 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
        soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_3)
		where 
			derivedCol_3 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by soundex(derivedCol_3) , referenceDateTime_1 
		having count(*) >=1			
	) q2 
    on 
		q1.soundex1 = q2.soundex1
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount = q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_3_G_AM_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 3_G_AM_2';

	IF iRowCount >0 then    
    	
		-- Update RecoResults with 1:1 combination (ReferenceDateTime, Amount & Uniqcode1 Pattern)
        INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
            `groupId`
		)        
		select null, null,  'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , 
        vupdateToken, vUserName, 'R3_G_AM_2'  , vJobExecutionId,vRelationshipId, groupRank
        from temp_group_3_g_2 t;
        
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_3G_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECO RESULTS 3_G_AM_2' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_3_g_2 g 
				on g.ERPUniqCode1 = i.derivedCol_3  
				and i.referenceDateTime_1  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_3 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 3_G_AM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_3_g_2 g 
				on g.BankUniqCode1 = e.derivedCol_3  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_3 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 3_G_AM_2' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_3_g_2;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_3_g_2;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_3_G_AM_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_3_G_AM_3`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Auto Matching. Combination of (referenceText_11 & ReferenceDateTime, Amount) and Text Pattern Matching using levenshtein_ratio.
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_3_g_3; 
    create temporary table temp_group_3_g_3
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  referenceText_11 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_3)
		where 
			jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and referenceText_11 like '%WITHDRAWAL TRANSFER--%'           
		group by referenceText_11  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select referenceText_1 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_3)
		where 
			referenceText_1 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
			and referenceText_1 like '%WITHDRAWAL TRANSFER--%'  
		group by referenceText_1 , referenceDateTime_1 
		having count(*) >=1			
	) q2 
    on 
		instr(q2.BankUniqcode1, q1.ERPUniqcode1) >0
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount = q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_3_G_AM_3 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 3_G_AM_3';

	IF iRowCount >0 then    
    	
		-- Update RecoResults with 1:1 combination (ReferenceDateTime, Amount & Uniqcode1 Pattern)
        INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
            `groupId`
		)        
		select null, null,  'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , 
        vupdateToken, vUserName, 'R3_G_AM_3'  , vJobExecutionId,vRelationshipId, groupRank
        from temp_group_3_g_3 t;
        
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_3G_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECO RESULTS 3_G_AM_3' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_3_g_3 g 
				on g.ERPUniqCode1 = i.referenceText_11  
				and i.referenceDateTime_1  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank,
            i.derivedCol_3  ='TVS MOTOR COMPANY LTD'
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.referenceText_11 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 3_G_AM_3' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_3_g_3 g 
				on g.BankUniqCode1 = e.referenceText_1 
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank,
            e.derivedCol_3  ='TVS MOTOR COMPANY LTD'            
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.referenceText_1 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 3_G_AM_3' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_3_g_3;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_3_g_3;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_3_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_3_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Nearest Matching (Amount Variance). Combination of (derivedCol_3 & ReferenceDateTime, Amount) and Text Pattern Matching using levenshtein_ratio.
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_3_g_1; 
    create temporary table temp_group_3_g_1
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  derivedCol_3 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2, soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords  
		where 
			jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_3 is not null         
		group by soundex(derivedCol_3)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select derivedCol_3 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
        soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords  
		where 
			derivedCol_3 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by soundex(derivedCol_3) , referenceDateTime_1 
		having count(*) >=1			
	) q2 
    on 
		(
			-- levenshtein_ratio(q1.ERPUniqcode1, q2.BankUniqcode1) <60
			-- and
			substring(q1.soundex1,1,5) = substring(q2.soundex1,1,5)
            or 
            q1.soundex1 = q2.soundex1
		)
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount <> q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_3_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 3_G_NM_1';

	IF iRowCount >0 then    
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_3_g_1 g 
				on g.ERPUniqCode1 = i.derivedCol_3  
				and i.referenceDateTime_1  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_3 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 3_G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_3_g_1 g 
				on g.BankUniqCode1 = e.derivedCol_3  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_3 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 3_G_NM_1' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_3_g_1;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_3_g_1;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_3_G_NM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_3_G_NM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Nearest Matching (Date Variance). Combination of (derivedCol_3 & ReferenceDateTime, Amount) and Text Pattern Matching using levenshtein_ratio.
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_3_g_2; 
    create temporary table temp_group_3_g_2
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  derivedCol_3 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2, soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_3)
		where 
			jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_3 is not null         
		group by soundex(derivedCol_3)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select derivedCol_3 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
        soundex(derivedCol_3) as Soundex1,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_3)
		where 
			derivedCol_3 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by soundex(derivedCol_3) , referenceDateTime_1 
		having count(*) >=1			
	) q2 
    on 
		(
			levenshtein_ratio(q1.ERPUniqcode1, q2.BankUniqcode1) <60
			and
			substring(q1.soundex1,1,5) = substring(q2.soundex1,1,5)
		)
		and q1.ERPUniqcode2 <> q2.BankUniqcode2
		and q1.ERPAmount = q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_3_G_NM_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP R3_G_NM_2';

	IF iRowCount >0 then    
    
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;       

		update t_intrecords i			
			inner join temp_group_3_g_2 g 
				on g.ERPUniqCode1 = i.derivedCol_3  
				and i.referenceDateTime_1  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_3 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R3_G_NM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_3_g_2 g 
				on g.BankUniqCode1 = e.derivedCol_3  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_3 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R3_G_NM_2' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_3_g_2;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_3_g_2;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_4_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_4_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	
	
     
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , null, 0, 'Error occurred in executing Matching Rule. Error:' + ifnull(@error_string, '');

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
	
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		`ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)	
    select q2.intRecordsId, q1.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vupdateToken, vUserName, 'R4.1' , vJobExecutionId, vRelationshipId
	from 
	(
		select e.jobId, e.relationshipId, e.extRecordsId,  eq1.BankUniqCode1, eq1.BankUniqCode2, e.amount_1 as BankAmount 
		from t_extrecords e 
		inner join 
		(
			select derivedCol_4 as BankUniqCode1, derivedCol_11 as BankUniqCode2 
			from t_extrecords 
			where   derivedCol_4 is not null 
				and processingStatus in ('New', 'Open')
				and jobId = vJobId
				and relationshipId = vRelationShipId
                and isDeleted = 'N'
			group by derivedCol_4 , derivedCol_11 
			having count(*) = 1
		) eq1 on (eq1.BankUniqCode1) = (e.derivedCol_4) 
			and (eq1.BankUniqCode2) = (e.derivedCol_11)			 
			and e.jobId = vJobId
			and e.relationshipId= vRelationshipId
	) q1 
	inner join
	(
		select i.jobId, i.relationshipId, i.intRecordsId, iq1.ERPUniqCode1 , iq1.ERPUniqCode2, i.amount_1 as ERPAmount
		from t_intrecords i 
		inner join  
		(
			select derivedCol_4 as ERPUniqCode1, derivedCol_11 as ERPUniqCode2  
			from t_intrecords 
			where derivedCol_4 is not null
				and jobId = vJobId
				and relationshipId = vRelationShipId
                and isDeleted = 'N'
				and processingStatus IN ('New','Open')
			group by derivedCol_4, derivedCol_11 
			having count(*) = 1
		) iq1 on (iq1.ERPUniqCode1) = (i.derivedCol_4)
			and (iq1.ERPUniqCode2) = (i.derivedCol_11)			 
			and i.jobId = vJobId
			and i.relationshipId= vRelationshipId
	) q2 
	on  (q1.BankUniqCode1) = (q2.ERPUniqCode1)
		and (q1.BankUniqCode2) = (q2.ERPUniqCode2)
		and q1.BankAmount = q2.ERPAmount
		and q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId;
    

	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_4_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULTS  R4.1' ;

	--
	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vUpdateToken,
		i.jobExecutionId = vjobExecutionId,
		i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vUpdateToken    
	where	
		i.jobId = vJobId
		and i.relationshipId = vrelationshipId	
		and r.processedDt = vUpdateToken
        and i.isDeleted='N';      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R4.1' ;

	-- 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vUpdateToken,
		e.jobExecutionId = vjobExecutionId,
		e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vUpdateToken    
	where	
		e.jobId = vJobId
		and e.relationshipId = vrelationshipId	
		and r.processedDt = vUpdateToken
        and e.isDeleted='N';   
    
	SET iRowCount = ROW_COUNT();	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R4.1' ;

	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_4_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_4_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        

	 ROLLBACK;
	 RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	-- match unique combinations of Text. Sample Data:
    -- Bank: TO TRANSFER-: "0999914BG0000974 01822243000001TF80102768062-TRANSFER TO 4599903099999-"
    -- ERP: "0999918GC0905807 00802615000001TF80102768062-TRANS"
    
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		 `ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)   
	select q1.intRecordsId, q2.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vUpdateToken, vUserName, 'R4.2'  , vJobExecutionId,vRelationshipId
	from
    (
		select  intRecordsId,  i.jobId, i.relationshipId, iq1.ERPUniqCode1, i.amount_1 as ERPAmount 
		from t_intrecords i force index (IDX_ITR_4)
        inner join 
		(	SELECT  derivedCol_4 as ERPUniqCode1 ,  count(*) 
			FROM reco.t_intrecords 
			where 
				jobid=vJobId
                and derivedCol_11 is null 
                and derivedCol_4 is not null 
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'				 
			group by derivedCol_4  
			having count(*) =1 
		) iq1 
        on 
			iq1.ERPUniqCode1 = i.derivedCol_4 			
            and i.jobId = vJobId
            and i.relationshipId= vRelationshipId
            and i.isDeleted='N'
		where
			i.processingStatus in ('New', 'Open') 
			and i.isDeleted='N'			
	) q1 inner join 
	(
		select extRecordsId, jobId, e.relationshipId, eq1.BankUniqCode1 , e.amount_1 as BankAmount 
		from t_extrecords e FORCE INDEX (IDX_TER_4)
        inner join 
		(
			select derivedCol_4 as BankUniqCode1,   count(*) from reco.t_extrecords 
			where 
				derivedCol_4 is not null 
                and derivedCol_11 is null 
				and jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_4 
            having count(*) =1 
		) eq1
		on 
			eq1.BankUniqCode1 = e.derivedCol_4 			
            and e.jobId = vJobId
            and e.relationshipId= vRelationshipId
            and e.isDeleted='N'
        where
			e.processingStatus in ('New', 'Open') 
			and e.isDeleted='N'			
	) q2 
    on 
		q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId
		and q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount=q2.BankAmount;
    
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_4_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS R4.2';

	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vupdateToken,
		i.jobExecutionId = vjobExecutionId
	where	
		i.jobId = vJobId
		and i.relationshipId = vrelationshipId	
		and r.processedDt = vupdateToken
        and i.isDeleted='N';      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R4.2' ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vupdateToken,
		e.jobExecutionId = vjobExecutionId
	where	
		e.jobId = vJobId
		and e.relationshipId = vrelationshipId	
		and r.processedDt = vupdateToken
        and e.isDeleted='N';   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY R4.2' ;


	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_4_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_4_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Auto Matching. Combination of (derivedCol_4 & ReferenceDateTime, Amount) and Text Pattern Matching using levenshtein_ratio.
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_4_g_1; 
    create temporary table temp_group_4_g_1
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  derivedCol_4 as ERPUniqcode1 , derivedCol_11 as ERPUniqCode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_4)
		where 
			jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_4 is not null  
			and derivedCol_11 is not null 
		group by derivedCol_4  , derivedCol_11 
		having count(*) >= 1 				
	) q1 
    inner join 
	(		
		select derivedCol_4 as BankUniqcode1, derivedCol_11 BankUniqcode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords FORCE INDEX (IDX_TER_4)
		where 
			derivedCol_4 is not null
            and derivedCol_11 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by (derivedCol_4) , derivedCol_11 
		having count(*) >=1			
	) q2 
    on 
		q1.ERPUniqcode1 = q2.BankUniqcode1
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount = q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_4_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP R4_G_AM_1';

	IF iRowCount >0 then    
    	
        INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
            `groupId`
		)        
		select null, null,  'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , 
        vupdateToken, vUserName, 'R4_G_AM_1'  , vJobExecutionId,vRelationshipId, groupRank
        from temp_group_4_g_1 t;
        
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_4_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECO RESULTS R4_G_AM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_4_g_1 g 
				on g.ERPUniqCode1 = i.derivedCol_4  
				and i.derivedCol_11  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_4 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R4_G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_4_g_1 g 
				on g.BankUniqCode1 = e.derivedCol_4  
				and e.derivedCol_11  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_4 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R4_G_AM_1' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_4_g_1;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_4_g_1;
        
	
	END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_4_G_AM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_4_G_AM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (Uniqcode)
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_4_g_2;    
    create temporary table temp_group_4_g_2    
    select q1.ERPUniqCode1,  ERPUniqCode2, q1.ERPAmount, 
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1, q1.ERPUniqCode2)   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_4 as ERPUniqCode1 , referenceDateTime_1 as ERPUniqCode2, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_4 is not null
		group by derivedCol_4, referenceDateTime_1 
		having count(*) >= 1 		
	) q1 inner join 
	(
		select derivedCol_4 as BankUniqCode1, referenceDateTime_1 as BankUniqCode2, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_4)
		where 
			derivedCol_4 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_4, referenceDateTime_1 
		having count(*) >= 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
        and q1.ERPUniqCode2 = q2.BankUniqCode2
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_4_G_AM_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R4G_AM_2' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R4_G_AM_2'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_4_g_2;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_4_G_AM_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R4_G_AM_2' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_4_g_2 g
			on g.ERPUniqCode1 = i.derivedCol_4
            and g.ERPUniqCode2= i.referenceDateTime_1
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N'
            and processingStatus in ('New', 'Open') ;      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R4_G_AM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_4_g_2 g
			on g.BankUniqCode1 = e.derivedCol_4
			and g.BankUniqCode2= e.referenceDateTime_1
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N'
            and processingStatus in ('New', 'Open') ;
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R4_G_AM_2' ;

		select @iMaxRank:=max(GroupRank) from temp_group_4_g_2;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_4_g_2;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_4_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_4_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Nearest Matching (Amount Variance). Combination of (derivedCol_4 & derivedCol_11) 
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_4_g_1; 
    create temporary table temp_group_4_g_1
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank as groupRank
	from
    (
		SELECT  derivedCol_4 as ERPUniqcode1 , derivedCol_11 as ERPUniqCode2,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords  
		where 
			jobid = vJobId
			and relationshipid = vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_4 is not null         
		group by (derivedCol_4)  , derivedCol_11 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select derivedCol_4 as BankUniqcode1, derivedCol_11 BankUniqcode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords  
		where 
			derivedCol_4 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by (derivedCol_4) , derivedCol_11 
		having count(*) >=1			
	) q2 
    on 
		q1.ERPUniqcode1 = q2.BankUniqcode1
		and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount <> q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_4_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 4_G_NM_1';

	IF iRowCount >0 then    
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_4_g_1 g 
				on g.ERPUniqCode1 = i.derivedCol_4  
				and i.derivedCol_11  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_4 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 4_G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_4_g_1 g 
				on g.BankUniqCode1 = e.derivedCol_4  
				and e.derivedCol_11  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_4 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 4_G_NM_1' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_4_g_1;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_4_g_1;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_4_G_NM_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_4_G_NM_2`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
  
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: Handles Many:Many combinations (ERP:Bank). Nearest Matching (Amount Variance). Combination of (derivedCol_4 & ReferenceDateTime) 
     -- 1: Populate a temp table with all  (1:Many) (Many:1) (Many:Many) Combinations
     -- 2: Update RecoResults table with 1:1 combination. Update ERP & Bank Tables respectively.
          
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId'; 
    
	drop temporary table if exists temp_group_4_g_2; 
    create temporary table temp_group_4_g_2
    select q1.ERPUniqCode1, q1.ERPUniqCode2, q1.ERPAmount, q1.RowCount as ERPRowCount,
    q2.BankUniqCode1, q2.BankUniqCode2, q2.BankAmount, q2.RowCount as BankRowCount,
    Rank () Over (Order by  q1.ERPUniqCode1,  q1.ERPUniqCode2 ) + @iMyRank  as groupRank
	from
    (
		SELECT  derivedCol_4 as ERPUniqcode1 , referenceDateTime_1 as ERPUniqCode2,
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as ERPAmount , count(*) as RowCount
		FROM reco.t_intrecords  
		where 
			jobid = vJobId
			and relationshipid = vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'	
			and derivedCol_4 is not null         
		group by (derivedCol_4)  , referenceDateTime_1 
		having count(*) >= 1 				
	) q1 inner join 
	(		
		select derivedCol_4 as BankUniqcode1, referenceDateTime_1 BankUniqcode2, 
		sum(
			case when abs(debitAmount) > 0 then debitAmount
				when abs(creditAmount) > 0 then creditAmount
			end
			) as BankAmount, count(*)  as RowCount
		from reco.t_extrecords  
		where 
			derivedCol_4 is not null 
			and jobid= vJobId
			and relationshipid= vRelationshipId
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by (derivedCol_4) , referenceDateTime_1 
		having count(*) >=1			
	) q2 
    on 
		q1.ERPUniqcode1 = q2.BankUniqcode1
		-- and q1.ERPUniqcode2 = q2.BankUniqcode2
		and q1.ERPAmount <> q2.BankAmount ;
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_4_G_NM_2 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'TEMP 4_G_NM_2';

	IF iRowCount >0 then    
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;        

		update t_intrecords i			
			inner join temp_group_4_g_2 g 
				on g.ERPUniqCode1 = i.derivedCol_4  
				and i.referenceDateTime_1  = g.ERPUniqCode2
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,		
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName,
			i.lastUpdatedDt = vUpdateToken,
            i.groupId = g.groupRank
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId
            and i.isDeleted='N'
            and i.derivedCol_4 is not null
            and i.processingStatus in ('New', 'Open') ;
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY 4_G_NM_2' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e		
			inner join temp_group_4_g_2 g 
				on g.BankUniqCode1 = e.derivedCol_4  
				and e.referenceDateTime_1  = g.BankUniqCode2 
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,		
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName,
			e.lastUpdatedDt = vUpdateToken,
            e.groupId = g.groupRank
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
            and e.isDeleted='N'
            and e.derivedCol_4 is not null
            and e.processingStatus in ('New', 'Open') ;
            
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY 4_G_NM_2' ;



		-- set the group id
		select @iMaxRank:= max(GroupRank) from temp_group_4_g_2;       
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
	
		-- TODO : populate the groupRecords JSON with all ERP & BANK Primary ID's
		drop temporary table temp_group_4_g_2;
        
	COMMIT;
	END IF;
    
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_5_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_5_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;     
	ROLLBACK;
	RESIGNAL;
END;



SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		 `ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)	
        
	select q1.intRecordsId, q2.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vUpdateToken, vUserName, 'R5.1'  , vJobExecutionId,vRelationshipId
	from
    (
		select  intRecordsId,  i.jobId, i.relationshipId, i.derivedCol_5 as UniqCode, i.amount_1 as Amount 
		from t_intrecords i force index (IDX_ITR_5)
        inner join 
		(	SELECT  derivedCol_5,  count(*) 
			FROM reco.t_intrecords 
			where 
				jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'				 
			group by derivedCol_5  
			having count(*) =1 
		) iq1 
        on 
			iq1.derivedCol_5 = i.derivedCol_5			 
            and i.jobId = vJobId
            and i.relationshipId= vRelationshipId
		where
			i.processingStatus in ('New', 'Open') 
			and i.isDeleted='N'			
	) q1 inner join 
	(
		select extRecordsId, jobId, e.relationshipId, e.derivedCol_5 as UniqCode, e.amount_1 as Amount 
		from t_extrecords e FORCE INDEX (IDX_TER_5)
        inner join 
		(
			select derivedCol_5 , count(*) from reco.t_extrecords 
			where 
				derivedCol_5 is not null 
				and jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_5 
            having count(*) =1 
		) eq1
		on 
			eq1.derivedCol_5 = e.derivedCol_5 
            and e.jobId = vJobId
            and e.relationshipId= vRelationshipId
        where
			e.processingStatus in ('New', 'Open') 
			and e.isDeleted='N'			
	) q2 
    on 
		q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId
		and q1.UniqCode = q2.UniqCode
		and q1.Amount=q2.Amount;

	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_5_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS R5.1';

	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
		inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vupdateToken,
		i.jobExecutionId = vjobExecutionId,
		i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vUpdateToken    
	where	
		i.jobId = vJobId
		and i.relationshipId = vrelationshipId	
		and r.processedDt = vupdateToken;      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R5.1' ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
		inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vupdateToken,
		e.jobExecutionId = vjobExecutionId,
        e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vUpdateToken    
	where	
		e.jobId = vJobId
		and e.relationshipId = vrelationshipId	
		and r.processedDt = vupdateToken;   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY R5.1';


	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_5_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_5_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match (UTR)
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_5_g_1;    
    create temporary table temp_group_5_g_1    
    select q1.ERPUniqCode1  ,  q1.ERPAmount, 
    q2.BankUniqCode1  , q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_5 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_5 is not null
		group by derivedCol_5  
		having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_5 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_5 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_5 
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_5_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R5G_AM_1' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R5_G_AM_1'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_5_g_1;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_5_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R5_G_AM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_5_g_1 g
			on g.ERPUniqCode1 = i.derivedCol_5
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R5_G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_5_g_1 g
			on g.BankUniqCode1 = e.derivedCol_5
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N';
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R2G_AM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_5_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_5_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_5_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_5_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Nearest Match
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_5_g_1;    
    create temporary table temp_group_5_g_1    
    select q1.ERPUniqCode1  ,  q1.ERPAmount, 
    q2.BankUniqCode1  , q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_5 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_5)
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_5 is not null
		group by derivedCol_5  
		having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_5 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_5)
		where 
			derivedCol_5 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_5 
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount <> q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_5_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R5G_AM_1' ;

	IF iRowCount >0 then  
		
		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_5_g_1 g
			on g.ERPUniqCode1 = i.derivedCol_5
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R5_G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_5_g_1 g
			on g.BankUniqCode1 = e.derivedCol_5
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N';
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R5G_NM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_5_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_5_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_7_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_7_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
BEGIN	
	SET vReturn = -1;
	
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
	
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`,`comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'ERROR' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'Error occurred in executing Matching Rule. Error:' + @error_string;

	 ROLLBACK;
	 RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	 INSERT INTO `reco`.`t_recoresults`
	( 
		`t_intRecordId`,
		`t_extRecordId`,
		`recoStatus`,
		`recoCategory`,
		`recoSubCategory`,
		`isActive`,
		`processedDt`,
		`processedBy`,
		`ruleReference`,
		`jobExecutionId`,
        `relationshipId`
	)	
        
	select q1.intRecordsId, q2.extRecordsId, 'MATCHED', 'SYSTEM-MATCHED', NULL, 'Y' , vupdateToken, vUserName, 'R7.1'  , vJobExecutionId,vRelationshipId
	from
    (
		select  intRecordsId,  i.jobId, i.relationshipId, i.derivedCol_7 as Cheque, i.amount_1 as Amount 
		from t_intrecords i force index (IDX_ITR_1)
        inner join 
		(	SELECT  derivedCol_7 , count(*) 
			FROM reco.t_intrecords 
			where 
				jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'				 
			group by derivedCol_7  
			having count(*) =1 
		) iq1 
        on 
			iq1.derivedCol_7 = i.derivedCol_7			 
            and i.jobId = vJobId
            and i.relationshipId= vRelationshipId
		where
			i.processingStatus in ('New', 'Open') 
			and i.isDeleted='N'			
	) q1 inner join 
	(
		select extRecordsId, jobId, e.relationshipId, e.derivedCol_7 as Cheque, e.amount_1 as Amount 
		from t_extrecords e FORCE INDEX (IDX_TER_1)
        inner join 
		(
			select derivedCol_7 , count(*) from reco.t_extrecords 
			where 
				derivedCol_7 is not null 
				and jobid=vJobId
				and relationshipid=vrelationshipId
				and processingStatus in ('New', 'Open') 
				and isDeleted='N'
			group by derivedCol_7 
            having count(*) =1 
		) eq1
		on 
			eq1.derivedCol_7 = e.derivedCol_7			 
            and e.jobId = vJobId
            and e.relationshipId= vRelationshipId
        where
			e.processingStatus in ('New', 'Open') 
			and e.isDeleted='N'			
	) q2 
    on 
		q1.jobid=q2.jobid
		and q1.relationshipid=q2.relationshipId
		and q1.Cheque = q2.Cheque
		and q1.Amount=q2.Amount; 
    
	
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_7_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'RECORESULTS R7.1';

	SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
    update t_intrecords i
    inner join t_recoresults r on i.intRecordsId = r.t_intRecordId
	set  
		i.processingStatus = 'Processed' ,
		i.processingDateTime = vupdateToken,
		i.jobExecutionId = vjobExecutionId,
		i.isMatched = 'Y',
        i.lastUpdatedBy = vUserName ,
		i.lastUpdatedDt = vUpdateToken 
	where	
	i.jobId = vJobId
	and i.relationshipId = vrelationshipId	
    and r.processedDt = vupdateToken;      
    
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R7.1' ;
 
	SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
    update t_extrecords e
    inner join t_recoresults r on e.extRecordsId = r.t_extRecordId
	set  
		e.processingStatus = 'Processed' ,
		e.processingDateTime = vupdateToken,
		e.jobExecutionId = vjobExecutionId,
        e.isMatched = 'Y',
        e.lastUpdatedBy = vUserName ,
		e.lastUpdatedDt = vUpdateToken 
	where	
	e.jobId = vJobId
	and e.relationshipId = vrelationshipId	
    and r.processedDt = vupdateToken;   
    
	SET iRowCount = ROW_COUNT();
	
   	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()) , 'SECONDARY R7.1';


	
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_7_G_AM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_7_G_AM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Auto Match.
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_7_g_1;    
    create temporary table temp_group_7_g_1    
    select q1.ERPUniqCode1  ,  q1.ERPAmount, 
    q2.BankUniqCode1  , q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_7 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords 
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_7 is not null
		group by derivedCol_7  
		having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_7 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_2)
		where 
			derivedCol_7 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_7 
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount = q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_7_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R7_G_AM_1' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R7_G_AM_1'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_7_g_1;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_7_G_AM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R7_G_AM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_7_g_1 g
			on g.ERPUniqCode1 = i.derivedCol_7
		set  
			i.processingStatus = 'Processed' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'Y',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R7_G_AM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_7_g_1 g
			on g.BankUniqCode1 = e.derivedCol_7
		set  
			e.processingStatus = 'Processed' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'Y',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N';
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R7_G_AM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_7_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_7_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_7_G_NM_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_7_G_NM_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vUpdateToken DATETIME;
DECLARE iMyRank INT ;
DECLARE iMaxRank INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;	

	 ROLLBACK;
	 RESIGNAL;
END;

SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vUpdateToken = now();
    
     -- Grouped Records: 1:Many combinations (Bank:ERP). Nearest Match
     
    select @iMyRank:=settingValue from recoSettings where  settingKey='GroupSeqId';
    
    drop temporary table if exists temp_group_7_g_1;    
    create temporary table temp_group_7_g_1    
    select q1.ERPUniqCode1  ,  q1.ERPAmount, 
    q2.BankUniqCode1  , q2.BankAmount,
	Rank () Over (Order by  q1.ERPUniqCode1 )   + @iMyRank  as GroupRank
	from
	(		
		SELECT  derivedCol_7 as ERPUniqCode1, 
		sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as ERPAmount , count(*) 
		FROM reco.t_intrecords FORCE INDEX (IDX_ITR_7)
		where 
			jobid = vJobId              
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'		
			and derivedCol_7 is not null
		group by derivedCol_7  
		having count(*) > 1 		
	) q1 inner join 
	(
		select derivedCol_7 as BankUniqCode1, 
        sum(case when abs(debitAmount) > 0 then debitAmount
			when abs(creditAmount) > 0 then creditAmount
		 end
		) as BankAmount,  count(*) 
		from reco.t_extrecords FORCE INDEX (IDX_TER_7)
		where 
			derivedCol_7 is not null                
			and jobid= vJobId
			and relationshipid = vRelationshipid
			and processingStatus in ('New', 'Open') 
			and isDeleted='N'
		group by derivedCol_7 
		having count(*) = 1  
	) q2 
	on 	 
		q1.ERPUniqCode1 = q2.BankUniqCode1
		and q1.ERPAmount <> q2.BankAmount;   
        
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_MR_7_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
	SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'TEMP R5G_AM_1' ;

	IF iRowCount >0 then  
		
		INSERT INTO `reco`.`t_recoresults`
		( 
			`t_intRecordId`,
			`t_extRecordId`,
			`recoStatus`,
			`recoCategory`,
			`recoSubCategory`,
			`isActive`,
			`processedDt`,
			`processedBy`,
			`ruleReference`,
			`jobExecutionId`,
			`relationshipId`,
			`groupId`
		)	
		select  null, null, 'MATCHED', 'SYSTEM-MATCHED', 'GROUPED', 'Y' , 
		vupdateToken, vUserName, 'R7_G_NM_1'  , vJobExecutionId, vRelationshipId, GroupRank
		from temp_group_7_g_1;
		
		
		SET iRowCount = ROW_COUNT();
		SELECT '	P_0001_MR_7_G_NM_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();	 
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'RECORESULT R7_G_NM_1' ;

		-- Update the Group Id as well
		SELECT '	UPDATING PRIMARY SOURCE STATUS' ;
		update t_intrecords i
		inner join temp_group_7_g_1 g
			on g.ERPUniqCode1 = i.derivedCol_7
		set  
			i.processingStatus = 'Open' ,
			i.processingDateTime = vUpdateToken,
			i.jobExecutionId = vjobExecutionId,
			i.groupId = g.GroupRank,
			i.isMatched = 'N',
			i.lastUpdatedBy = vUserName ,
			i.lastUpdatedDt = vUpdateToken   
		where	
			i.jobId = vJobId
			and i.relationshipId = vrelationshipId	
			and i.isDeleted='N';      
		
		SET iRowCount = ROW_COUNT();
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY R7_G_NM_1' ;

		-- Update the Group Id as well 
		SELECT '	UPDATING SECONDARY SOURCE STATUS' ;
		update t_extrecords e
		inner join temp_group_7_g_1 g
			on g.BankUniqCode1 = e.derivedCol_7
		set  
			e.processingStatus = 'Open' ,
			e.processingDateTime = vUpdateToken,
			e.jobExecutionId = vjobExecutionId,
			e.groupId = g.GroupRank,
			e.isMatched = 'N',
			e.lastUpdatedBy = vUserName ,
			e.lastUpdatedDt = vUpdateToken    
		where	
			e.jobId = vJobId
			and e.relationshipId = vrelationshipId
			and e.isDeleted='N';
		   
		
		SET iRowCount = ROW_COUNT();		
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
		SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY R7_G_NM_1' ;

		select @iMaxRank:=max(GroupRank) from temp_group_7_g_1;
		update recoSettings 
			set settingValue = @iMaxRank where settingKey='GroupSeqId';
		
        -- TODO: Update groupedRecords JSON   
    
        drop temporary table temp_group_7_g_1;
		
    END IF;
    
    COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_MR_CLEANUP_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_MR_CLEANUP_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN



DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	SET vUpdateToken = now();
    
	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;    
	
	ROLLBACK;
	RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	
    update t_extRecords
    set processingStatus= 'Open', processingDateTime=vupdateToken, jobExecutionId=vJobExecutionId
    where processingStatus in ('New', 'Open')
		and jobId=vJobId
		and relationshipId=vRelationshipId
		and isDeleted='N';    
    
    SET iRowCount = ROW_COUNT();
    
    SELECT '	P_0001_MR_CLEANUP_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW() ;
    
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'SECONDARY OPEN' ;
 
	
	update t_intRecords
    set processingStatus= 'Open', processingDateTime=vupdateToken, jobExecutionId=vJobExecutionId
    where processingStatus in ('New', 'Open')
		and jobId=vJobId
		and relationshipId=vRelationshipId
		and isDeleted='N';
	
    SET iRowCount = ROW_COUNT();
	INSERT INTO `reco`.`etl_recoexecutionlog`
	(`jobId`,`executionId`,`taskId`,`startDt`,`endDt`,`status`,`rowCount`,`duration`, `comments`)   
    SELECT vJobId, vJobExecutionId, vTaskid, vUpdateToken, now(), 'SUCCESS' , iRowCount, TIMESTAMPDIFF(SECOND , vUpdateToken,  now()), 'PRIMARY OPEN' ;
 
 
	select @minIntDate:= min(referenceDateTime_1), @maxIntDate:=max(referenceDateTime_1), @intRows:= count(*)  from t_intrecords where jobExecutionId = vJobExecutionId ;
	select @minExtDate:= min(referenceDateTime_1), @maxExtDate:=max(referenceDateTime_1), @extRows:= count(*)  from t_extrecords where jobExecutionId = vJobExecutionId ;
	
	update etl_jobExecutions
		set
			executionEndDt  = now(),
			duration = TIMESTAMPDIFF(SECOND, executionStartDt, now() ),
			executedBy  = vUserName,
			executionStatus = 'SUCCESS',
			totalRecordsInt =  @intRows,
			totalRecordsExt =  @extRows,
			intFromDate = @minIntDate,
			intToDate = @maxIntDate,
			extFromDate = @minExtDate,
			extToDate = @maxExtDate        
	where jobExecutionId = vJobExecutionId ;
    
	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_VL_ERP_1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_VL_ERP_1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	ROLLBACK;
	RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	

	-- SET iRowCount = ROW_COUNT();
	-- SELECT '	P_0001_VL_ERP_1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
  
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_0001_VL_SBI_1_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_0001_VL_SBI_1_1`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT  , vUserName VARCHAR(16), vTaskId INT, OUT vReturn INT )
BEGIN


DECLARE vProcessingStatus VARCHAR(16)  ;
DECLARE iRowCount INT;
DECLARE vupdateToken DATETIME;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	SET vReturn = -1;
	ROLLBACK;
	RESIGNAL;
END;


SET vProcessingStatus = 'New';
SET vReturn = 0;

	START TRANSACTION;
    SET vupdateToken = now();
	
	
	
	

    
	SET iRowCount = ROW_COUNT();
	SELECT '	P_0001_VL_ERP_1_1 -> ROWS UPDATED:' , CONCAT(iRowCount), '	TIME:', NOW();
	
    
  
    
 	COMMIT;
	SET vReturn = 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_ETL_MAIN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_ETL_MAIN`(  vOrgId INT,   vRelationshipId INT,   vRelationshipCode VARCHAR(16)  , vJobId INT,   vJobExecutionId INT , vUserName VARCHAR(16), vStartLevelId INT, vStartSeqId INT)
BEGIN


DECLARE iTotalRows INT;
DECLARE iCurrentRow INT;

DECLARE sParameters varchar(255);
DECLARE sExecutionCode varchar(64);
DECLARE iTaskId INT;
DECLARE sOnSuccess varchar(16);
DECLARE sOnError varchar(16);

DECLARE iReturn INT;

DECLARE EXIT handler for SQLEXCEPTION,SQLWARNING
BEGIN	
	
   	GET DIAGNOSTICS CONDITION 1
		@code = RETURNED_SQLSTATE, @error_string = MESSAGE_TEXT;        
		
        select @error_string;
        
		INSERT INTO `reco`.`etl_recoexecutionlog`
		(`jobId`,`executionId`,`taskId`, `startDt`, `endDt`,`status`,`rowCount`,`duration`,`comments`)   
		SELECT vJobId, vJobExecutionId, iTaskId, now(), now(), 'ERROR' , null , null , CONCAT('Error occurred in ETL Execution!!!. Error:' , IFNULL(@error_string,'') );
		
		RESIGNAL;
END;

SET @sQuery = '';
SET @iReturn = 0;

create temporary table  if not exists temp_reco_tasks
select     
	   ( select @rownum := @rownum + 1 from ( select @rownum := 0 ) d2 ) 
	   as rowId,
	   q.*
from 
(
	select t.taskName, t.taskId, t.phase, t.taskType, t.onSuccess, t.onError, r.executionCode, r.ruleDescription, t.level, t.sequence
	from etl_recotasks t 
	inner join etl_recorules r on t.ruleId=r.ruleId  
	where t.jobId = vjobId
		and t.relationshipId = vrelationshipId
		and t.isActive = 'Y' 
		and r.isActive = 'Y'
		and t.relationshipId = r.relationshipId     
        and t.taskType='DBPROC'
        and t.level >= ( CASE WHEN vStartLevelId >0 then vStartLevelId ELSE 1 END) 
        and t.sequence >= ( CASE WHEN t.level = vStartLevelId then vStartSeqId ELSE 1 END) 
	order by t.level, t.sequence
) q;

SELECT COUNT(*) INTO iTotalRows FROM temp_reco_tasks;
set iCurrentRow = 1;

select taskName as  Activities , level ,  sequence, onError, onSuccess  from temp_reco_tasks;
-- SELECT 'INITIATING BUSINESS LOGIC FOR RECONCILIATION' AS Activity;
dynaSQL:BEGIN
IF (iTotalRows >0) THEN 	
	WHILE (iCurrentRow <= iTotalRows) DO		
        select executionCode, taskId, onSuccess, onError  into sExecutionCode, iTaskId, sOnSuccess, sOnError 
        from temp_reco_tasks where rowId = iCurrentRow;    
        
        set sParameters = concat('(' , vOrgId, ',' , vRelationshipId, ',''', vRelationshipCode , ''',', vJobId, ',', vJobExecutionId ,  ',''', vUserName, ''',', iTaskId , ',',  '@iReturn' ');');        
        SET @sQuery = CONCAT('CALL ',sExecutionCode , sParameters)  ;   
		 
		SELECT 'EXECUTING PROCEDURE:-->' as Activity, sExecutionCode AS ProcName, now() as StartTime;
		PREPARE stmt FROM @sQuery;       
		EXECUTE stmt ;
		DEALLOCATE PREPARE stmt;    
        
		-- SELECT sOnError, @ireturn,sExecutionCode,vJobExecutionId, @error_string ;
        
        IF (@iReturn <=0) THEN	
			SELECT 'ERROR occurred. Please refer to Execution Log for more details!!!!' as Error,@p2 as ErrorDescription;
			
            UPDATE etl_jobExecutions 
            SET executionStatus='ERROR', executionEndDt=now(),
				comments=CONCAT('Error in executing procedure:', sExecutionCode, '. Error Message:',@p2) , 
				duration=TIMESTAMPDIFF(SECOND,executionStartDt, now())
            WHERE jobExecutionId=vJobExecutionId;    
            
            IF(sOnError='STOP') THEN
				SET @iReturn = -1;
				LEAVE dynaSQL;
			END IF;
		END IF;
        
		SET iCurrentRow = iCurrentRow + 1;
        SET sExecutionCode ='';
        SET @iReturn = 1;
	END WHILE;	
END IF;

END;   -- END  THE BLOCK dynaSQL

drop temporary table IF EXISTS temp_reco_tasks;

 


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_RECOTOOLS_CREATE_NEWEXECUTIONID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_RECOTOOLS_CREATE_NEWEXECUTIONID`(  vJobId INT,   vUserName VARCHAR(16))
BEGIN
-- vJobId INT,   vUserName VARCHAR(16), OUT vGeneratedId INT
DECLARE vGeneratedId INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	ROLLBACK;
	RESIGNAL;
END;

	set vGeneratedId=0;
	
    -- if not exists (select 1 from etl_jobexecutions where jobId=vJobId and executionStatus='INPROGRESS') then
    START TRANSACTION;
	INSERT INTO `reco`.`etl_jobexecutions`
	( 
		`jobId`,
		`executionStartDt`,		 
		`executedBy`,
		`executionStatus`
	)
	VALUES ( vJobId , now(), vUserName, 'INPROGRESS'); 
 	COMMIT;
    SET vGeneratedId = LAST_INSERT_ID();
    -- else
	--	SET vGeneratedId =-1;
    -- end if;    
	 
    SELECT vGeneratedId;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_RECOTOOLS_CREATE_NEWIMPORTID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_RECOTOOLS_CREATE_NEWIMPORTID`(  vJobId INT, vRelationshipId INT, vCounterPartyId INT,  vFileName varchar(255), vFileSize INT, vURL varchar(255), vUserName VARCHAR(16))
BEGIN

DECLARE vGeneratedId INT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	ROLLBACK;
	RESIGNAL;
END;

	set vGeneratedId=0;
	
     
    START TRANSACTION;
    
	INSERT INTO `reco`.`etl_dataimports`
	( jobId, relationshipId, counterPartyId, sourceType, extractionType, fileName, fileSizeBytes, downloadURL, status, lastUpdatedBy, lastUpdatedDt)    
    VALUES ( vJobId, vRelationshipId, vCounterPartyId, 'FILE', 'UPLOAD',  vFileName, vFileSize, vURL, 'INPROGRESS',  vUserName, now()); 
    
 	COMMIT;
    SET vGeneratedId = LAST_INSERT_ID();    
	 
    SELECT vGeneratedId;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_RECOTOOLS_UPDATE_EXECUTIONDETAILS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_RECOTOOLS_UPDATE_EXECUTIONDETAILS`(  vExecutionId INT,   vUserName VARCHAR(16), vStatus varchar(16))
BEGIN
-- vJobId INT,   vUserName VARCHAR(16), OUT vGeneratedId INT
 

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	ROLLBACK;
	RESIGNAL;
END;
 
    
    START TRANSACTION;
	
    UPDATE etl_jobexecutions
    SET 
		executionStatus=vStatus,
		executionEndDt=now(),
        duration=TIMESTAMPDIFF(SECOND,executionStartDt, now()),
        executedBy=vUserName
    WHERE
    jobExecutionId=vExecutionId;
	
 	COMMIT;
   

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `P_RECOTOOLS_UPDATE_IMPORTDETAILS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`reco`@`localhost` PROCEDURE `P_RECOTOOLS_UPDATE_IMPORTDETAILS`(  vImportId INT, vReferenceFromDate DATETIME,  vReferenceToDate DATETIME,vRowCount INT,  vUserName VARCHAR(16), vStatus varchar(16))
BEGIN
-- vJobId INT,   vUserName VARCHAR(16), OUT vGeneratedId INT
 

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN	
	ROLLBACK;
	RESIGNAL;
END;
 
    
    START TRANSACTION;
	
    UPDATE etl_dataimports
    SET 
		status=vStatus,
		referenceFromDate = vReferenceFromDate,
        referenceToDate = vReferenceToDate,
        rowCount= vRowCount,
        lastUpdatedBy=vUserName,
        lastUpdatedDt=now(),
        duration=TIMESTAMPDIFF(SECOND,lastUpdatedDt, now()),
        executedBy=vUserName
    WHERE
    importId=vImportId;
	
 	COMMIT;
   

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `test1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `test1`()
BEGIN


DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
SHOW ERRORS LIMIT 1;

-- SHOW WARNINGS LIMIT 1;
BEGIN	
	 SET @iNewId =  -1;
    -- GET DIAGNOSTICS CONDITION 1
		-- @p1 = RETURNED_SQLSTATE,  @p2 = MESSAGE_TEXT;
	-- SELECT 'SQLException encountered:', @p1, @p2;
    ROLLBACK;
	-- RESIGNAL;
END;

dyanSQL:BEGIN
	SET @sQuery = 'call reco.P_RECOTOOLS_CREATE_NEWEXECUTIONID_1(1, ''recoadmin'', @iNewId);';
-- SET @sQuery = 'set @iNewId = (call reco.P_RECOTOOLS_CREATE_NEWEXECUTIONID_1(1, ''recoadmin''));';
-- CALL P_RECOTOOLS_CREATE_NEWEXECUTIONID_1 ( 1,''recoadmin'');' ;   
-- select @sQuery;
		 
		-- SELECT 'EXECUTING PROCEDURE:-->' as Activity, sExecutionCode AS ProcName, now() as StartTime;
		PREPARE stmt FROM @sQuery;       
		EXECUTE stmt ;
		DEALLOCATE PREPARE stmt;  
       
        IF @iNewId <=0 THEN
			LEAVE dyanSQL;
		END IF;
		SELECT 'SQLException encountered:', @p1, @p2;
        SELECT @iNewId ;
END;
        
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:37
