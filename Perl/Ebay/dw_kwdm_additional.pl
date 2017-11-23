#!/usr/local/bin/perl 
use strict;

######################
#  definition
######################
my $now=sprintf "%02d:%02d",(localtime(time()))[2,1];
##  define the past 10days.
my @day; 
foreach(@day=(0..9)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
}
## minus function
sub minus {
    my ($bigger,$little)=@_;
    my $total=substr($bigger,0,2)*60+substr($bigger,3,2)-substr($little,0,2)*60-substr($little,3,2);
    return $total;
    }

my $HOME="/export/home/dx_wang/kevin/batch";
my $LOGDIR="$HOME/log";
my $ARCDIR="$HOME/arc";
my $TMPDIR="$HOME/tmp";
my $CFGDIR="$HOME/cfg";
my $DATDIR="$HOME/dat";
my $EXEDIR="$HOME/bin"; 
# KWDM additional daily tasks/checks.
chdir $LOGDIR;
my ($kwdm_add_log)=glob("dw_kwdm_additional.*.$day[0]");
my $logcontent;
if(!$kwdm_add_log){
    open(ADDLOG,">dw_kwdm_additional.log.$day[0]")||die "cannot creat dw_kwdm_additional.log.$day[0]\n";
        close(ADDLOG);
}
else{
    open(ADDLOG,"$kwdm_add_log")||die "cannnot open $kwdm_add_log";
        $logcontent=do {local $/; <ADDLOG>;};
        close(ADDLOG);
}

open(ADDLOG,">>dw_kwdm_additional.log.$day[0]")||die "cannnot open $LOGDIR/dw_kwdm_additional.log.$day[0]";
######################
# check DW_KWDM_SCRUB_KW @7am 
######################
my ($Stubhub_ld_log)="dw_kwdm_stubhub_trffc_00_w.ld.single_table_load.$day[0]*log";
my $remote_cmd="ls -tl /dw/etl/home/prod/log/primary/dw_kwdm/$Stubhub_ld_log >/dev/null";
my $return_code=system("/usr/local/bin/ssh dx_wang\@sqwitetl03.smf.ebay.com $remote_cmd");
my $Stubhub_mls="$DATDIR/dw_kwdm/Stubhub.mls";
my $Scrub_mls="$DATDIR/dw_kwdm/Scrub.mls";
my $Stubhub_tls="$DATDIR/dw_kwdm/Stubhub.tls";
my $Scrub_tls="$DATDIR/dw_kwdm/Scrub.tls";
my $Stubhub_deadline="06:40";
my $Scrub_deadline="07:00";
my ($Scrub_log)=glob("/export/home/dw_adm/log/dw_kwdm_scrub_kw.ksh-$day[0]*log");
unless($logcontent=~/scrub done/){
    if($Scrub_log){
        print ADDLOG "stubhub done\nscrub done\n";
    }
    else{
        if($return_code!='0' and minus($now,$Stubhub_deadline)>0 and $logcontent!~/stubhub done/){
                system("cat $Stubhub_mls|mailx -s '[KWDM monitor]: Please higher Stubhub ld priority' `cat $Stubhub_tls`");
                    print ADDLOG "stubhub done\n";
            }
            elsif(minus($now,$Scrub_deadline)>0){
                system("cat $Scrub_mls|mailx -s '[KWDM monitor]: Please investigate why DW_KWDM_SCRUB_KW has not started' `cat $Scrub_tls`");
                    print ADDLOG "scrub done\n";
            }
    }
}


my $status_log="$LOGDIR/dw_kwdm_touch_status.$day[0]";
open(TOUCHSTAT,"$status_log")|| die "cannot open $status_log \n";
my $touch_files=do {local $/;<TOUCHSTAT>;};
######################
# check "dw_kwdm_perf_data.done" @14am
######################
my $cost_feed_deadline="14:00";
my $cost_feed_file="dw_kwdm_perf_data.done";
my $COST_DATA_FEED_tls="$DATDIR/dw_kwdm/COST_DATA_FEED.tls";
my $COST_DATA_FEED_mls="$DATDIR/dw_kwdm/COST_DATA_FEED.mls";

close(TOUCHSTAT);
unless($logcontent=~/COST FEED done/){
    if($touch_files=~/(..:..)     $cost_feed_file/){
            print ADDLOG "COST FEED done\n";
        }
    else{
            if(minus($now,$cost_feed_deadline)>0){
            system("cat $COST_DATA_FEED_mls|mailx -s '[KWDM monitor]: Please let us know when 'dw_kwdm_perf_data.done' will be ready.' `cat $COST_DATA_FEED_tls`");
                print ADDLOG "COST FEED done\n";
                }
    }
}


#######################
# check     C_DW_KWDM_TR_PRTNR_KW_SD_MPXLT by 5pm:
#######################
my $SD_MPXLT_DONE="dw_kwdm_prtnr_kw_sd_mpxlt_load.done";
my $MPXLT_deadline="17:00";
my $MPXLT_mls="$DATDIR/dw_kwdm/MPXLT.mls";
my $MPXLT_tls="$DATDIR/dw_kwdm/MPXLT.tls";

unless($logcontent=~/KW_SD_MPXLT/){
    if($touch_files=~/(..:..)     $SD_MPXLT_DONE/){
            print ADDLOG "KW_SD_MPXLT\n";
        }
    else{
            if(minus($now,$MPXLT_deadline)>0){
            system("cat $MPXLT_mls|mailx -s '[KWDM monitor]: C_DW_KWDM_TR_PRTNR_KW_SD_MPXLT not finish yet.' `cat $MPXLT_tls`");
                print ADDLOG "KW_SD_MPXLT\n";
                }
    }
}



close(ADDLOG);    