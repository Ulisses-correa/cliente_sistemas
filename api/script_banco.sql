/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: sistema_clientes
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefone` varchar(100) DEFAULT NULL,
  `status` enum('ativo','inativo') DEFAULT 'ativo',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES
(1,'Gustavo Henrique Bittencourt','gustavo.bittencourt@gmail.com','47991458236','ativo','2026-10-02 22:50:14'),
(2,'Mariana Alves Pacheco','mariana.pacheco@hotmail.com','48988734152','ativo','2026-10-02 22:50:14'),
(3,'Leonardo Farias Montenegro','leonardo.montenegro@outlook.com','11982647519','ativo','2026-10-02 22:50:14'),
(4,'André Felipe Cardoso','andre.cardoso@gmail.com','47992361487','ativo','2026-10-02 22:50:14'),
(5,'Patrícia Regina Tavares','patricia.tavares@hotmail.com','48991172834','inativo','2026-10-02 22:50:14');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itens_pedido`
--

DROP TABLE IF EXISTS `itens_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `itens_pedido` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pedido_id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_itens_pedidos` (`pedido_id`),
  KEY `fk_itens_produtos` (`produto_id`),
  CONSTRAINT `fk_itens_pedidos` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_itens_produtos` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES
(1,1,1,1,18750.00),
(2,2,2,1,3850.00),
(3,2,3,1,2190.00),
(4,3,2,1,3850.00),
(5,4,6,1,12990.00),
(6,5,5,1,679.90),
(7,6,4,1,489.90);
/*!40000 ALTER TABLE `itens_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cliente_id` int(11) NOT NULL,
  `atendido_por` int(11) DEFAULT NULL,
  `data_pedido` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('pendente','pago','cancelado') DEFAULT 'pendente',
  `valor_total` decimal(10,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `fk_pedidos_clientes` (`cliente_id`),
  KEY `fk_pedidos_usuarios` (`atendido_por`),
  CONSTRAINT `fk_pedidos_clientes` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  CONSTRAINT `fk_pedidos_usuarios` FOREIGN KEY (`atendido_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES
(1,1,2,'2026-10-02 22:50:19','pago',18750.00),
(2,2,3,'2026-10-02 22:50:19','pendente',6040.00),
(3,3,1,'2026-10-02 22:50:19','pago',3850.00),
(4,4,4,'2026-10-02 22:50:19','pendente',12990.00),
(5,1,2,'2026-10-02 22:50:19','cancelado',679.90),
(6,2,3,'2026-10-02 22:50:19','pago',489.90);
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produtos`
--

DROP TABLE IF EXISTS `produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` decimal(10,2) NOT NULL,
  `estoque` int(11) DEFAULT 0,
  `status` enum('ativo','inativo') DEFAULT 'ativo',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES
(1,'Kit Embreagem BMW M3 Competition','Conjunto de embreagem de alta performance compatível com BMW M3 Competition, indicado para substituição do sistema original.',18750.00,3,'ativo','2026-10-02 22:50:16'),
(2,'Jogo de Pastilhas Brembo GT Performance','Jogo de pastilhas de freio de alto desempenho para veículos esportivos, desenvolvido para uso urbano e condução esportiva.',3850.00,12,'ativo','2026-10-02 22:50:16'),
(3,'Filtro de Ar Esportivo K&N 57i','Sistema de admissão de ar esportivo com filtro lavável e reutilizável, proporcionando maior fluxo de ar ao motor.',2190.00,7,'ativo','2026-10-02 22:50:16'),
(4,'Óleo Motul 8100 X-Cess 5W40','Lubrificante sintético de alta performance indicado para motores de veículos esportivos e de alto desempenho.',489.90,25,'ativo','2026-10-02 22:50:16'),
(5,'Jogo de Velas NGK Iridium','Conjunto de quatro velas de ignição com tecnologia Iridium para melhor desempenho e eficiência do motor.',679.90,15,'ativo','2026-10-02 22:50:16'),
(6,'Kit Suspensão Esportiva Bilstein B16','Sistema de suspensão esportiva com regulagem de altura e desempenho desenvolvido para condução esportiva.',12990.00,2,'ativo','2026-10-02 22:50:16'),
(7,'Disco de Freio Esportivo Brembo','Disco de freio ventilado de alta performance para aplicações esportivas.',4250.00,6,'ativo','2026-10-02 22:50:16'),
(8,'Scanner Automotivo Launch X431','Equipamento profissional para diagnóstico eletrônico de veículos, leitura e apagamento de códigos de falha.',5890.00,4,'ativo','2026-10-02 22:50:16');
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `perfil` enum('admin','operador') DEFAULT 'operador',
  `status` enum('ativo','inativo') DEFAULT 'ativo',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES
(1,'Marcelo Augusto Nogueira','marcelo.nogueira@autovitta.com.br','123','admin','ativo','2026-10-02 22:50:12'),
(2,'Larissa Mendes Ribeiro','larissa.ribeiro@autovitta.com.br','123','operador','ativo','2026-10-02 22:50:12'),
(3,'Caio Henrique Valença','caio.valenca@autovitta.com.br','123','operador','ativo','2026-10-02 22:50:12'),
(4,'Renato Luiz Bastos','renato.bastos@autovitta.com.br','123','operador','ativo','2026-10-02 22:50:12');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'sistema_clientes'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-10-02 20:12:18
