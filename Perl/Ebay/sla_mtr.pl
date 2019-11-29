#!/usr/local/bin/perl 
###################################################################################################
# NAME  : sla_monitor.pl 
# TYPE  : perl
# OUTPUT: shows the real time SLA batch status. ETC given.
#
#
# Usage:                #sla_monitor.pl   30  all
#                          '30' :  to show the jobs delayed by 30 mins, set to '0' if empty.
#                          'all' :  to give all the complete/uncomplete jobs which were delayed, show only uncomplete jobs if empty.
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-5-30          1.0         Kevin                   Initial Version
#
#                     Hist_avg file locates at /export/home/dx_wang/kevin/batch/dat/dw_sla_touch_hist.dat,
#                     generated by /export/home/dx_wang/kevin/batch/bin/sla_hist_avg_gen.pl everyday.
####################################################################################################

use strict;

my $Weekday=(localtime(time()))[6];
my $now=sprintf "%02d:%02d",(localtime(time()))[2,1,0];
my ($delay,$select)=(defined @ARGV)?@ARGV:(10);    #How many mins delay is allowed?  default delay set to 10mins
my $slash="="x100;
my $slaover=0;

##################################################################
#                     part 1   Definition
##################################################################

#define the past 10days.
my @day; 
foreach(@day=(0..9)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
}

#minus function
sub minus {
    my ($bigger,$little)=@_;
    my $total=substr($bigger,0,2)*60+substr($bigger,3,2)-substr($little,0,2)*60-substr($little,3,2);
    return $total;
    }
    
# env setting    
my $pwd=`pwd`;
chomp $pwd;
my $HOME="/export/home/dx_wang/kevin/batch";
my $LOGDIR="$HOME/log";
my $ARCDIR="$HOME/arc";
my $TMPDIR="$HOME/tmp";
my $CFGDIR="$HOME/cfg";
my $DATDIR="$HOME/dat";
my $SLA_TOUCH_CFG="$CFGDIR/dw_sla_touch.cfg";
my $SLA_HIST_DAT="$DATDIR/dw_sla_touch_hist.dat";
my $SLA_COMP_CHECK="$TMPDIR/dw_sla_comp_check.$day[0]";
my $SLA_DELAY_DAY="$DATDIR/dw_sla_delay_days.lis";
my $SLA_CORE_LIS="$DATDIR/dw_sla_core.lis";
my $MAIL_SEND_LIS="$DATDIR/dw_sla_mtr.tls";
my $usage="Usage:\t$pwd/sla_monitor.pl   30  all\n\t'30' ->to show the jobs delayed by 30 mins | default='0' if not given.\n\t'all' ->to give all complete/uncomplete jobs which were delayed | show only uncomplete jobs if not given.\n";
#my $info="*Hist_avg file locates at $SLA_HIST_DAT,\ngenerated by $pwd/sla_hist_avg_gen.pl everyday\n";

##################################################################
#                     part 2  Pre_check, Pre_process
##################################################################

# exit if $SLA_COMP_CHECK is already exist;
chdir $TMPDIR;
my @tmp=glob ("dw_sla_comp*$day[0]");
exit if(defined @tmp); 
# transfer the whole touch files list form oterh host
system("ls -tl /export/home/dw_adm/WatchFiles > $TMPDIR/pascal.wfl");
system("/usr/local/bin/ssh dx_wang\@liono.vip.ebay.com 'ls -tl /dw/etl/home/prod/watch/primary' > $TMPDIR/liono.wfl");
#system("/usr/local/bin/ssh dx_wang\@sqwitetl03.smf.ebay.com 'ls -tl /dw/etl/home/prod/watch/primary' > $TMPDIR/etl03.wfl");

open(THFLL,"$TMPDIR/liono.wfl")|| die "can not open $! \n";
my $TOUCH_L=do{local $/;<THFLL>;};
close(THFLL);
open(THFLP,"$TMPDIR/pascal.wfl")|| die "can not open $! \n";
my $TOUCH_P=do{local $/;<THFLP>;};
close(THFLP);
open(HISTDAT,"$SLA_HIST_DAT")||die "can not open $! \n";
my $HISTDAT=do{local $/;<HISTDAT>;};
close(HISTDAT);


open(LOGFILE,">$LOGDIR/dw_sla_touch_status.$day[0]")||die "can not write tmp file:$!";
close(LOGFILE);
open(DELAYLIST,">$LOGDIR/dw_sla_delay_lst.$day[0]")||die "can not wirte file:$!";
print DELAYLIST "\nThe following jobs are $delay mins late than average.\n\n";
close(DELAYLIST);

my ($TH_FILE,$TH_HOST,$TH_SUBJECT_AREA,$TH_UCJOB,$TH_JOBP,$TH_CORE);
my ($finish,$hist,$record,$max,$mail);
my (@TH_FILE);
my (%TOUCH_FILE_LIST,%TH_UCJOB,%TH_SUBJECT_AREA,%TH_JOBP,%CORE_F);

open(MAILLIS,"$MAIL_SEND_LIS")||die "cannot oep $! \n";
	$mail=do {local $/;<MAILLIS>;};
