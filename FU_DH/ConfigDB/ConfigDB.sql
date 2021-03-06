﻿USE [master]
GO
CREATE DATABASE [ConfigDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ConfigDB', FILENAME = N'D:\Data\DBFiles\ConfigDB.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ConfigDB_log', FILENAME = N'D:\Data\DBFiles\ConfigDB_log.ldf' , SIZE = 794624KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [ConfigDB] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ConfigDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ConfigDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ConfigDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ConfigDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ConfigDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ConfigDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [ConfigDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ConfigDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ConfigDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ConfigDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ConfigDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ConfigDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ConfigDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ConfigDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ConfigDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ConfigDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ConfigDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ConfigDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ConfigDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ConfigDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ConfigDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ConfigDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ConfigDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ConfigDB] SET RECOVERY FULL 
GO
ALTER DATABASE [ConfigDB] SET  MULTI_USER 
GO
ALTER DATABASE [ConfigDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ConfigDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ConfigDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ConfigDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ConfigDB] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'ConfigDB', N'ON'
GO
ALTER DATABASE [ConfigDB] SET QUERY_STORE = OFF
GO
USE [ConfigDB]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
ALTER DATABASE [ConfigDB] SET  READ_WRITE 
GO
