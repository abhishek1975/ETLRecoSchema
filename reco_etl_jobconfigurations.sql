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
-- Table structure for table `etl_jobconfigurations`
--

DROP TABLE IF EXISTS `etl_jobconfigurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `etl_jobconfigurations` (
  `jobConfigurationId` int(11) NOT NULL,
  `organizationId` int(11) NOT NULL,
  `relationshipId` int(11) DEFAULT NULL,
  `jobId` int(11) NOT NULL,
  `intSourceType` varchar(16) DEFAULT NULL,
  `extSourceType` varchar(16) DEFAULT NULL,
  `intSourceDetails` json DEFAULT NULL,
  `extSourceDetails` json DEFAULT NULL,
  `version` varchar(4) DEFAULT '1',
  `isActive` char(1) NOT NULL DEFAULT 'Y',
  `lastUpdatedDt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdatedBy` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`jobConfigurationId`),
  KEY `FK_JOBCONFIGURATIONS_RELATIONSHIPS_idx` (`relationshipId`),
  KEY `FK_JOBCONFIGURATIONS_JOBS_idx` (`jobId`),
  CONSTRAINT `FK_JOBCONFIGURATIONS_JOBS` FOREIGN KEY (`jobId`) REFERENCES `etl_jobs` (`jobid`),
  CONSTRAINT `FK_JOBCONFIGURATIONS_RELATIONSHIPS` FOREIGN KEY (`relationshipId`) REFERENCES `m_relationships` (`relationshipid`)
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

-- Dump completed on 2019-01-08 12:42:32
