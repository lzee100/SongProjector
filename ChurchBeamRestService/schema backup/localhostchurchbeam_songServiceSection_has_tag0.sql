CREATE DATABASE  IF NOT EXISTS `localhostchurchbeam` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `localhostchurchbeam`;
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
  CONSTRAINT `fk_SongServiceSection_has_tag_SongServiceSection1` FOREIGN KEY (`songServiceSection_id`, `songServiceSection_songServiceSettings_id`, `songServiceSection_songServiceSettings_organization_id`) REFERENCES `songservicesection` (`id`, `songservicesettings_id`, `songservicesettings_organization_id`),
  CONSTRAINT `fk_SongServiceSection_has_tag_tag1` FOREIGN KEY (`tag_id`, `tag_organization_id`) REFERENCES `tag` (`id`, `organization_id`)
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

-- Dump completed on 2019-07-21 12:26:09
