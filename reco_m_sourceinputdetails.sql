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
-- Table structure for table `m_sourceinputdetails`
--

DROP TABLE IF EXISTS `m_sourceinputdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `m_sourceinputdetails` (
  `sourceInputDetailId` int(11) NOT NULL,
  `counterPartyId` int(11) DEFAULT NULL,
  `inputType` varchar(16) NOT NULL COMMENT 'FILE, DATABASE',
  `inputFileName` varchar(64) DEFAULT NULL COMMENT 'Contains the file name expected. May have pattern as well like SBI_DDMMYYYY',
  `inputFileLocation` varchar(128) DEFAULT NULL,
  `inputFileExtension` varchar(8) DEFAULT NULL,
  `inputFileSizeKB` int(11) DEFAULT NULL COMMENT 'Permissible File Size in KB',
  `inputFileSheetCount` smallint(6) DEFAULT NULL,
  `inputDbName` varchar(32) DEFAULT NULL,
  `inputDbServerName` varchar(32) DEFAULT NULL,
  `isZipped` char(1) DEFAULT 'N',
  `isEncrypted` char(1) DEFAULT 'N',
  `isPassword` char(1) DEFAULT 'N',
  `userName` varchar(16) DEFAULT NULL,
  `password` varchar(16) DEFAULT NULL,
  `isActive` char(1) NOT NULL,
  `lastUpdatedBy` varchar(32) NOT NULL,
  `lastUpdatedDt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sourceInputDetailId`),
  KEY `FK_SID_1_idx` (`counterPartyId`),
  CONSTRAINT `FK_SID_1` FOREIGN KEY (`counterPartyId`) REFERENCES `m_counterparties` (`counterpartyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:29
