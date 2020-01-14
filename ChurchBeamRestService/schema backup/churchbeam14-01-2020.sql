-- MySQL dump 10.13  Distrib 8.0.13, for macos10.14 (x86_64)
--
-- Host: 127.0.0.1    Database: localhostchurchbeam
-- ------------------------------------------------------
-- Server version	8.0.18

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
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `book` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=140 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chapter`
--

DROP TABLE IF EXISTS `chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `chapter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` int(11) DEFAULT NULL,
  `book_id` int(11) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`,`book_id`),
  KEY `fk_chapter_book1_idx` (`book_id`),
  CONSTRAINT `fk_chapter_book1` FOREIGN KEY (`book_id`) REFERENCES `book` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=369 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cluster`
--

DROP TABLE IF EXISTS `cluster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cluster` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `theme_id` int(11) NOT NULL,
  `isLoop` tinyint(4) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `time` decimal(3,2) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`theme_id`,`organization_id`),
  KEY `fk_cluster_theme1_idx` (`theme_id`),
  KEY `fk_cluster_organization1_idx` (`organization_id`),
  CONSTRAINT `fk_cluster_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`),
  CONSTRAINT `fk_cluster_theme1` FOREIGN KEY (`theme_id`) REFERENCES `theme` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=937 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contract`
--

DROP TABLE IF EXISTS `contract`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `contract` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contract_has_organization`
--

DROP TABLE IF EXISTS `contract_has_organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `contract_has_organization` (
  `contract_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`contract_id`,`organization_id`),
  KEY `fk_contract_has_organization_organization1_idx` (`organization_id`),
  KEY `fk_contract_has_organization_contract1_idx` (`contract_id`),
  CONSTRAINT `fk_contract_has_organization_contract1` FOREIGN KEY (`contract_id`) REFERENCES `contract` (`id`),
  CONSTRAINT `fk_contract_has_organization_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contractLedger`
--

DROP TABLE IF EXISTS `contractLedger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `contractLedger` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contract_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  `title` varchar(45) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `userName` varchar(45) DEFAULT NULL,
  `phoneNumber` varchar(10) DEFAULT NULL,
  `hasApplePay` tinyint(1) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`contract_id`,`organization_id`,`user_id`),
  KEY `fk_ContractLedger_contract1_idx` (`contract_id`),
  KEY `fk_ContractLedger_organization1_idx` (`organization_id`),
  KEY `fk_contractLedger_user1_idx` (`user_id`),
  CONSTRAINT `fk_ContractLedger_contract1` FOREIGN KEY (`contract_id`) REFERENCES `contract` (`id`),
  CONSTRAINT `fk_ContractLedger_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`),
  CONSTRAINT `fk_contractLedger_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instrument`
--

DROP TABLE IF EXISTS `instrument`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `instrument` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cluster_id` int(11) NOT NULL,
  `isLoop` tinyint(4) DEFAULT NULL,
  `aswFileID` varchar(1000) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `fileSizeInBytes` int(11) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`,`cluster_id`),
  KEY `fk_instrument_cluster1_idx` (`cluster_id`),
  CONSTRAINT `fk_instrument_cluster1` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization`
--

DROP TABLE IF EXISTS `organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `organization` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=262 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`,`organization_id`),
  KEY `fk_role_organization1_idx` (`organization_id`),
  CONSTRAINT `fk_role_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sheet`
--

