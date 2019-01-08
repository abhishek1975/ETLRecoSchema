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
-- Table structure for table `stg_importsourceext`
--

DROP TABLE IF EXISTS `stg_importsourceext`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stg_importsourceext` (
  `importSourceExtId` int(11) NOT NULL AUTO_INCREMENT,
  `jobId` int(11) NOT NULL,
  `jobImportId` int(11) NOT NULL,
  `organizationId` int(11) NOT NULL,
  `relationshipId` int(11) NOT NULL,
  `recordType` varchar(16) NOT NULL COMMENT 'Either "Header", "Footer", "Row"',
  `processingStatus` varchar(16) NOT NULL DEFAULT 'New' COMMENT 'Refer Lookup Table (RECO_IMPORTOVERALLSTATUS): New, Processed, Pending. ',
  `processingDateTime` datetime DEFAULT NULL,
  `currencyId` int(11) DEFAULT NULL,
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
  `referenceDateTime_1` varchar(32) DEFAULT NULL,
  `referenceDateTime_2` varchar(32) DEFAULT NULL,
  `referenceDateTime_3` varchar(32) DEFAULT NULL,
  `referenceDateTime_4` varchar(32) DEFAULT NULL,
  `referenceDateTime_5` varchar(32) DEFAULT NULL,
  `debitAmount` varchar(24) DEFAULT NULL COMMENT 'money data type',
  `creditAmount` varchar(24) DEFAULT NULL COMMENT 'money data type',
  `amount_1` varchar(24) DEFAULT NULL,
  `amount_2` varchar(24) DEFAULT NULL,
  `amount_3` varchar(24) DEFAULT NULL,
  `amount_4` varchar(24) DEFAULT NULL,
  `amount_5` varchar(24) DEFAULT NULL,
  `transactionType` varchar(32) NOT NULL COMMENT '''DR'', ''CR''',
  `isDeleted` char(1) NOT NULL DEFAULT 'N',
  `createdDateTime` datetime DEFAULT CURRENT_TIMESTAMP,
  `createdByUser` varchar(32) NOT NULL,
  `recordDetails` json DEFAULT NULL,
  PRIMARY KEY (`importSourceExtId`),
  KEY `FK_STGIMPORTINT_JOBS_idx` (`jobId`),
  KEY `FK_STGIMPORTEXT_JOBIMPORTS_idx` (`jobImportId`),
  KEY `FK_STGIMPORTEXT_RELATIONSHIPS_idx` (`relationshipId`) /*!80000 INVISIBLE */,
  KEY `FK_ISE_1` (`jobId`,`relationshipId`,`processingStatus`,`processingDateTime`,`isDeleted`),
  KEY `IDX_ISE_LOAD` (`jobId`,`relationshipId`,`processingStatus`,`recordType`,`isDeleted`,`referenceText_4`),
  CONSTRAINT `FK_STGIMPORTEXT_JOBIMPORTS` FOREIGN KEY (`jobImportId`) REFERENCES `etl_jobimports` (`jobimportid`),
  CONSTRAINT `FK_STGIMPORTEXT_JOBS` FOREIGN KEY (`jobId`) REFERENCES `etl_jobs` (`jobid`),
  CONSTRAINT `FK_STGIMPORTEXT_RELN` FOREIGN KEY (`relationshipId`) REFERENCES `m_relationships` (`relationshipid`)
) ENGINE=InnoDB AUTO_INCREMENT=8255 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='RECO job stores the user imported data in this staging table. Copying to this table is done in a "Batch" and entire source data is stored as a single JSON. Import LogID is the unique ID generated for each import performed. ExecutionLogId is the unique ID generated for each execution of RECO job. Initially all records are marked as "New". After RECO job execution, if all records are matched then the status is udpated as "Completed" else "Pending"';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:35
