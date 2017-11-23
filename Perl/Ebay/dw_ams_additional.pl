#!/usr/local/bin/perl 

###################################################################################################
# NAME  : AMD BATCH checkpoint checker
# TYPE  : perl
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-11-13          1.0         Kevin                   Initial Version
#
####################################################################################################
use lib ("/export/home/dx_wang/kevin/batch/lib");
use strict;
use Time;

## env definition
my $HOME="/export/home/dx_wang/kevin/batch";
my $CFGDIR="$HOME/cfg";
my $LOGDIR="$HOME/log";
my $TMPDIR="$HOME/tmp";
my $CFGFILE="$CFGDIR/dw_ams_deadline.cfg";
my $LOGFILE="$LOGDIR/dw_ams_additional.log";
my $WFL="$TMPDIR/etl10.wfl";        # -------------------> where's our watch file list from 

my ($TH_FILE,$DEADLINE,$watchlist,$logcontent,$msg,$tmp);
my (@TH_FILE,@INCOMPLETE);
my (%DEADLINE);
my $CONTACT="dl-ebay-sha-imd-dima-cdc-imk\@corp.ebay.com dl-ebay-sha-imd-dima-cdc-oncall\@ebay.com";

my $now=sprintf "%02d:%02d",(localtime(time()))[2,1];
my @day;
foreach(@day=(0,1)){ #today and yesterday
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
}
my $slash="#"x50;
####  Par 1 ########################
##          check existence of IMK touch files
################################

open(CFG, "$CFGDIR/dw_ams_deadline.cfg");
    foreach(<CFG>){
        chomp $_;
        ($TH_FILE,$DEADLINE)=(split(' ',$_));
        push(@TH_FILE,$TH_FILE);
        $DEADLINE{$TH_FILE}=$DEADLINE;
    }
close CFG;

open(LOG,"$LOGFILE")||open(LOG,">$LOGFILE");
    $logcontent=do {local $/;<LOG>;};
close(LOG);

open(WFL,"$WFL")||die "cannot open $WFL.\n";
    $watchlist=do {local $/;<WFL>;};
close(WFL);

open(LOG,">>$LOGFILE")||die "cannot wright into $LOGFILE.\n";
    foreach(@TH_FILE){
	    unless($logcontent=~/$_/ or Time->new($now,$DEADLINE{$_})->minus < 0){
			    if($watchlist=~/$_/){
				    print LOG "\n$now: Checking  $_;\nStatus: File exists;\nReport: Null\n$slash\n";
				}
				else{
				    push(@INCOMPLETE,$_);
					print LOG "\n$now: Checking  $_;\nStatus: File does not exists;\nReport: Mail sent\n$slash\n";
				}
			}		
	}
close(LOG);

foreach(@INCOMPLETE){
    $msg.="\t$_        $DEADLINE{$_}\n";
}
if($msg){
$msg=sprintf <<EOF;
Hi AMS team,
  
  Below files are beyond deadline and still unavailable for the moment! Please check.

    $slash    
	Filename       Deadline  

$msg
    $slash

Thanks
CDC Oncall

EOF

open(MAL,"|/usr/lib/sendmail -t");
print MAL "To: $CONTACT\n";
print MAL "From: dx_wang\@pascal.vip.ebay.com\n";
print MAL "Subject:[AMS monitor]\: AMS Checkpiont Notification!!!\n";
print MAL "\n${msg}";
close(MAL);  
}

####  Part 2 ######################
##                  Check the content of
##  	$DW_DAT/extract/dw_coreimk/dw_coreimk_mpx_hourly_control_file.dat
##  	$DW_DAT/extract/dw_coreimk/dw_coreimk_mpx_othr_org_hourly_control_file.dat
##  	it should be greater than {CURRENT_DATE-1}_23 DONE
###############################
my $file1=qq(dw_coreimk_mpx_hourly_control_file.dat);
my $file2=qq(dw_coreimk_mpx_othr_org_hourly_control_file.dat);
my $ctrdir=qq(/dw/etl/home/prod/dat/extract/dw_coreimk);
my ($msg,%stat,@tmp);
chdir $TMPDIR;

