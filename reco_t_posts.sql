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
-- Table structure for table `t_posts`
--

DROP TABLE IF EXISTS `t_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_posts` (
  `postId` int(11) NOT NULL AUTO_INCREMENT,
  `internalAccountSource` int(11) NOT NULL,
  `internalAccountTarget` int(11) NOT NULL,
  `transactionType` varchar(16) NOT NULL COMMENT 'Debit/Credit',
  `isPostGenerated` char(1) NOT NULL DEFAULT 'N',
  `postGeneratedDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `postGeneratedBy` varchar(32) NOT NULL,
  `postFileName` varchar(64) DEFAULT NULL,
  `postFileURL` varchar(512) DEFAULT NULL COMMENT 'Location of the file generated through Export after post is confirmed.',
  `postApprovedBy` varchar(32) DEFAULT NULL,
  `postApprovedDatetime` datetime DEFAULT NULL,
  `totalRecords` int(11) DEFAULT NULL,
  `totalAmount` decimal(13,2) DEFAULT NULL,
  `isDeleted` char(1) NOT NULL DEFAULT 'N',
  `status` varchar(16) DEFAULT NULL COMMENT 'New, Assigned, Approved, Processed',
  `lastUpdatedBy` varchar(32) NOT NULL,
  `lastUpdatedDt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`postId`),
  KEY `FK_1_idx` (`internalAccountSource`),
  KEY `FK_2_idx` (`transactionType`),
  KEY `FK_TPR_2_idx` (`internalAccountTarget`),
  CONSTRAINT `FK_TPR_1` FOREIGN KEY (`internalAccountSource`) REFERENCES `m_internalaccounts` (`internalaccountid`),
  CONSTRAINT `FK_TPR_2` FOREIGN KEY (`internalAccountTarget`) REFERENCES `m_internalaccounts` (`internalaccountid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='This table creates a new PostId for grouping all the transactions that were marked for Posting. Application will generate a unique file for all records related to the PostId. These records will be then exported to an excel and then uploaded to thier internal ERP systems or manually updated. ';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-08 12:42:34
