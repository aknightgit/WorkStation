#! D:/Perl/bin/perl.exe -W

#
# File: find.pl
# License: GPL-2

use strict;
use warnings;
use File::Find;
use Tie::File;
use POSIX qw(strftime);

my $HOME="D:/Home";
my $DATDIR="$HOME/indir";


opendir(DH, "$DATDIR") or die "Can't open: $!\n" ;

#my @list = grep {/\#\d+\_5min.txt$/ && -f "$DATDIR/$_" } readdir(DH) ;

my @list = grep {/.*\#\d+_5min.txt$/x && -f "$DATDIR/$_" } readdir(DH) ;

closedir(DH) ;

#print "@list";
#exit 0;

chdir($DATDIR) or die "Can't cd dir: $!\n" ;

#遍历文件夹，定义文件句柄。
foreach my $file (@list){
#    open(FH, "$file") or die "Can't open: $!\n" ;
#    while(<FH>){
#
#  	if(<FH> =~ /$str2/i){
#    	print "$file:\n" ; 
#   	}
#    }
#    print "\n";
#    close(FH) ;
#	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)  = stat($file);
#  my @t = localtime $ctime;
#    $date = sprintf "%02u/%02u/%02u %02u:%02u:%02u", $t[4] + 1, $t[3], $t[5] % 100, $t[2], $t[1], $t[0];
#    print $date; 

#  my $date = strftime "%Y/%m/%d %H:%M:%S", (localtime $ctime)[0..5];
#  print $date;
#  exit;
#  next unless $date lt "2016/07/01 00:20:06";
	tie my @contents, 'Tie::File', $file or die "can't open $!\n";
	
	@contents = grep {!/^$/} @contents;		##remove empty line
	@contents = grep {/^\d+/} @contents;
	#@contents = grep {s/\s+/\|/g} @contents;
#	print @contents;
#	print $firstline;
	my $firstline ;
#	print $contents[0];
	next unless $contents[0] =~ m/5分钟线/;
	
	$firstline = shift(@contents);
	my ($stockcode,$stockname);
	($stockcode,$stockname) = ($1,$2) if {$firstline =~ m/(\d+)(.*?)5分钟线/};
	$stockname =~ s/\s//g;
	next unless defined($stockcode);
#	print $stockcode;
#	print $stockname ;
#	print $stocknametail;
#	$stockname = $stockname.$stocknametail unless ($stocknametail  eq "5分钟线");
#	print $stockcode;
#	print $stockname;
	for(@contents){		
#		s/^\D+.*//;
		s/\s+/\|/g;
		s/\/|\-//g;
#		s/\s+/|/g;
#		s/^\s+$//g;
#		if m/(^\|\d+)\|/ my $stockcode = $1 ;
#		print $stockcode;
		s/^/$stockcode\|$stockname\|/g;
#		s/\|日线//g;
#		s/^(\d+\|.*?\|)+/$1/g;
	}
	untie @contents;

}

exit 0;