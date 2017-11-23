#!/usr/local/bin/perl 
###################################################################################################
# NAME  : sla_hist_avg_gen.pl 
# TYPE  : perl
# OUTPUT: Generate historical avg-time table for sla touch files.
#
#
# Usage:
#         $sla_hist_avg_gen.pl $1 $2 $3;
#         $1:  involve logs in recent '$1' days. value range : 1-30
#         $2:  1 for Monday, 2 for Tue,.., 7 for Sunday; value range : 1-7 and 'all'. 
#         $3:  the day you don't want to count. can be null.
#        
#         eg.  $sla_hist_avg_gen.pl 30 5 20080530
#               means that, you want to count the average from recent 30 days, only Friday, and exclude the day 20080530, 
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-5-30          1.0         Kevin                   Initial Version

####################################################################################################

use strict;

#################################################################
#                     part 1   Definition
#################################################################

my $Usage="Usage:  \$sla_hist_avg_gen.pl 30 all 200800530\n\t30->the day-range to include in;\n\tall->1 for Mon..0 for Sun,'all' means all the 7 days;\n\t20080530->the day exclusive, can be null.\n\n";      
my ($TH_FILE,$Day_range,$wday,$WDAY,$i,$tmp,$exclude);
my (@TH_FILE,@date,@exclude,@ARC,%HIST,%NUM);
$wday=(localtime(time()))[6];
my %week=('0'=>'Sun','1'=>'Mon','2'=>'Tue','3'=>'Wed','4'=>'Thu','5'=>'Fri','6'=>'Sat','all'=>'week');

#define the past 10days.
my @day; 
foreach(@day=(0..30)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
}

#define the avg-time function
sub plustime{
    my ($ta,$tb)=@_;
	my $total=(substr($ta,0,2)+substr($tb,0,2))*60+substr($ta,3,2)+substr($tb,3,2);
	return sprintf "%02d:%02d",$total/60,$total%60;
}
sub avgtime{
    my ($total,$num)=@_;
	if(!$num){
	    return undef;
	}
	else{
	    my $m=(substr($total,0,2)*60+substr($total,3,2))/$num;
	    return sprintf "%02d:%02d",$m/60,$m%60;
	}
}
#################################################################
#                     part 2   setting up
#################################################################
# env setting    
my $HOME="/export/home/dx_wang/kevin/batch";
my $LOGDIR="$HOME/log";
my $ARCDIR="$HOME/arc";
my $TMPDIR="$HOME/tmp";
my $CFGDIR="$HOME/cfg";
my $DATDIR="$HOME/dat";
my $SLA_TOUCH_CFG="$CFGDIR/dw_sla_touch.cfg";
my $SLA_HIST_DAT="$DATDIR/dw_sla_touch_hist.dat";
my $SLA_DELAY_DAY="$DATDIR/dw_sla_delay_days.lis";
open(HISTDAT,">$SLA_HIST_DAT")||die "can not creat $! \n";
close(HISTDAT);

# set default to  $1=30, $2=$wday, $3=null
if(!@ARGV){
	($Day_range,$WDAY,@exclude)=(30,$wday);  
	warn "$Usage";
}
elsif(@ARGV==1){
    ($Day_range,$WDAY,@exclude)=(@ARGV,$wday);	
}
else{
    ($Day_range,$WDAY,@exclude)=@ARGV;	
}
#define the exclude list
if(!defined @exclude){
	open(EXDAYLIS,"$SLA_DELAY_DAY")||die "cannot open $!";
    @exclude=<EXDAYLIS>;
	close(EXDAYLIS);
}
# check the 'wday' parmeter

print "You're searching data from recent $Day_range days for all $week{$WDAY} days.\n";
if($WDAY eq "all"){
    foreach(1..$Day_range){
	    push(@date,$day[$_]);
	}
} 
elsif($WDAY >= 0 and $WDAY < 7){
    $tmp=$wday-$WDAY;
	for($i=1;$i*7+$tmp<=$Day_range;$i++){
	    push(@date,$day[$i*7+$tmp]);
	}	
}
else{
    print "$Usage";
	die "you gave the wrong week day! FYI:0 for Sun .. 6 for Sat, 'all' for all 7 days.\n\n";
}
## delete the unwanted element, depend ont he exclude day list
foreach $exclude (@exclude){  
    @date=map{$_ if $exclude ne $_} @date;  
}

chdir $ARCDIR;

foreach(@date){
    ($tmp)=glob("*sla_touch_status.$_");
    if(defined $tmp){
        push(@ARC,"dw_sla_touch_status.$_");
	}
}
if(!@ARC){
    die "Cannot find any data from recent $Day_range days for all $week{$WDAY} days. please try other parameters.\n";
}
else{
    print "Found the following hist data matchs your requery:\n@ARC\n\n";
}
#################################################################
#                     part 3   generate the hist-ave file
#################################################################
open(CFGFILE,$SLA_TOUCH_CFG)||die "connot open cfg file:$!";
foreach(<CFGFILE>){
    $tmp=(split(' ',$_))[0];
	push(@TH_FILE,$tmp);
}
close(CFGFILE);

chdir $ARCDIR;
foreach(@ARC){
    open(ARCLOG,$_)||die "cannot open arc file $_.\n";
    $tmp=do{local $/;<ARCLOG>;};
	foreach (@TH_FILE){
	    if($tmp=~/(..:..)     $_/){
		    $HIST{$_}=plustime($HIST{$_},$1);
			$NUM{$_}++;
		}
	}
	close(ARCLOG);
}

open(HISTDAT,">>$SLA_HIST_DAT")||die "can not creat $! \n";
foreach(@TH_FILE){  
    $HIST{$_}=avgtime($HIST{$_},$NUM{$_});
	printf HISTDAT "%-10s%-60s\n",$HIST{$_},$_;
}
close(HISTDAT);

print "Complete writing hist-avg data into $SLA_HIST_DAT. Please check.\n"