USE [master]
GO

/****** Object:  Database [Stock]    Script Date: 2016/6/28 1:50:59 ******/
CREATE DATABASE [Stock]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Stock', FILENAME = N'D:\DW\DATA\Stock2016' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Stock_log', FILENAME = N'D:\DW\log\Stock2016' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [Stock] SET COMPATIBILITY_LEVEL = 130
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Stock].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Stock] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Stock] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [Stock] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Stock] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Stock] SET ARITHABORT OFF 
GO

ALTER DATABASE [Stock] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Stock] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Stock] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Stock] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Stock] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Stock] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Stock] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Stock] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [Stock] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Stock] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Stock] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Stock] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Stock] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Stock] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Stock] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Stock] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Stock] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Stock] SET RECOVERY FULL 
GO

ALTER DATABASE [Stock] SET  MULTI_USER 
GO

ALTER DATABASE [Stock] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Stock] SET DB_CHAINING OFF 
GO

ALTER DATABASE [Stock] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [Stock] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [Stock] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [Stock] SET QUERY_STORE = OFF
GO

USE [Stock]
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO

ALTER DATABASE [Stock] SET  READ_WRITE 
GO


