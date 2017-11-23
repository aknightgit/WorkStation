#!/usr/local/bin/perl 
###################################################################################################
# NAME  : set_up.pl 
# TYPE  : perl
# Usage   set up a new subject area.
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-6-13          1.0         Kevin                   Initial Version
#
####################################################################################################

use strict;

my $HOME="/export/home/dx_wang/kevin/batch";
my $LOGDIR="$HOME/log";
my $ARCDIR="$HOME/arc";
my $TMPDIR="$HOME/tmp";
my $CFGDIR="$HOME/cfg";
my $DATDIR="$HOME/dat";
my $EXEDIR="$HOME/bin";


my ($SUBJECT_AREA,$choice,$email,$TH_FILE,$TH_HOST,$TH_INFO,$TH_UCJOB,$TH_JOBP,@TH_FILE);

if(!@ARGV){
        print "What subject area do you want to set up:\n";
        $SUBJECT_AREA=<STDIN>;
        chomp $SUBJECT_AREA;
}
else{
        ($SUBJECT_AREA)=@ARGV;
}

my $DAILY_MTR_CFG="$CFGDIR/daily_batch_mtr.cfg";
my $HIST_AVG_CFG="$CFGDIR/hist_avg_gen.cfg";
my $TOUCH_FILE_CFG="$CFGDIR/${SUBJECT_AREA}_touch.cfg";

my $EMAIL_LIS="$DATDIR/daily_batch_mtr.tls";
my $HIST_AVG_DAT="$DATDIR/$SUBJECT_AREA"."_touch_hist.dat";
my $DELAY_DAY_LIS="$DATDIR/$SUBJECT_AREA"."_delay_days.lis";

unless(-e $TOUCH_FILE_CFG){
	print "$TOUCH_FILE_CFG required!!!\n ";
	exit;
}

open(MTRCFG,"$DAILY_MTR_CFG")||die "can not open $DAILY_MTR_CFG.\n";
    my $tmp=do{local $/;<MTRCFG>;};
	if($tmp=~/$SUBJECT_AREA/){
		print "Entry for $SUBJECT_AREA arleady exists in $DAILY_MTR_CFG.\nPlease remove it before adding now entry.\n";
		exit;
	}
close(MTRCFG);

print "Please set the Sensitivity(acceptable lag):\n ";
my $delay=<STDIN>;
chomp $delay;

print "Please set the report level, 'all' or Enter:\n";
my $select=<STDIN>;
chomp $select;

print "Please set the up limit for the daily batch(e.g. 23:00):\n";
my $limit=<STDIN>;
chomp $limit;

print "Please select the email sent object: \n[1]oncall team;\n[2]only me;\n1,2 or else:\n";
$choice=<STDIN>;
chomp $choice;

if($choice==1){
    $email="dl-ebay-sha-imd-dima-cdc-oncall\@ebay.com";
}
elsif($choice==2){
    $email="aiwang\@ebay.com";
}
else{
    chomp($email=$choice);
}

#CFG
chdir $CFGDIR;
open(MTRCFG,">>$DAILY_MTR_CFG")||die "can not creat $DAILY_MTR_CFG.\n";
        printf MTRCFG "%-5s%-15s%-20s%-15s%-15s\n",'+',$SUBJECT_AREA,$delay,$select,$limit;
close(MTRCFG);

open(AVGCFG,">>$HIST_AVG_CFG")||die "can not creat $HIST_AVG_CFG.\n";
        printf AVGCFG "%-5s%-20s%-15s%-15s\n",'+',$SUBJECT_AREA,'7','all';
close(AVGCFG);
#re-orgnize the cfg file
open(THCFG,$TOUCH_FILE_CFG)||die "can not open $TOUCH_FILE_CFG, you must provide the cfg file for adding new monitor item\n";
    open(TMPFILE,">>$TMPDIR/mytmp")||die "cannot creat $TMPDIR/mytmp;";
        foreach(<THCFG>){
                ($TH_FILE,$TH_HOST,$TH_INFO,$TH_UCJOB,$TH_JOBP)=split(' ',$_);
                push(@TH_FILE,$TH_FILE);
                
                printf TMPFILE "$TH_FILE\t$TH_HOST\t$TH_INFO\t$TH_UCJOB\t$TH_JOBP\n";
        }
        close(TMPFILE);
close(THCFG);
system("cd $TMPDIR; mv $TMPDIR/mytmp $TOUCH_FILE_CFG > /dev/null");

#DAT
chdir $DATDIR;
open(FH1,">>$EMAIL_LIS")||die "can not creat $EMAIL_LIS.\n";
    print FH1 "$SUBJECT_AREA $email";
close(FH1);
open(FH2,">$HIST_AVG_DAT")||die "can not creat $HIST_AVG_DAT.\n";
open(FH2,">>$HIST_AVG_DAT")||die "can not creat $HIST_AVG_DAT.\n";
        foreach(@TH_FILE){
        printf FH2 "%-10s%-60s\n",$limit,$_;
        }
close(FH2);

open(FH3,">$DELAY_DAY_LIS")||die "can not creat $DELAY_DAY_LIS.\n";
close(FH3);


print "Complete setting up check system for $SUBJECT_AREA, please check.\n"