unless(Time->new($now,'09:00')->minus < 0 or $logcontent=~/$file1/){

system("/usr/local/bin/scp srwimdetl10:$ctrdir/*hourly_control* $TMPDIR >/dev/null");
if($? ne '0'){
    exit "failed scp control files from srwimdetl10.$!\n";
}
open(LOG,">>$LOGFILE")||die "cannot wright into $LOGFILE.\n";
foreach($file1,$file2){
    open(CTRFILE,$_)||die "cannto open $TMPDIR/$_\n";
	chomp($stat{$_}=<CTRFILE>);
    my ($date,$seq)=($1,$2) if ($stat{$_}=~/(\d\d\d\d-\d\d-\d\d)_(\d\d)/);
	$date=~s/-//g;
    if($date < $day[0]){    #### equal to {CURRENT_DATE-1}_* 
	    if($date eq $day[1] and $seq eq '23'){###  equal to {CURRENT_DATE-1}_23 
		    print LOG "\n$now: Checking  $_;\nStatus: $stat{$_};\nReport: Up-To-datated\n$slash\n";
        }
		else{
		    push(@tmp,$_);
		    print LOG "\n$now: Checking  $_;\nStatus: $stat{$_};\nReport: not-updated\n$slash\n";
		}
    }
	else{  
	    print LOG "\n$now: Checking  $_;\nStatus: $stat{$_};\nReport: Up-To-datated\n$slash\n";
	}
    close(CTRFILE);
}
close(LOG);

if(@tmp){    
    foreach(@tmp){
        $msg.="\t$_        $stat{$_}\n";
    }
	$msg=sprintf <<EOF;
Hi AMS team,
	
  Control file was found not Up-To-Date. Please check:
	$slash		
	$msg
	$slash	
Thanks
CDC oncall
EOF
	
	open(MAL,"|/usr/lib/sendmail -t");
    print MAL "To: $CONTACT\n";
    print MAL "From: dx_wang\@pascal.vip.ebay.com\n";
    print MAL "Subject:[AMS monitor]\: AMS Checkpiont Notification!!!\n";
    print MAL "$msg\n";
    close(MAL); 
}
unlink ($file1,$file2);

}
#### Part 3 ###########
##        Check completion of AMS batch
###################

##  we don't have touch file to define the completion of AMS batch...
## all I can do is to find a stupid way to check this..... try to see if my @checkjobs finish or not

my @checkjobs=('TR_AMS_NTWRK_TRFC_SD_INS','TR_AMS_LOADS_DONE_REPORT_EMAIL');
my $rembox='zimsetl09.smf.ebay.com';
my $remdir='/export/home/uc4pe1/executor/temp';
my $mark='ended';
my $jp_stat='Finish';
unless(Time->new($now,'14:00')->minus <0 or $logcontent=~/C_DW_AMS_BATCH_DAILY/){
    foreach(@checkjobs){
		system("/usr/local/bin/ssh aiwang\@$rembox 'cd $remdir;grep $_ `ls -1t|head -1`|grep $day[0]|grep $mark' >/dev/null");
		if($? eq 1){##### if any one of the jobs still doesnt finish
		
		$jp_stat='Not Finish';

		open(MAL,"|/usr/lib/sendmail -t");
		print MAL "To: $CONTACT\n";
		print MAL "From: dx_wang\@pascal.vip.ebay.com\n";
		print MAL "Subject:[AMS monitor]\: AMS Checkpiont Notification!!!\n";
		print MAL "\nHi\n  AMS batch has not finished yet. Please check.\n\nThanks\n";
		close(MAL); 
	
		last;
		}
	}
	
	open(LOG,">>$LOGFILE")||die "cannot wright into $LOGFILE.\n";
	print LOG "\n$now: Checking C_DW_AMS_BATCH_DAILY completion;\nStatus: $jp_stat;\n$slash\n";
    close(LOG);

}

###################  End ##########