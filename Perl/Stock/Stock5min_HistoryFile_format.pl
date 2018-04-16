#! D:/Perl/bin/perl.exe -W

#
# File: find.pl
# License: GPL-2

use strict;
use warnings;
use File::Find;
use Tie::File;
use POSIX qw(strftime);

my $HOME="C:/AK/Home";
my $DATDIR="$HOME/indir/stock_5min";


($DATDIR)=@ARGV?@ARGV:($DATDIR);
$DATDIR=~s/\\/\//g;


opendir(DH, "$DATDIR") or die "Can't open:$DATDIR. $!\n" ;

#my @list = grep {/\#\d+\_5min.txt$/ && -f "$DATDIR/$_" } readdir(DH) ;

my @list = grep {/.*\#\d+.txt$/x && -f "$DATDIR/$_" } readdir(DH) ;

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
	# print $file;
	tie my @contents, 'Tie::File', $file or die "can't open $file. $!\n";
	
	next unless $contents[0] =~ m/5分钟线/;
	my $firstline ;
	$firstline = shift(@contents);
	my ($stockcode,$stockname);
	($stockcode,$stockname) = ($1,$2) if {$firstline =~ m/(\d+)(.*?)5分钟线/};
	$stockname =~ s/\s//g;
	
	next unless defined($stockcode);
	
	# @contents = grep {/^\d+/} @contents;		##remove empty line
# 
	# map { s/\s+|\;/\|/g;	s/^/$stockcode\|$stockname\|/;} @contents;
	for(@contents){	
		# print $_;
		# exit;
		#delete $_ unless /^\d+/;
		s/\s+|\;/\|/g;
		s/^/$stockcode\|$stockname\|/;
	}
	untie @contents;

}

exit 0;