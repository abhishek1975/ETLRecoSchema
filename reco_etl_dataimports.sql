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
-- Table structure for table `etl_dataimports`
--

DROP TABLE IF EXISTS `etl_dataimports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `etl_dataimports` (
  `importId` int(11) NOT NULL AUTO_INCREMENT,
  `relationshipId` int(11) NOT NULL,
  `counterPartyId` int(11) NOT NULL,
  `jobId` int(11) DEFAULT NULL,
  `sourceType` varchar(16) NOT NULL COMMENT 'FILE,DATABASE,API',
  `extractionType` varchar(16) NOT NULL COMMENT 'UPLOAD, QUERY, METHOD',
  `fileName` varchar(512) DEFAULT NULL,
  `downloadURL` varchar(1024) DEFAULT NULL,
  `fileSizeBytes` int(11) DEFAULT NULL,
  `referenceFromDate` date DEFAULT NULL,
  `referenceToDate` date DEFAULT NULL,
  `rowCount` int(11) DEFAULT NULL,
  `status` varchar(16) NOT NULL COMMENT 'COMPLETED, ERROR',
  `duration` int(11) DEFAULT NULL,
  `isProcessed` char(1) NOT NULL DEFAULT 'N',
  `isDeleted` char(1) NOT NULL DEFAULT 'N',
  `isZipped` char(1) NOT NULL DEFAULT 'N',
  `isEncrypted` char(1) NOT NULL DEFAULT 'N',
  `lastUpdatedBy` varchar(32) NOT NULL,
  `lastUpdatedDt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`importId`),
  KEY `FK_EDI_1_idx` (`relationshipId`),
  KEY `FK_EDI_2_idx` (`counterPartyId`),
  KEY `FK_EDI_3_idx` (`jobId`),
  CONSTRAINT `FK_EDI_1` FOREIGN KEY (`relationshipId`) REFERENCES `m_relationships` (`relationshipid`),
  CONSTRAINT `FK_EDI_2` FOREIGN KEY (`counterPartyId`) REFERENCES `m_counterparties` (`counterpartyid`),
  CONSTRAINT `FK_EDI_3` FOREIGN KEY (`jobId`) REFERENCES `etl_jobs` (`jobid`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:31
