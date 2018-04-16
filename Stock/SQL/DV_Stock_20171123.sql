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

drop table dbo.hub_date;
create table dbo.hub_date(
	hub_date_key char(32) not null,
	datekey int not null,
	LoadDTS datetime2 default(getdate()),
	RecSrc varchar(200) 
);
go
alter table dbo.hub_date
add  primary key   clustered  (hub_date_key);
alter table dbo.hub_date
add  constraint  ui_date unique  (datekey);

drop table dbo.hub_index;
create table dbo.hub_index(
	hub_index_key char(32) not null,
	stockindex varchar(100) not null,
	LoadDTS datetime2 default(getdate()),
	RecSrc varchar(200) 
);
go
alter table dbo.hub_index
add  primary key   clustered  (hub_index_key);
alter table dbo.hub_index
add  constraint  ui_index unique  (stockindex);

drop table dbo.link_stockdate;
create table dbo.link_stockdate(
	link_stockdate_key char(32) not null,
	hub_stock_key char(32) not null,
	hub_date_key char(32) not null,
	LoadDTS datetime2 default(getdate()),
	RecSrc varchar(200) 
);
go
alter table dbo.link_stockdate
add  primary key   clustered  (link_stockdate_key);
alter table dbo.link_stockdate
add  constraint  ui_stockdate unique  (hub_stock_key,hub_date_key);

