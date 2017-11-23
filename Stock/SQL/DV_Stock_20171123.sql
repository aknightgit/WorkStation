drop table dbo.hub_stock;
create table dbo.hub_stock(
	hub_stock_key char(32) not null,
	StockCode varchar(50) not null,
	LoadDTS datetime2 default(getdate()),
	RecSrc varchar(200) 
);
go
alter table dbo.hub_stock
add  primary key   clustered  (hub_stock_key);
alter table dbo.hub_stock
add  constraint  ui_StockCode unique  (StockCode);

drop table dbo.hub_stock;
create table dbo.hub_stock(
	hub_stock_key char(32) not null,
	StockCode varchar(50) not null,
	LoadDTS datetime2 default(getdate()),
	RecSrc varchar(200) 
);
go
alter table dbo.hub_stock
add  primary key   clustered  (hub_stock_key);
alter table dbo.hub_stock
add  constraint  ui_StockCode unique  (StockCode);
