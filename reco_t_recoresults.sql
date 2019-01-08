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
-- Table structure for table `t_recoresults`
--

DROP TABLE IF EXISTS `t_recoresults`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_recoresults` (
  `recoResultId` int(11) NOT NULL AUTO_INCREMENT,
  `relationshipId` int(11) DEFAULT NULL,
  `t_intRecordId` int(11) DEFAULT NULL,
  `t_extRecordId` int(11) DEFAULT NULL,
  `jobExecutionId` int(11) DEFAULT NULL,
  `recoStatus` varchar(32) NOT NULL COMMENT 'MATCHED, GROUPED, DISPUTED, ROLLBACK, EXPORTED , POSTED, EXCEPTIONS',
  `recoCategory` varchar(32) DEFAULT NULL COMMENT 'FOR MATCHED -> SYSTEM-MATCHED,  USER-MATCHED, BY-POSTING; \nFOR GROUPED ->  SYSTEM-MATCHED,  USER-MATCHED, BY-POSTING, VARIANCE; ',
  `recoSubCategory` varchar(32) DEFAULT NULL COMMENT 'RECEIVABLES, VENDOR PAYMENT, SWEEPS, BANK CHARGES, INTERESTS, LATE FEES, GST CHARGES',
  `isActive` char(1) NOT NULL DEFAULT 'Y',
  `isAutoApproved` char(1) NOT NULL DEFAULT 'Y',
  `processedDt` datetime DEFAULT CURRENT_TIMESTAMP,
  `processedBy` varchar(32) DEFAULT NULL,
  `ruleReference` varchar(32) NOT NULL,
  `groupId` int(11) DEFAULT NULL,
  `lastUpdatedBy` varchar(32) DEFAULT NULL,
  `lastUpdatedDt` datetime DEFAULT NULL,
  `groupedRecords` json DEFAULT NULL,
  PRIMARY KEY (`recoResultId`),
  KEY `IDX_1` (`ruleReference`),
  KEY `FK_TRR_1_idx` (`relationshipId`),
  KEY `IDX_TRR_UPD_E` (`processedDt`,`t_extRecordId`) /*!80000 INVISIBLE */,
  KEY `IDX_TRR_UPD_I` (`processedDt`,`t_intRecordId`),
  CONSTRAINT `FK_TRR_1` FOREIGN KEY (`relationshipId`) REFERENCES `m_relationships` (`relationshipid`)
) ENGINE=InnoDB AUTO_INCREMENT=8865 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
