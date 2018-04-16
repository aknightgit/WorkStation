#! C:/Strawberry/Perl/bin/perl.exe -w

#
# File: find.pl
# License: GPL-2

use strict;
use warnings;
use File::Find;
use Tie::File;
use POSIX qw(strftime);

my $HOME="C:/AK/Home";
my $DATDIR="$HOME/indir/stock_daily";


opendir(DH, "$DATDIR") or die "Can't open: $DATDIR! $!\n" ;

#my @list = grep {/.*\#900926.txt$/x && -f "$DATDIR/$_" } readdir(DH) ; #For test use

my @list = grep {/.*\#\d+.txt$/x && -f "$DATDIR/$_" } readdir(DH) ;

closedir(DH) ;

#print "@list";
#exit 0;

chdir($DATDIR) or die "Can't cd dir: $!\n" ;

#遍历文件夹，定义文件句柄。
foreach my $file (@list){
	
	print "Processing ".$file."...\n";
	tie my @contents, 'Tie::File', $file or die "can't open $!\n";
	
	@contents = grep {!/^$/} @contents;		##remove empty line
	@contents = grep {/^\d+/} @contents;
	#@contents = grep {s/\s+/\|/g} @contents;
#	print @contents;
	my $firstline ;
	unless( $contents[0] =~ m/日线/ )
	{
		print $file." is in invalid format. Maybe processed already!\n";
		next;
	}
	
	$firstline = shift(@contents);
	my ($stockcode,$stockname);
	($stockcode,$stockname) = ($1,$2) if {$firstline =~ m/(\d+)(.*?)日线/};
	$stockname =~ s/\s//g;
	next unless defined($stockcode);
#	print $stockcode;
#	print $stockname ;
#	print $stocknametail;
	for(@contents){		
		s/\s+/\|/g;
		s/\/|\-//g;
		s/^/$stockcode\|$stockname\|/g;
	}
	untie @contents;
	print "Process Done!\n";
}

print "All completed!";
exit 0;