close(MAILLIS);
open(SLACORE,"$SLA_CORE_LIS")||die " cannot open $! \n";
    $TH_CORE=do {local $/;<SLACORE>;};
close(SLACORE);

open(TOUCHCFG,$SLA_TOUCH_CFG)||die "cant open:$!";
    foreach(<TOUCHCFG>){
        chomp;
        ($TH_FILE,$TH_HOST,$TH_SUBJECT_AREA,$TH_UCJOB,$TH_JOBP)=split(' ',$_);
        push(@TH_FILE,$TH_FILE);

        $TH_SUBJECT_AREA{$TH_FILE}=$TH_SUBJECT_AREA;
        $TH_UCJOB{$TH_FILE}=$TH_UCJOB;
		$TH_JOBP{$TH_FILE}=$TH_JOBP;
        if($TH_HOST eq "liono.vip.ebay.com"){
            $TOUCH_FILE_LIST{$TH_FILE}=$TOUCH_L;
        }
        elsif($TH_HOST eq "pascal.vip.ebay.com"){
            $TOUCH_FILE_LIST{$TH_FILE}=$TOUCH_P;
        }
        else{
            warn"***Please check the host name for $TH_FILE!\n";
        }
        
    }
close(TOUCHCFG);

##################################################################
#                     part 3  start checking
##################################################################
open(LOGFILE,">>$LOGDIR/dw_sla_touch_status.$day[0]")||die "can not write tmp file:$!";
open(DELAYLIST,">>$LOGDIR/dw_sla_delay_lst.$day[0]")||die "can not wirte file:$!";
printf DELAYLIST "%-10s%-10s%-50s%-30s\n$slash\n",'Status','Avg','UC4_job_names','UC4_jobplan';

    foreach(@TH_FILE){
		$hist=$1 if($HISTDAT=~/(..:..)     $_/);
	    if($TOUCH_FILE_LIST{$_}=~/(..:..) $_/){
            $finish=$1;
			#if it's Friday, ajust the complete time by 1h.
		    if($Weekday==5){ 
		        $finish=sprintf "%02d:%02d",substr($finish,1,2)-1,substr($finish,3,2);
		    }
			printf LOGFILE "%-10s%-60s\n",$finish,$_;
			
			if($select eq 'all' and minus($finish,$hist)>$delay){
			    printf DELAYLIST "%-10s%-10s%-50s%-30s\n",$finish,$hist,$TH_UCJOB{$_},$TH_JOBP{$_};
				$record++;
		    }	
			# find out the maxtime,  in other words, SLA finish time
			if(minus($finish,$max)>0){
			    $max=$finish;
			}
			# log the core subject finish time
			if($TH_CORE=~/$_/){
			    $CORE_F{$_}=$finish;
			}
        }    
        else{
			$finish="N";
			$slaover=1;
			if($Weekday==5){
			    $delay+=60;
			}
			if(minus($now,$hist)>$delay){
		        printf DELAYLIST "%-10s%-10s%-50s%-30s\n",$finish,$hist,$TH_UCJOB{$_},$TH_JOBP{$_};
			    $record++;
		    }	
		}
    }

##################################################################
#                     part 4  Post touch&output
##################################################################	
# IF SLA has finished
if($slaover==0){
#touch SLA complete file 
    open(SLACOMP,">>$SLA_COMP_CHECK")||die "cannot write file:$!\n";  
	print SLACOMP $slash,"\n";
	print SLACOMP "SLA has finished at $max.\n\n";
	foreach $TH_FILE (keys %CORE_F){
	    printf SLACOMP "%-10s%-20s%-40s\n",$CORE_F{$TH_FILE},$TH_SUBJECT_AREA{$TH_FILE},$TH_FILE;
	}
	print SLACOMP $slash,"\n";
	close(SLACOMP);
	open(SLACOMP,"$SLA_COMP_CHECK")||die "cannot open file:$!\n";  
	print <SLACOMP>;
	close(SLACOMP);
	system("cat $SLA_COMP_CHECK | mailx -s '[SLA Monitor]: Jobs Finished \@ $max.' $mail");
# record the day if the SLA complete time is too late;
	open(EXDAYLIS,">>$SLA_DELAY_DAY")||die "cannot write file:$!\n";
	print EXDAYLIS $day[0] if(minus($max,'07:00')>0);  
	close(EXDAYLIS) ;
#generate the hist-avg time list
#	system("/export/home/dx_wang/kevin/batch/bin/sla_hist_avg_gen.pl 7 all");
	exit;
}
# Else move on 
if($Weekday==5){
    print DELAYLIST "\* All Friday statistics have been ajusted by 1h.\n";
}   
print DELAYLIST "\n$slash\n$usage";
close(LOGFILE);
close(DELAYLIST);
open(DELAYLIST,"$LOGDIR/dw_sla_delay_lst.$day[0]")||die "cannot open file $!";
print <DELAYLIST>;
close(DELAYLIST);

if($record >=1){
system("cat $LOGDIR/dw_sla_delay_lst.$day[0] | mailx -s '[SLA Monitor]: Jobs delayed.' $mail");
}        
chdir $TMPDIR;
unlink("dw_sla_comp_check.$day[1]");