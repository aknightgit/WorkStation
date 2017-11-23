#!/usr/local/bin/perl 
###################################################################################################
# NAME  : hist_avg_gen.pl 
# TYPE  : perl
# OUTPUT: Generate historical avg-time table for touch files.
#
#
# Usage:
#         $shist_avg_gen.pl $subject_area;
#        
# Outside parameters:   /export/home/dx_wang/kevin/batch/cfg/hist_avg_gen.cfg
#                                      $1:  involve logs in recent '$1' days. value range : 1-30
#                                      $2:  1 for Monday, 2 for Tue,.., 7 for Sunday; value range : 1-7 and 'all'. 
#                                       $3:  the day you don't want to count. can be null.
#        
#         eg.  $hist_avg_gen.pl 30 5 20080530
#               means that, you want to count the average from recent 30 days, only Friday, and exclude the day 20080530, 
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-5-30          1.0         Kevin                   Initial Version
# 2008-6-10           1.1          Kevin                  debug avgtime/plustime fun, exclude list, and also Friday avg stuff
####################################################################################################

use strict;

#################################################################
#                     part 1   Definition
#################################################################

my $Usage="Usage:  \$hist_avg_gen.pl \$subject_area\n";      
my $info="Info:  config file locates at /export/home/dx_wang/kevin/batch/cfg/hist_avg_gen.cfg.\n";
my $slash="#"x80;
my ($SUBJECT_AREA,$TH_FILE,$Day_range,$wday,$WDAY,$i,$tmp,$exclude);
my (@pars,@TH_FILE,@date,@exclude,@ARC,%HIST,%NUM,%IS_FRIDAY);
$wday=(localtime(time()))[6];
my %week=('0'=>'Sun','1'=>'Mon','2'=>'Tue','3'=>'Wed','4'=>'Thu','5'=>'Fri','6'=>'Sat','all'=>'week');

#define the past 30days.
my @day; 
foreach(@day=(0..30)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
        if($wday==5){
                $IS_FRIDAY{$_}=1;    ### define the friday.
        }
}

#define the avg-time function
sub plustime{
    my ($ta,$tb)=@_;
        my $total=((split(':',$ta))[0]+(split(':',$tb))[0])*60+(split(':',$ta))[1]+(split(':',$tb))[1];
        return sprintf "%02d:%02d",$total/60,$total%60;
}
sub avgtime{
    my ($total,$num)=@_;
        if(!$num){
            return undef;
        }
        else{
            my $m=((split(':',$total))[0]*60+(split(':',$total))[1])/$num;
            return sprintf "%02d:%02d",$m/60,$m%60;
        }
}
#################################################################
#                     part 2   setting up
#################################################################
# env setting    
if(!@ARGV){
    print "Please select the subject_area (e.g. dw_sla, dw_kwdm..): ";
        ($SUBJECT_AREA)=<STDIN>;
        chomp $SUBJECT_AREA;
}
else{
    ($SUBJECT_AREA,$Day_range,$WDAY,@exclude)=@ARGV;
}
my $HOME="/export/home/dx_wang/kevin/batch";
my $LOGDIR="$HOME/log";
my $ARCDIR="$HOME/arc";
my $TMPDIR="$HOME/tmp";
my $CFGDIR="$HOME/cfg";
my $DATDIR="$HOME/dat";
my $TOUCH_CFG="$CFGDIR/$SUBJECT_AREA"."_touch.cfg";
my $HIST_AVG_CFG="$CFGDIR/hist_avg_gen.cfg";
my $HIST_DAT="$DATDIR/$SUBJECT_AREA"."_touch_hist.dat";
my $DELAY_DAY="$DATDIR/$SUBJECT_AREA"."_delay_days.lis";
open(HISTDAT,">$HIST_DAT")||die "can not creat $! \n";
close(HISTDAT);

# set default to  $1=30, $2=$wday, $3=null
open(AVGCFG,$HIST_AVG_CFG)||die "cannot open $HIST_AVG_CFG\n";
    foreach(<AVGCFG>){
            my ($symbol,$SA,@tmp)=split(' ',$_);
                if($symbol eq '+' and $SA eq $SUBJECT_AREA){
                    @pars=@tmp;
                        last;
                }
        }
close(AVGCFG);

print "$slash\nStart executing hist_avg_gen.pl $SUBJECT_AREA.\n";
if(!$Day_range){
        ($Day_range)=@pars;  
        print "get default \$Day_range from $HIST_AVG_CFG, set to $Day_range.\n";
}
if(!$WDAY){
    ($WDAY)=($pars[1])?$pars[1]:$wday;
        print "get default \$WDAY from $HIST_AVG_CFG, set to \'$WDAY\'.\n";
}
#define the exclude list
if(!defined @exclude){
        open(EXDAYLIS,"$DELAY_DAY")||die "cannot open $DELAY_DAY\n";
    @exclude=<EXDAYLIS>;
        close(EXDAYLIS);
        print "get default \@exclude from $DELAY_DAY, set to \'@exclude\'.\n";
}
# check the 'wday' parmeter

print "You're searching data from recent $Day_range days for all $week{$WDAY} days.\n\n";
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
    chomp $exclude;
    @date=map{$_ if $exclude ne $_} @date;  
}

chdir $ARCDIR;

foreach(@date){
    ($tmp)=glob("*sla_touch_status.$_");
    if(defined $tmp){
        push(@ARC,"$SUBJECT_AREA"."_touch_status.$_");
        }
}
if(!@ARC){
    die "Cannot find any data from recent $Day_range days for all $week{$WDAY} days. please try other parameters.\n\n";
}
else{
    print "Found the following hist data matchs your requery:\n";
}
#################################################################
#                     part 3   generate the hist-ave file
#################################################################
open(CFGFILE,$TOUCH_CFG)||die "connot open cfg file:$!";
foreach(<CFGFILE>){
    $tmp=(split(' ',$_))[0];
        push(@TH_FILE,$tmp);
}
close(CFGFILE);

chdir $ARCDIR;
foreach(@ARC){  
    open(ARCLOG,$_)||next;
        print "$_\n";
    $tmp=do{local $/;<ARCLOG>;};
        my $date=(split('\.',$_))[-1];

        if($IS_FRIDAY{$date}==1){  # if it's Friday, adjust the time by -1h.
                foreach (@TH_FILE){
                        if($tmp=~/(..:..)     $_/){
                        my $adjust=sprintf "%02d:%02d",(split(':',$1))[0]-1,(split(':',$1))[1];
                    $HIST{$_}=plustime($HIST{$_},$adjust);
                        $NUM{$_}++;
                        }
                }       
        }
        else{
                foreach (@TH_FILE){
                        if($tmp=~/(..:..)     $_/){
                    $HIST{$_}=plustime($HIST{$_},$1);
                        $NUM{$_}++;
                        }
                }
        }
        close(ARCLOG);
}

open(HISTDAT,">>$HIST_DAT")||die "can not creat $! \n";
foreach(@TH_FILE){  
    $HIST{$_}=avgtime($HIST{$_},$NUM{$_});
        printf HISTDAT "%-10s%-60s\n",$HIST{$_},$_;
}
close(HISTDAT);

print "\nComplete writing hist-avg data into $HIST_DAT. Please check.\n$slash\n";
#########################  End of program #####################################