DROP TABLE IF EXISTS `sheet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sheet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isEmptySheet` tinyint(4) NOT NULL,
  `position` int(11) NOT NULL,
  `time` double DEFAULT NULL,
  `content` varchar(10000) DEFAULT NULL,
  `hasTitle` tinyint(4) DEFAULT NULL,
  `imageBorderColor` varchar(100) DEFAULT NULL,
  `imageBorderSize` int(11) DEFAULT NULL,
  `imageContentMode` int(11) DEFAULT NULL,
  `imageHasBorder` tinyint(4) DEFAULT NULL,
  `imagePathAWS` varchar(1000) DEFAULT NULL,
  `thumbnailPathAWS` varchar(1000) DEFAULT NULL,
  `contentLeft` varchar(1000) DEFAULT NULL,
  `contentRight` varchar(1000) DEFAULT NULL,
  `cluster_id` int(11) NOT NULL,
  `theme_id` int(11) DEFAULT NULL,
  `theme_entity_id` int(11) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `type` varchar(100) NOT NULL,
  `imagePath` varchar(300) DEFAULT NULL,
  `thumbnailPath` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`,`cluster_id`),
  UNIQUE KEY `theme_id_UNIQUE` (`theme_id`),
  UNIQUE KEY `theme_entity_id_UNIQUE` (`theme_entity_id`),
  KEY `fk_sheet_theme1_idx` (`theme_id`,`theme_entity_id`),
  KEY `fk_sheet_cluster1_idx` (`cluster_id`),
  CONSTRAINT `fk_sheet_cluster1` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sheet_theme1` FOREIGN KEY (`theme_id`) REFERENCES `theme` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1211 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `songServiceSection`
--

