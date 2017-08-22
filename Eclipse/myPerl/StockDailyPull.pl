#! C:/Strawberry/Perl/bin/perl.exe -w

push(@INC,"C:/Strawberry/Perl/lib");
use LWP::UserAgent;
use HTML::Parser;
use HTML::TableExtract;
use Text::Table;
use Tie::File;
use strict;
use warnings;

my $HOME="C:/AK/Home";
my $LOGDIR="$HOME/logdir";
my $ARCDIR="$HOME/arcdir";
my $TMPDIR="$HOME/tmpdir";
my $CFGDIR="$HOME/cfgdir";
my $DATDIR="$HOME/indir";
my $EXEDIR="$HOME/exedir"; 

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()); 
my $today = ($year + 1900) * 10000 + ($mon + 1) * 100 + $mday;
#print $today;
print 'Start at '.($hour>9?$hour:'0'.$hour).':'.($min>9?$min:'0'.$min).':'.($sec>9?$sec:'0'.$sec);
my $stockrankdaily = "http://vip.stock.finance.sina.com.cn/q/go.php/vDYData/kind/dpqs/index.phtml";

my @stockList_page_sina = qw(http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=&s_z=&num=60&p=
http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sz_a&s_z=&num=60&p=
http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sh_b&s_z=&num=60&p=
http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sz_b&s_z=&num=60&p=
);


###### determin date
my $ua = LWP::UserAgent->new;
my $stockrank_res = $ua->get($stockrankdaily);		
my $stockrank_html = $stockrank_res->content();

$stockrank_html =~ m/更新日期：(.*)&nbsp/;
# 		print $1;
(my $date = $1) =~ s/-//g;
#		print $date;
if ($date lt $today) {$today = $date;}
print "\nDate to process: ".$today;
my $cnt = 1;

my $datafile = $DATDIR."/stockdaily_".$today.".txt";


######## pull daily stock

open(DATFILE, ">$datafile") || die("Cannot open files\n");

foreach my $stockList_page_sina (@stockList_page_sina){
#	print $stockList_page_sina;
	for(my $i=1;$i<50;$i++){

		$stockList_page_sina = $stockList_page_sina.$i;
		#print $stockList_page_sina;
		my $ua = LWP::UserAgent->new;
		my $stocklist_res = $ua->get($stockList_page_sina);

		last unless $stocklist_res->is_success();

		my $stocklist_html = $stocklist_res->content();
 
	#printf $stocklist_html;

	#	my $doc = 'state-actions-to-implement-the-health-benefit.aspx';
		my $headers =  [ '代码', '名称' ,'千股千评','最新价','涨跌额','涨跌幅','昨收' ,'今开','最高','最低','成交量\(万股\)','成交额\(万元\)' ];
		 
		my $table_extract = HTML::TableExtract->new(headers => $headers);
		$table_extract->parse($stocklist_html);
		my ($tables) = $table_extract->tables;
		
		our $table_output = Text::Table->new(@$headers);
		 
		for my $row ($tables->rows) {
		#    clean_up_spaces($row); # not shown for brevity
			die unless defined $row;
#			print join('|',@$row);
#exit;			
#			unshift(@$row,$date)；
		    #$table_output->load($row);	
		    printf DATFILE join('|',@$row)."\n" unless $row =~ /^代码/;	    
		}
	#$table_output =~ s/^代码.*\n// ;
	
	#printf DATFILE $table_output;
	} 
	#print $table_output;
	sleep 0.5;
	$cnt++;
}

close(DATFILE);

tie my @contents, 'Tie::File', $datafile or die "can't open $!\n";
for(@contents){		
    #s/\s+/|/g;
    #s/(^\d+\|[\x80-\xFF][\x80-\xFF])\|/$1/;
    #s/(^\d+\|\w+)\|([\x80-\xFF][\x80-\xFF])/$1$2/;
    #s/(^\d+\|[\x80-\xFF][\x80-\xFF][\x80-\xFF][\x80-\xFF])\|([\x80-\xFF][\x80-\xFF]\|)/$1$2/;
    s/$/\|$today/;
#    s/^代码.*\n//;
}
untie @contents;
print "\nPull Daily stock list is done!";
exit 0;
#sed -i -n -e 's/\s+/\t/' $datafile;