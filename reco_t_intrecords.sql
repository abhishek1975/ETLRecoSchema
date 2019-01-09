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
-- Table structure for table `t_intrecords`
--

DROP TABLE IF EXISTS `t_intrecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_intrecords` (
  `intRecordsId` int(11) NOT NULL AUTO_INCREMENT,
  `jobId` int(11) NOT NULL,
  `jobExecutionId` int(11) NOT NULL,
  `jobImportId` int(11) NOT NULL,
  `organizationId` int(11) NOT NULL,
  `relationshipId` int(11) NOT NULL,
  `sourceRowId` int(11) NOT NULL,
  `currencyId` int(11) NOT NULL,
  `recordType` varchar(16) NOT NULL COMMENT 'Either "Header", "Footer", "Transaction"',
  `transactionType` varchar(32) DEFAULT NULL COMMENT '''''DR'''', ''''CR''''',
  `transactionSubType` varchar(32) DEFAULT NULL COMMENT 'NEFT, RTGS, IMPS (ONLINE TRANSFER)\\nVENDOR PAYMENT, INTERNAL SWEEP, (BY CHEQUE)',
  `processingStatus` varchar(16) NOT NULL DEFAULT 'New' COMMENT 'Refer Lookup Table (RECO_IMPORTOVERALLSTATUS): New, Completed, InProgress, Pending. ',
  `processingDateTime` datetime DEFAULT CURRENT_TIMESTAMP,
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
  `isDeleted` char(16) NOT NULL DEFAULT 'N',
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdByUser` varchar(32) NOT NULL,
  `lastUpdatedBy` varchar(32) DEFAULT NULL,
  `lastUpdatedDt` datetime DEFAULT NULL,
  `extRecordId` int(11) DEFAULT NULL,
  `groupId` int(11) DEFAULT NULL,
  PRIMARY KEY (`intRecordsId`),
  KEY `FK_ITR_JOBIMPORTS_idx` (`jobImportId`),
  KEY `FK_ITR_RELATIONSHIPID_IDX` (`relationshipId`),
  KEY `IDX_ITR_3` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_3`),
  KEY `IDX_ITR_5` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_5`),
  KEY `IDX_ITR_6` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_6`),
  KEY `IDX_ITR_7` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_7`),
  KEY `IDX_ITR_8` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_8`),
  KEY `IDX_ITR_1_1` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_1`),
  KEY `IDX_ITR_1_4` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_4`) /*!80000 INVISIBLE */,
  KEY `IDX_ITR_1_9` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_9`),
  KEY `IDX_ITR_2_11` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_11`) /*!80000 INVISIBLE */,
  KEY `IDX_ITR_1_3` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_3`),
  KEY `IDX_ITR_1_5` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_5`),
  KEY `IDX_ITR_1_11` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`referenceText_1`),
  KEY `IDX_ITR_1` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`derivedCol_1`,`amount_1`),
  KEY `IDX_ITR_2` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`derivedCol_2`,`amount_1`),
  KEY `IDX_ITR_4` (`jobId`,`relationshipId`,`processingStatus`,`isDeleted`,`amount_1`,`derivedCol_4`,`derivedCol_11`),
  CONSTRAINT `FK_TIMPORTINT_JOBIMPORTS` FOREIGN KEY (`jobImportId`) REFERENCES `etl_jobimports` (`jobimportid`),
  CONSTRAINT `FK_TIMPORTINT_JOBS` FOREIGN KEY (`jobId`) REFERENCES `etl_jobs` (`jobid`),
  CONSTRAINT `FK_TIMPORTINT_RELATIONSHIPS` FOREIGN KEY (`relationshipId`) REFERENCES `m_relationships` (`relationshipid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_intrecords`
--

LOCK TABLES `t_intrecords` WRITE;
/*!40000 ALTER TABLE `t_intrecords` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_intrecords` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-09 10:34:51
