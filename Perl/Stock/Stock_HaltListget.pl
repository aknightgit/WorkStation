
#! D:/Perl/bin/perl.exe 

BEGIN{push(@INC,"D:/Perl/site/lib")};
use Encode;
# use utf8;
use LWP::UserAgent;
# use HTML::Parser;
# use HTML::TableExtract;
# use Text::Table;
# use Tie::File;
use strict;
use warnings;


my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()); 
my $today = ($year + 1900) * 10000 + ($mon + 1) * 100 + $mday;

my $HOME="D:/Home";
my $DATDIR="$HOME/indir";
my $stockhalthist = $DATDIR."/stockhalthist.txt";



while(<DATA>){
	chomp;
	my $stockhalt_eastfundpage = $_.($year + 1900)."-".($mon + 1)."-".$mday;
	
	my $ua = LWP::UserAgent->new;
	my $res = $ua->get($stockhalt_eastfundpage);		
	my $html = $res->content();
	

	$html = Encode::decode("utf-8", $html);
#	utf8::decode($html);

#	map { print "//u", sprintf( "%x", $_ ) } unpack( "U*", $html );
Encode::_utf8_off($html);	
	$html =~ s/","/\n/g;
	$html =~ s/^\(\[\"//;
	$html =~ s/\"\]\)$//;
#	$html =~ s/[\"\%]//g;
#	$html =~ s/(.*),\-/$1/g;
#	$html =~ s/(?:.*\[\[)|(?:,\-\]\].*)//g;
#	$html =~ s/(\d)\-(\d)/$1$2/g;
	$html =~ s/,/|/g ;
	$html =~ s/ 09:30| 15:00|-//g ;
#	$html =~ s/^\s+$//g;
	open(INDEXHIST,">$stockhalthist") or die("canot open file!\n");
	printf INDEXHIST $html;
	close(INDEXHIST);

#	my @html = split '\n',$html;
##	print @html;
#	for my $line (@html){
##		($day,$a,$b,$c,$d,$f,$g,$h)
##print $_;
#	my ($day,$a,$b,$c,$d,$f,$g,$h) = split ',',$line;
##		local @a = split(',',$_);
#		print $day
#	}
}
print "hi"

__DATA__
http://datainterface.eastmoney.com/EM_DataCenter/JS.aspx?type=FD&sty=SRB&st=0&sr=-1&p=5&ps=500&mkt=1&fd=