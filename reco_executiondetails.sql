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
-- Table structure for table `executiondetails`
--

DROP TABLE IF EXISTS `executiondetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `executiondetails` (
  `executionDetailsId` int(11) NOT NULL AUTO_INCREMENT,
  `executionLogId` int(11) NOT NULL,
  `intSourceDataId` int(11) DEFAULT NULL,
  `extSourceDataId` int(11) DEFAULT NULL,
  `recoStatus` varchar(16) DEFAULT 'Open' COMMENT 'Refer Lookup: Open (default), Matched, UnMatched, Under Dispute, Rollback, Voucher Generated, Voucher Matched',
  `recoCategory` varchar(16) DEFAULT NULL COMMENT 'Refer Lookup: Variance,OneSided, DetailsMismatch',
  `recoSubCategory` varchar(16) DEFAULT NULL COMMENT 'Refer Lookup:  Charges, Interests, DateMisMatch, ReferenceMismatch',
  PRIMARY KEY (`executionDetailsId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='This table holds the details of RECO output post execution. First, it will use extSourceDataId (external data) to loop through the records and find similar matches in the internal data source (like ERP, Tally). If matched, RECO will update the extSourceDataId with the reference to stgImportData. If not found any matches RECO will update the status as "UnMatched" by executing all the matching rules.If any of the Rules gives closest match or is One Sided transaction then the system will update the RECO Category and RECO Sub Category accordingly.';
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
