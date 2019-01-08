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
-- Table structure for table `t_extrecords`
--

DROP TABLE IF EXISTS `t_extrecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_extrecords` (
  `extRecordsId` int(11) NOT NULL AUTO_INCREMENT,
  `jobId` int(11) NOT NULL,
  `jobExecutionId` int(11) NOT NULL,
  `jobImportId` int(11) NOT NULL,
  `organizationId` int(11) NOT NULL,
  `relationshipId` int(11) NOT NULL,
  `sourceRowId` int(11) NOT NULL,
  `currencyId` int(11) NOT NULL,
  `recordType` varchar(16) NOT NULL COMMENT 'Either "Header", "Footer", "Row"',
  `transactionType` varchar(32) DEFAULT NULL COMMENT '''''DR'''', ''''CR''''',
  `trasactionSubType` varchar(32) DEFAULT NULL,
  `processingStatus` varchar(16) NOT NULL DEFAULT 'New' COMMENT 'Refer Lookup Table (RECO_IMPORTOVERALLSTATUS): New, Completed, Pending, Derived',
  `processingDateTime` datetime DEFAULT NULL,
  `referenceText_1` varchar(512) DEFAULT NULL,
  `referenceText_2` varchar(512) DEFAULT NULL,
  `referenceText_3` varchar(512) DEFAULT NULL,
  `referenceText_4` varchar(512) DEFAULT NULL,
  `referenceText_5` varchar(512) DEFAULT NULL,
  `referenceText_6` varchar(512) DEFAULT NULL,
  `referenceText_7` varchar(512) DEFAULT NULL,
  `referenceText_8` varchar(512) DEFAULT NULL,
  `referenceText_9` varchar(512) DEFAULT NULL,
  `referenceText_10` varchar(512) DEFAULT NULL,
  `referenceText_11` varchar(512) DEFAULT NULL,
  `referenceText_12` varchar(512) DEFAULT NULL,
  `referenceText_13` varchar(512) DEFAULT NULL,
  `referenceText_14` varchar(512) DEFAULT NULL,
  `referenceText_15` varchar(512) DEFAULT NULL,
  `referenceDateTime_1` datetime DEFAULT NULL,
  `referenceDateTime_2` datetime DEFAULT NULL,
  `referenceDateTime_3` datetime DEFAULT NULL,
  `referenceDateTime_4` datetime DEFAULT NULL,
  `referenceDateTime_5` datetime DEFAULT NULL,
  `debitAmount` decimal(13,2) DEFAULT NULL COMMENT 'money data type',
  `creditAmount` decimal(13,2) DEFAULT NULL COMMENT 'money data type',
  `amount_1` decimal(13,2) DEFAULT NULL,
  `amount_2` decimal(13,2) DEFAULT NULL,
  `amount_3` decimal(13,2) DEFAULT NULL,
  `amount_4` decimal(13,2) DEFAULT NULL,
  `amount_5` decimal(13,2) DEFAULT NULL,
  `recordDetails` json DEFAULT NULL,
  `derivedCol_1` varchar(128) DEFAULT NULL,
  `derivedCol_2` varchar(128) DEFAULT NULL,
  `derivedCol_3` varchar(128) DEFAULT NULL,
  `derivedCol_4` varchar(128) DEFAULT NULL,
  `derivedCol_5` varchar(128) DEFAULT NULL,
  `derivedCol_6` varchar(128) DEFAULT NULL,
  `derivedCol_7` varchar(128) DEFAULT NULL,
  `derivedCol_8` varchar(128) DEFAULT NULL,
  `derivedCol_9` varchar(128) DEFAULT NULL,
  `derivedCol_10` varchar(128) DEFAULT NULL,
  `derivedCol_11` varchar(128) DEFAULT NULL,
  `derivedCol_12` varchar(128) DEFAULT NULL,
  `isSplit` char(1) NOT NULL DEFAULT 'N',
  `isMarkedForPosting` char(1) NOT NULL DEFAULT 'N',
  `isMatched` char(1) NOT NULL DEFAULT 'N',
  `isDeleted` char(1) NOT NULL DEFAULT 'N',
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdByUser` varchar(32) NOT NULL,
  `lastUpdatedBy` varchar(32) DEFAULT NULL,
  `lastUpdatedDt` datetime DEFAULT NULL,
  `intRecordId` int(11) DEFAULT NULL,
  `groupId` int(11) DEFAULT NULL,
  PRIMARY KEY (`extRecordsId`),
  KEY `FK_TER_JOBID_IDX` (`jobId`),
  KEY `FK_TER_JOBIMPORTID_IDX` (`jobImportId`),
  KEY `FK_TER_RELATIONSHIPID_IDX` (`relationshipId`),
  KEY `IDX_TER` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_1`) /*!80000 INVISIBLE */,
  KEY `IDX_TER_1` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_1`),
  KEY `IDX_TER_2` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_2`),
  KEY `IDX_TER_3` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_3`),
  KEY `IDX_TER_5` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_5`),
  KEY `IDX_TER_6` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_6`),
  KEY `IDX_TER_7` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_7`),
  KEY `IDX_TER_8` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_8`),
  KEY `IDX_TER_UPD` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`debitAmount`,`creditAmount`,`amount_1`),
  KEY `IDX_TER_4` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_4`,`derivedCol_11`),
  CONSTRAINT `FK_TIMPORTEXT_JOBIMPORTS` FOREIGN KEY (`jobImportId`) REFERENCES `etl_jobimports` (`jobimportid`),
  CONSTRAINT `FK_TIMPORTEXT_JOBS` FOREIGN KEY (`jobId`) REFERENCES `etl_jobs` (`jobid`)
) ENGINE=InnoDB AUTO_INCREMENT=8381 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='RECO job stores cleansed data in this table. Copies data from STG';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:30
