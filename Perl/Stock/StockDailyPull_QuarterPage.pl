#! C:/Strawberry/Perl/bin/perl.exe -w

push(@INC,"C:/Strawberry/Perl/lib");
use LWP::UserAgent;
use HTML::Parser;
use HTML::TableExtract;
use Text::Table;
use Tie::File;
use strict;
use warnings;
use JSON qw/encode_json decode_json/; 
use Data::Dumper;
 
# use utf8;
# use Encode qw(encode_utf8 decode_utf8);

# use utf8;
# binmode(STDIN, ':encoding(utf8)');
# binmode(STDOUT, ':encoding(utf8)');
# binmode(STDERR, ':encoding(utf8)');

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
print "\n";
my $eastmoney_qgqp_part1 = "http://dcfm.eastmoney.com/em_mutisvcexpandinterface/api/js/get?type=QGQP_LB&token=70f12f2f4f091e459a279469fe49eca5&cmd=&st=Code&sr=1&p=";
my $eastmoney_qgqp_part2 = "&ps=50&js=var%20jFbAVxGY={pages:(tp),data:(x)}&filter=&rt=50403625";


my @stockList_page_sina = qw(http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=&s_z=&num=60&p=
 http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sz_a&s_z=&num=60&p=
 http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sh_b&s_z=&num=60&p=
 http://vip.stock.finance.sina.com.cn/q/go.php/vInvestConsult/kind/qgqp/index.phtml?s_i=&s_a=&s_c=&s_t=sz_b&s_z=&num=60&p=
 );


###### determin date
for(my $pageid=1;$pageid<100;$pageid++){
	my $eastmoney_qgqp = $eastmoney_qgqp_part1.$pageid.$eastmoney_qgqp_part2;
	# print $eastmoney_qgqp;
	
	my $ua = LWP::UserAgent->new;
	my $eastmoney_qgqp_res = $ua->get($eastmoney_qgqp);	
	# print $eastmoney_qgqp_res;
	
	last unless $eastmoney_qgqp_res->is_success();

	my $json_out = $eastmoney_qgqp_res->decoded_content; 
	exit:
	# print $json_out;
	# exit;
	my $arr = decode_json($json_out);	
	
	my $xx= Dumper($arr);        
	print $xx;
	# my $eastmoney_qgqp_content = $eastmoney_qgqp_res->content();
	
	# print $eastmoney_qgqp_content;
	
	
	
	# my $headers =  [ '代码', '名称' ,'千股千评','最新价','涨跌额','涨跌幅','昨收' ,'今开','最高','最低','成交量\(万股\)','成交额\(万元\)' ];
		 
		# my $table_extract = HTML::TableExtract->new(headers => $headers);
		# $table_extract->parse($stocklist_html);
		# my ($tables) = $table_extract->tables;
		
		# our $table_output = Text::Table->new(@$headers);
		 
		# for my $row ($tables->rows) {
		# #    clean_up_spaces($row); # not shown for brevity
			# die unless defined $row;
# #			print join('|',@$row);
# #exit;			
# #			unshift(@$row,$date)；
		    # #$table_output->load($row);	
		    # printf DATFILE join('|',@$row)."\n" unless $row =~ /^代码/;	    
		# }
}

exit;



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