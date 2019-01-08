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
-- Table structure for table `m_bankaccounts`
--

DROP TABLE IF EXISTS `m_bankaccounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `m_bankaccounts` (
  `bankAccountId` int(11) NOT NULL AUTO_INCREMENT,
  `organizationId` int(11) NOT NULL,
  `bankName` varchar(64) NOT NULL,
  `branchCode` varchar(32) NOT NULL,
  `bankIFSCcode` varchar(16) NOT NULL,
  `bankAccountNum` varchar(24) NOT NULL,
  `customerRelationshipNum` varchar(24) DEFAULT NULL,
  `currencyCode` varchar(8) NOT NULL,
  `bankAccountDescription` varchar(512) DEFAULT NULL,
  `accountHolderName_1` varchar(64) NOT NULL,
  `accountHolderName_2` varchar(64) DEFAULT NULL,
  `nomineeName` varchar(64) DEFAULT NULL,
  `nomineeRelationship` varchar(16) DEFAULT NULL,
  `isNomineeRegistered` char(1) NOT NULL DEFAULT 'N',
  `isJointAccount` char(1) NOT NULL DEFAULT 'N',
  `isActive` char(1) NOT NULL DEFAULT 'Y',
  `lastUpdatedBy` varchar(64) NOT NULL,
  `lastUpdatedDt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `branchName` varchar(32) DEFAULT NULL,
  `branchLocation` varchar(64) DEFAULT NULL,
  `branchAddress` varchar(255) DEFAULT NULL,
  `branchState` varchar(32) DEFAULT NULL,
  `accountType` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`bankAccountId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='List of all the Bank Accounts managed by the Organization';
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
