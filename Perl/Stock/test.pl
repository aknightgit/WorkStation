
#! C:/Strawberry/Perl/bin/perl.exe -w

# push(@INC,"C:/Perl/lib"); 
# BEGIN{push(@INC,"C:/Perl/site/lib")};
# use lib "D:/Perl/lib";

use LWP::UserAgent;
use HTML::Parser;
use HTML::TableExtract;
use Text::Table;
use Tie::File;
#use Test::More;
use strict;
use warnings;

my $HOME="C:/AK/Home";
my $DATDIR="$HOME/indir";
my $indexhistfile = $DATDIR."/szzs_indexhist.txt";



while(<DATA>){
	chomp;
	my $szzs_hist_page = $_;
	
	my $ua = LWP::UserAgent->new;
	my $res = $ua->get($szzs_hist_page);		
	my $html = $res->content();
	
	$html =~ s/\],\[/\n/g;
	$html =~ s/[\"\%]//g;
	$html =~ s/(.*),\-/$1/g;
	$html =~ s/(?:.*\[\[)|(?:,\-\]\].*)//g;
	$html =~ s/(\d)\-(\d)/$1$2/g;
	$html =~ s/,/|/g;
#	$html =~ s/^\s+$//g;
	open(INDEXHIST,">$indexhistfile") || die("canot open file!\n");
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
print "done" ;

__DATA__
http://q.stock.sohu.com/hisHq?code=zs_399001&start=20010101&end=20160629&stat=1&order=D&period=d&callback=historySearchHandler