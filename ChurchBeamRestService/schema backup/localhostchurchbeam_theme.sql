-- MySQL dump 10.13  Distrib 8.0.13, for macos10.14 (x86_64)
--
-- Host: 127.0.0.1    Database: localhostchurchbeam
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
-- Table structure for table `theme`
--

DROP TABLE IF EXISTS `theme`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `theme` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allHaveTitle` tinyint(4) DEFAULT NULL,
  `backgroundColor` varchar(45) DEFAULT NULL,
  `backgroundTransparancy` int(11) DEFAULT NULL,
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
  `position` int(11) DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=504 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-07-21 12:24:14
