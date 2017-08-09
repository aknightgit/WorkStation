#! D:/Perl/bin/perl.exe 

push(@INC,"C:/Perl/lib");
use LWP::UserAgent;
use HTML::Parser;
use HTML::TableExtract;
use Text::Table;
use Tie::File;
#use Test::More;
use strict;
use warnings;

my $HOME="C:/AK/WorkStation/Home";
my $LOGDIR="$HOME/logdir";
my $ARCDIR="$HOME/arcdir";
my $TMPDIR="$HOME/tmpdir";
my $CFGDIR="$HOME/cfgdir";
my $DATDIR="$HOME/indir";
my $EXEDIR="$HOME/exedir"; 

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()); 
my $today = ($year + 1900) * 10000 + ($mon + 1) * 100 + $mday;
#print $today;
my $stockrankdaily = "http://vip.stock.finance.sina.com.cn/q/go.php/vDYData/kind/dpqs/index.phtml";
#my $page_num = 1;

my @stockList_page_sina = qw(http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=&s_z=&num=60&p=
http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sz_a&s_z=&num=60&p=
http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sh_b&s_z=&num=60&p=
http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sz_b&s_z=&num=60&p=
);


#my $index_page_sina = 'http://quote.eastmoney.com/center/index.html#zyzs_0_1';
# my $index_page = 'http://q.10jqka.com.cn/stock/zs/';
my $index_page = 'http://q.10jqka.com.cn/zs/';

###### determin date
my $ua = LWP::UserAgent->new;
my $stockrank_res = $ua->get($stockrankdaily);		
my $stockrank_html = $stockrank_res->content();

$stockrank_html =~ m/更新日期：(.*)&nbsp/;
# 		print $1;
(my $date = $1) =~ s/-//g;
#		print $date;
if ($date lt $today) {$today = $date;}
#exit;
my $cnt = 1;

my $datafile = $DATDIR."/stockdaily_".$today.".txt";
my $indexdatafile = $DATDIR."/indexdaily_".$today.".txt";


####### pull daily index
my $index_ua = LWP::UserAgent->new;
my $index_res = $index_ua->get($index_page);		
my $index_html = $index_res->content();
# print $index_html;

#my $headers =  [ '代码', '名称' ,'最新价','涨跌额','涨跌幅','成交量\(手\)','成交额\(万\)','昨收' ,'今开','最高','最低' ]; 
my $headers =  [ '序号', '指数代码', '指数名称' ,'最新价' ,'涨跌额', '涨跌幅\(\%\)', '昨收' , '今开', '最高价', '最低价' ,'成交量\（万手\）' ,'成交额\（亿元\）' ]; 
my $te_index = HTML::TableExtract->new(headers => $headers);
my $te_output = Text::Table->new(@$headers);
	# print $te_index;	
	# print $te_output;
$te_index->parse($index_html);
my ($tables) = $te_index->tables;
print $tables;		

for my $row ($tables->rows) {
#    clean_up_spaces($row); # not shown for brevity
    $te_output->load($row);		    
}
#$te_output =~ s/\s+\n$/\n/;
$te_output =~ s/%//g ;
$te_output =~ s/(\d+)\n/$1/g;
$te_output =~ s/^序号.*//g;
$te_output =~ s/^$//g;

open(INDEXFILE, ">$indexdatafile") || die("Cannot open files\n");
printf INDEXFILE $te_output;
close(INDEXFILE);

tie my @indexcontents, 'Tie::File', $indexdatafile or die "can't open $!\n";
for(@indexcontents){		
		chomp();		
    s/\s+/|/g ;    
    s/^\|//;
    s/\|$/\|$today/;
    #    $_ =~ s/(\d+$)\n//g;
}
untie @indexcontents;
#exit;
######## pull daily stock

open(DATFILE, ">$datafile") || die("Cannot open files\n");

foreach my $stockList_page_sina (@stockList_page_sina){
#	print $stockList_page_sina;
	for(my $i=1;$i<50;$i++){

		my $stockList_page_sina = $stockList_page_sina.$i;
		#print $stockList_page_sina;
		my $ua = LWP::UserAgent->new;
		my $stocklist_res = $ua->get($stockList_page_sina);

		last unless $stocklist_res->is_success();

		my $stocklist_html = $stocklist_res->content();
 
	#printf $stocklist_html;

#	my $te = new HTML::TableExtract( depth => 1 );
#	$te->parse($stocklist_html);
#	# Examine all matching tables
#	foreach my $ts ($te->table_states) {
#	 print "Table (", join(',', $ts->coords), "):\n";
#	 foreach my $row ($ts->rows) {
#	    print join(',', @$row), "\n";



	#	my $doc = 'state-actions-to-implement-the-health-benefit.aspx';
		my $headers =  [ '代码', '名称' ,'千股千评','最新价','涨跌额','涨跌幅','昨收' ,'今开','最高','最低','成交量\(万股\)','成交额\(万元\)' ];
		 
		my $table_extract = HTML::TableExtract->new(headers => $headers);
		our $table_output = Text::Table->new(@$headers);
		 
		$table_extract->parse($stocklist_html);
		my ($tables) = $table_extract->tables;
		
		for my $row ($tables->rows) {
		#    clean_up_spaces($row); # not shown for brevity
		#	die unless defined $row;
#			print "@$row";
#				unshift(@$row,$date)；
		    $table_output->load($row);		    
		}
	$table_output =~ s/^代码.*\n// ;
	
	printf DATFILE $table_output;
	} 
	#print $table_output;
	sleep 0.5;
	$cnt++;
}

close(DATFILE);

#open(DATFILE, "<$datafile") || die("Cannot open files\n");
#while(<DATFILE>){
#	s/\s+/\t/; 
#	print;
#	}
#close(DATFILE);
#
#
tie my @contents, 'Tie::File', $datafile or die "can't open $!\n";
for(@contents){		
    s/\s+/|/g;
    s/(^\d+\|[\x80-\xFF][\x80-\xFF])\|/$1/;
    s/(^\d+\|\w+)\|([\x80-\xFF][\x80-\xFF])/$1$2/;
    s/(^\d+\|[\x80-\xFF][\x80-\xFF][\x80-\xFF][\x80-\xFF])\|([\x80-\xFF][\x80-\xFF]\|)/$1$2/;
    s/\|$/\|$today/;
#    s/^代码.*\n//;
}
untie @contents;
exit 0;
#sed -i -n -e 's/\s+/\t/' $datafile;