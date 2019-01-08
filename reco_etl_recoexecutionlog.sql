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
-- Table structure for table `etl_recoexecutionlog`
--

DROP TABLE IF EXISTS `etl_recoexecutionlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `etl_recoexecutionlog` (
  `logId` int(11) NOT NULL AUTO_INCREMENT,
  `jobId` int(11) NOT NULL,
  `executionId` int(11) NOT NULL,
  `taskId` int(11) NOT NULL,
  `startDt` datetime DEFAULT NULL,
  `endDt` datetime DEFAULT NULL,
  `status` varchar(16) NOT NULL,
  `rowCount` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL COMMENT 'in milliseconds',
  `comments` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`logId`),
  KEY `FK_EREL_1_idx` (`jobId`),
  KEY `FK_EREL_2_idx` (`taskId`),
  CONSTRAINT `FK_EREL_1` FOREIGN KEY (`jobId`) REFERENCES `etl_jobs` (`jobid`),
  CONSTRAINT `FK_EREL_2` FOREIGN KEY (`taskId`) REFERENCES `etl_recotasks` (`taskid`)
) ENGINE=InnoDB AUTO_INCREMENT=420 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:27