DROP TABLE IF EXISTS `songServiceSection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `songServiceSection` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT '0',
  `numberOfSongs` int(11) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `songServiceSettings_id` int(11) NOT NULL,
  `songServiceSettings_organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`songServiceSettings_id`,`songServiceSettings_organization_id`),
  KEY `fk_SongServiceSection_SongServiceSettings1_idx` (`songServiceSettings_id`,`songServiceSettings_organization_id`),
  CONSTRAINT `fk_SongServiceSection_SongServiceSettings1` FOREIGN KEY (`songServiceSettings_id`, `songServiceSettings_organization_id`) REFERENCES `songservicesettings` (`id`, `organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `songServiceSection_has_tag`
--

DROP TABLE IF EXISTS `songServiceSection_has_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `songServiceSection_has_tag` (
  `songServiceSection_id` int(11) NOT NULL,
  `songServiceSection_songServiceSettings_id` int(11) NOT NULL,
  `songServiceSection_songServiceSettings_organization_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `tag_organization_id` int(11) NOT NULL,
  PRIMARY KEY (`songServiceSection_id`,`songServiceSection_songServiceSettings_id`,`songServiceSection_songServiceSettings_organization_id`,`tag_id`,`tag_organization_id`),
  KEY `fk_SongServiceSection_has_tag_tag1_idx` (`tag_id`,`tag_organization_id`),
  KEY `fk_SongServiceSection_has_tag_SongServiceSection1_idx` (`songServiceSection_id`,`songServiceSection_songServiceSettings_id`,`songServiceSection_songServiceSettings_organization_id`),
  CONSTRAINT `fk_SongServiceSection_has_tag_SongServiceSection1` FOREIGN KEY (`songServiceSection_id`, `songServiceSection_songServiceSettings_id`, `songServiceSection_songServiceSettings_organization_id`) REFERENCES `songservicesection` (`id`, `songServiceSettings_id`, `songServiceSettings_organization_id`),
  CONSTRAINT `fk_SongServiceSection_has_tag_tag1` FOREIGN KEY (`tag_id`, `tag_organization_id`) REFERENCES `tag` (`id`, `organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `songServiceSettings`
--

DROP TABLE IF EXISTS `songServiceSettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `songServiceSettings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT 'Default',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`organization_id`),
  KEY `fk_SongServiceSettings_organization1_idx` (`organization_id`),
  CONSTRAINT `fk_SongServiceSettings_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`organization_id`),
  KEY `fk_tag_organization1_idx` (`organization_id`),
  CONSTRAINT `fk_tag_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_has_cluster`
--

DROP TABLE IF EXISTS `tag_has_cluster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `tag_has_cluster` (
  `tag_id` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL,
  `cluster_theme_id` int(11) NOT NULL,
  `cluster_organization_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_id`,`cluster_id`,`cluster_theme_id`,`cluster_organization_id`),
  KEY `fk_tag_has_cluster_cluster1_idx` (`cluster_id`,`cluster_theme_id`,`cluster_organization_id`),
  KEY `fk_tag_has_cluster_tag1_idx` (`tag_id`),
  CONSTRAINT `fk_tag_has_cluster_cluster1` FOREIGN KEY (`cluster_id`, `cluster_theme_id`, `cluster_organization_id`) REFERENCES `cluster` (`id`, `theme_id`, `organization_id`),
  CONSTRAINT `fk_tag_has_cluster_tag1` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `theme`
--

DROP TABLE IF EXISTS `theme`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `theme` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allHaveTitle` tinyint(4) DEFAULT NULL,
  `backgroundColor` varchar(45) DEFAULT NULL,
  `backgroundTransparancy` varchar(100) DEFAULT NULL,
  `displayTime` tinyint(4) DEFAULT NULL,
  `hasEmptySheet` tinyint(4) DEFAULT NULL,
  `imagePath` varchar(300) DEFAULT NULL,
  `imagePathThumbnail` varchar(300) DEFAULT NULL,
  `isEmptySheetFirst` tinyint(4) DEFAULT NULL,
  `isHidden` tinyint(4) DEFAULT NULL,
  `isContentBold` tinyint(4) DEFAULT NULL,
  `isContentItalic` tinyint(4) DEFAULT NULL,
  `isContentUnderlined` tinyint(4) DEFAULT NULL,
  `isTitleBold` tinyint(4) DEFAULT NULL,
  `isTitleItalic` tinyint(4) DEFAULT NULL,
  `isTitleUnderlined` tinyint(4) DEFAULT NULL,
  `contentAlignmentNumber` int(11) DEFAULT NULL,
  `contentBorderColor` varchar(45) DEFAULT NULL,
  `contentBorderSize` int(11) DEFAULT NULL,
  `contentFontName` varchar(100) DEFAULT NULL,
  `contentTextColor` varchar(45) DEFAULT NULL,
  `position` int(11) unsigned zerofill DEFAULT NULL,
  `titleAlignmentNumber` int(11) DEFAULT NULL,
  `titleBackgroundColor` varchar(45) DEFAULT NULL,
  `titleBorderColor` varchar(45) DEFAULT NULL,
  `titleBorderSize` int(11) DEFAULT NULL,
  `titleFontName` varchar(100) DEFAULT NULL,
  `titleTextColor` varchar(45) DEFAULT NULL,
  `titleTextSize` int(11) DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `contentTextSize` int(11) DEFAULT NULL,
  `imagePathThumbnailAWS` varchar(400) DEFAULT NULL,
  `imagePathAWS` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`id`,`organization_id`),
  KEY `fk_theme_organization1_idx` (`organization_id`),
  CONSTRAINT `fk_theme_organization1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=527 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(45) DEFAULT NULL,
  `appInstallToken` varchar(255) DEFAULT NULL,
  `userToken` varchar(200) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  `inviteToken` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_has_role`
--

DROP TABLE IF EXISTS `user_has_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `user_has_role` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `fk_person_has_role_role1_idx` (`role_id`),
  KEY `fk_person_has_role_person_idx` (`user_id`),
  CONSTRAINT `fk_person_has_role_person` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `fk_person_has_role_role1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vers`
--

DROP TABLE IF EXISTS `vers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `vers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` int(11) DEFAULT NULL,
  `content` varchar(1000) DEFAULT NULL,
  `chapter_id` int(11) NOT NULL,
  `chapter_book_id` int(11) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`chapter_id`,`chapter_book_id`),
  KEY `fk_vers_chapter1_idx` (`chapter_id`,`chapter_book_id`),
  CONSTRAINT `fk_vers_chapter1` FOREIGN KEY (`chapter_id`, `chapter_book_id`) REFERENCES `chapter` (`id`, `book_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=601 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-14 17:03:51
