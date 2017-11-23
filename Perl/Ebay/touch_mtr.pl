#!/usr/local/bin/perl 
###################################################################################################
# NAME  : touch_mtr.pl 
# TYPE  : perl
# OUTPUT: shows the real time batch touch status. 
#
#
# Usage:                #touch_mtr.pl   $subjuect_area 30  all
#                          '30' :  to show the jobs delayed by 30 mins, set to '0' if empty.
#                          'all' :  to give all the complete/uncomplete jobs which were delayed, show only uncomplete jobs if empty.
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-5-30          1.0         Kevin                   Initial Version
# 2008-6-23          1.1          Kevin         fix the case that th file is removed later, by using pending list file.
#2008-11-21           1.2         Kevin        add the Time.pm
#                     Hist_avg file locates at /export/home/dx_wang/kevin/batch/dat/"$SUBJECT_AREA"_touch_hist.dat,
####################################################################################################

use lib ("/export/home/dx_wang/kevin/batch/lib");
use strict;
use Time;

##  define the past 10days.
my @day; 
foreach(@day=(0..9)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
}

##################################################################
#                     part 1   env setting up
################################################################## 
my $slash="="x100;
my $compflag=0;
my $Weekday=(localtime(time()))[6];
my $now=sprintf "%02d:%02d",(localtime(time()))[2,1];
my $pwd=$ENV{'pwd'};
chomp $pwd;
my $usage=sprintf <<EOF;

Usage:\t$pwd\./touch_mtr.pl \$SUBJECT_AREA 30 all
\t\$SUBJECT_AREA  -> subject area:dw_sla,dw_kwdm...
\t'30' ->to show the jobs delayed by 30 mins | default='0' if not given.
\t'all' ->to give all complete/incomplete jobs which were delayed | show only incomplete jobs if not given.

EOF

# fetch $SUBJECT_AREA from outside argv
my ($SUBJECT_AREA,$delay,$select,$limit)=(defined @ARGV)?@ARGV:('dw_kwdm','120','all','23:00');    
my $SUBJECT_NAME=substr(uc($SUBJECT_AREA),3);
my $HOME="/export/home/dx_wang/kevin/batch";
my $LOGDIR="$HOME/log";
my $ARCDIR="$HOME/arc";
my $TMPDIR="$HOME/tmp";
my $CFGDIR="$HOME/cfg";
my $DATDIR="$HOME/dat";
my $CFGDIR="$HOME/cfg";
my $TOUCH_LIST_CFG="$CFGDIR/${SUBJECT_AREA}_touch.cfg";
my $HIST_AVG_DAT="$DATDIR/${SUBJECT_AREA}_touch_hist.dat";
my $COMP_CHECK_FILE="$TMPDIR/${SUBJECT_AREA}_comp_check.$day[0]";
my $PEND_LIST_FILE="$LOGDIR/${SUBJECT_AREA}_touch_pending.lis.$day[0]";
my $DELAYED_DAY_LIST="$DATDIR/${SUBJECT_AREA}_delay_days.lis";
my $MAIL_SEND_LIS="$DATDIR/daily_batch_mtr.tls";
my $DAILY_MTR_CFG="$CFGDIR/daily_batch_mtr.cfg";
my $DAILY_LOG="$LOGDIR/${SUBJECT_AREA}_touch_mtr.log.$day[0]";


chdir $TMPDIR;
# exit if $COMP_CHECK_FILE is already exist;
my ($today_complete)=glob ("${SUBJECT_AREA}_comp*$day[0]");
if($today_complete){
    print "\n<$SUBJECT_NAME Batch already completed>\n\n";
    exit;
} 

open(DAILYLOG,">$DAILY_LOG")||die "cannot creat $DAILY_LOG.\n";
print DAILYLOG "Check the status for $SUBJECT_NAME\n\n";
open(DAILYLOG,">>$DAILY_LOG")||die "cannot creat $DAILY_LOG.\n";

### get parameter for a seperate run, it they are not given
if(@ARGV!='4'){
    print DAILYLOG "4 pars required:    \$subject,\$delay,\$select,\$limit\nOnly \'@ARGV\' given, now searching other default pars from $DAILY_MTR_CFG.\n\n";
}
if(!defined $delay){
open(MTRCFG,"$DAILY_MTR_CFG")||die "cannot open daily_batch_mtr.cfg $!\n";
    foreach(<MTRCFG>){      
        if($_=~/$SUBJECT_AREA/){
            ($delay)=(split(' ',$_))[-3];               
        }
    }
    print DAILYLOG "set defaut \$delay to $delay mins...\n";
close(MTRCFG);
}

if(!defined $select){
open(MTRCFG,"$DAILY_MTR_CFG")||die "cannot open daily_batch_mtr.cfg $!\n";
    foreach(<MTRCFG>){      
        if($_=~/$SUBJECT_AREA/){
            ($select)=(split(' ',$_))[-2];              
        }
    }
    print DAILYLOG "set defaut \$select to \'$select\'...\n";
close(MTRCFG);
}

if(!defined $limit){
open(MTRCFG,"$DAILY_MTR_CFG")||die "cannot open daily_batch_mtr.cfg $!\n";
    foreach(<MTRCFG>){      
        if($_=~/$SUBJECT_AREA/){
            ($limit)=(split(' ',$_))[-1];               
        }
        }
        print DAILYLOG "set defaut \$limit to $limit, record \$today if batch is late beyond $limit...\n";
close(MTRCFG);
}

##################################################################
#                     part 2  Pre_check, Pre_process
##################################################################
print DAILYLOG "\n<Start checking>\n";

# transfer the whole touch files list form oterh host
system("ls -tl /export/home/dw_adm/WatchFiles > $TMPDIR/pascal.wfl");
open(REMSRC,"$HOME/src/remote_src.lis")||die "cannot open $HOME/src/remote_src.lis\n";
foreach(<REMSRC>){
    my($wflname,$login,$rembox,$remdir)=(split(' ',$_));
    system("/usr/local/bin/ssh $login\@$rembox 'ls -tl $remdir' > $TMPDIR/$wflname");
}

open(THFLL,"$TMPDIR/etl10.wfl")|| die "can not open etl10.wfl.$! \n";
my $TOUCH_10=do{local $/;<THFLL>;};
close(THFLL);
open(THFLP,"$TMPDIR/pascal.wfl")|| die "can not open pascal.wfl.$! \n";
my $TOUCH_P=do{local $/;<THFLP>;};
close(THFLP);
open(THFL03,"$TMPDIR/etl11.wfl")|| die "can not open etl11.wfl.$! \n";
my $TOUCH_11=do{local $/;<THFL03>;};
close(THFL03);
open(HISTDAT,"$HIST_AVG_DAT")||die "can not open $HIST_AVG_DAT.$! \n";
my $HISTDAT=do{local $/;<HISTDAT>;};
close(HISTDAT);

# here're all the needed stuff..
my ($TH_FILE,$TH_HOST,$TH_SUBJECT_AREA,$TH_UCJOB,$TH_JOBP,$TH_CORE);
my ($finish,$hist,$record,$tmp,$max,$mail);
my (@TH_FILE,@TMP,@DONE,@PEND,@mail);
my (%TOUCH_FILE_LIST,%TH_UCJOB,%TH_SUBJECT_AREA,%TH_JOBP,%FINISH,%CORE_F);

open(MAILLIS,"$MAIL_SEND_LIS")||die "cannot open $MAIL_SEND_LIS $! \n";
    foreach(<MAILLIS>){
        if((split(' ',$_))[0] eq "$SUBJECT_AREA"){
            ($tmp,@mail)=(split(' ',$_));
        }
    }
    $mail=sprintf "@mail";
close(MAILLIS);

open(TOUCHCFG,$TOUCH_LIST_CFG)||die "cant open $TOUCH_LIST_CFG:$!";
    foreach(<TOUCHCFG>){
        chomp;
        ($TH_FILE,$TH_HOST,$TH_SUBJECT_AREA,$TH_UCJOB,$TH_JOBP)=split(' ',$_);
        push(@TH_FILE,$TH_FILE);
        $TH_SUBJECT_AREA{$TH_FILE}=$TH_SUBJECT_AREA;
        $TH_UCJOB{$TH_FILE}=$TH_UCJOB;
        $TH_JOBP{$TH_FILE}=$TH_JOBP;
        
        if($TH_HOST eq "srwimdetl10.smf.ebay.com" or $TH_HOST eq "sqwitetl01.smf.ebay.com"){
            $TOUCH_FILE_LIST{$TH_FILE}=$TOUCH_10;
        }
        elsif($TH_HOST eq "pascal.vip.ebay.com"){
            $TOUCH_FILE_LIST{$TH_FILE}=$TOUCH_P;
        }
        elsif($TH_HOST eq "srwimdetl11.smf.ebay.com"){
            $TOUCH_FILE_LIST{$TH_FILE}=$TOUCH_11;
        }
        else{
            warn"***Please check the host name for $TH_FILE!\n";
        }
        
    }
close(TOUCHCFG);

#generate the hist-avg time list at the daily 1st run
chdir $TMPDIR;
my $last_complete="$TMPDIR/${SUBJECT_AREA}_comp_check.$day[1]";
if(-e $last_complete){
    system("/export/home/dx_wang/kevin/batch/bin/hist_avg_gen.pl $SUBJECT_AREA");
    unlink($last_complete);
    
    open(PENDLIS,">$PEND_LIST_FILE")||die "cannot create $PEND_LIST_FILE";    #generate a new pending list.
    open(PENDLIS,">>$PEND_LIST_FILE")||die "cannot write into $PEND_LIST_FILE";
    foreach(@TH_FILE){
    print PENDLIS "$_\n";
    }
    close(PENDLIS);
}

##################################################################
#                     part 3  start checking
##################################################################
###update pending check list
open(PENDLIS,"$PEND_LIST_FILE")||die "cannot open $PEND_LIST_FILE";
@TMP=<PENDLIS>;
chomp @TMP;
close(PENDLIS);

open(PENDLIS,">$PEND_LIST_FILE")||die "cannot create $PEND_LIST_FILE";
open(PENDLIS,">>$PEND_LIST_FILE")||die "cannot write into $PEND_LIST_FILE";
### update TH status file
open(THSTA,">>$LOGDIR/${SUBJECT_AREA}_touch_status.$day[0]")||die "can not write THSTA file:$!";

foreach(@TMP){
    if($TOUCH_FILE_LIST{$_}=~/(..:..) $_\n/){
        $finish=$1;                  
        printf THSTA "%-10s%-60s\n",$finish,$_;
    }
    else{
        $compflag=1;
        $finish='N';
        print PENDLIS "$_\n";
        push(@PEND,$_);       #---->now  we get a  new pending list 
    }
    $FINISH{$_}=$finish;
}
$max=(Time->new(values %FINISH)->max);   #------->  the latest generated file, it's time	

close(THSTA);
close(PENDLIS);

### define delayed files list, and write delay log      
open(DELAYTMP,">$TMPDIR/${SUBJECT_AREA}_delay.tmp")||die "can not wirte file:$!";
print DELAYTMP "\nAction required!!!    The following jobs are late than average by $delay mins or even longer!!! \n\n";

open(DELAYTMP,">>$TMPDIR/${SUBJECT_AREA}_delay.tmp")||die "can not wirte file:$!";
printf DELAYTMP "%-10s%-10s%-50s%-30s\n$slash\n",'Status','Avg','UC4_job_names','UC4_jobplan';

open(WORKTMP,">>$TMPDIR/working.tmp")||die "can not wright tmp file";
    foreach (@PEND){
        $hist=$1 if($HISTDAT=~/(..:..)     $_/);
        $finish=$FINISH{$_};   ## -------> now it's 'N' acctually.  equal to  ($finish = 'N';)
        next if(! defined($hist));  #------------> if no historical time found, skip.   thats for newly added touch file item. we'dnot show it in the delay list for the 1st run
                
        if($Weekday==5){
        $hist=sprintf "%02d:%02d",(split(':',$hist))[0]+1,(split(':',$hist))[1]; # that's for Friday adjustment;
        }
                
        if((Time->new($now,$hist)->minus) > $delay*60){
            $record++;
            printf WORKTMP "%-10s%-10s%-50s%-30s\n",$finish,$hist,$TH_UCJOB{$_},$TH_JOBP{$_};    
        }   
    }
##   devide all TH file list to PENDING part and DONE part
    foreach $TH_FILE (@PEND){
        @DONE=map{$_ if $TH_FILE ne $_} @TH_FILE;               
    }
## print more infomation if $selete = all.      
if($select eq 'all'){
    open(THSTA,"$LOGDIR/${SUBJECT_AREA}_touch_status.$day[0]")||die "can not open THSTA file:$!";
    $tmp=do {local $/;<THSTA>;};
    close(THSTA);
                
    foreach(@DONE){
        $hist=$1 if($HISTDAT=~/(..:..)     $_/);
        $finish=$1 if($tmp=~/(..:..)     $_/);
        next if(! defined($hist));  #------------> if no historical time found, skip.   mainly for newly added touch file
                
        if($Weekday==5){
        $hist=sprintf "%02d:%02d",(split(':',$hist))[0]+1,(split(':',$hist))[1]; # that's for Friday adjustment;
        }
                
        if((Time->new($finish,$hist)->minus) > $delay*60){
        $record++;
        printf WORKTMP "%-10s%-10s%-50s%-30s\n",$finish,$hist,$TH_UCJOB{$_},$TH_JOBP{$_};
        }       
    }
}
close(WORKTMP);
qx(cat $TMPDIR/working.tmp|sort -r >>"$TMPDIR/${SUBJECT_AREA}_delay.tmp");

##################################################################
#                     part 4  Post touch&output
##################################################################      
# IF  has finished
if($compflag==0){
#touch complete file 
    open(COMPCHECK,">>$COMP_CHECK_FILE")||die "cannot write file:$!\n";  
        print COMPCHECK "$slash\n\n$SUBJECT_AREA has finished at $max.\n$slash\n";
        
    open(COMPCHECK,"$COMP_CHECK_FILE")||die "cannot open file $COMP_CHECK_FILE:$!\n";  
        print DAILYLOG <COMPCHECK>;
    close(COMPCHECK);

# record the day if the batch complete time is too late, based on $limit;
    if((Time->new($now,$hist)->minus) > 0){
    open(EXDAYLIS,">>$DELAYED_DAY_LIST")||die "cannot write file $DELAYED_DAY_LIST:$!\n";
    print EXDAYLIS "$day[0]\n";
    close(EXDAYLIS);        
    print DAILYLOG "Batch is beyond $limit, add $day[0] into $DELAYED_DAY_LIST;\n"; 
    }  

}
else{   
    if($Weekday==5){   ## if it's Fri, then ...
        print DELAYTMP "\n\* All Friday statistics have been ajusted by 1h.\n";
    }   
    print DELAYTMP "\n$slash\n$usage\n";

    open(DELAYTMP,"$TMPDIR/${SUBJECT_AREA}_delay.tmp")||die "cannot open file $!";
    print DAILYLOG <DELAYTMP>;
    close(DELAYTMP);
    
    if((Time->new($now,$limit)->minus) > 0){  # send out notification if the batch is behind $limit;
        open(COMPCHECK,">$COMP_CHECK_FILE")||die "cannot create file $COMP_CHECK_FILE:$!\n";  
        close(COMPCHECK);
        
        open(EXDAYLIS,">>$DELAYED_DAY_LIST")||die "cannot write file $DELAYED_DAY_LIST:$!\n";
        print EXDAYLIS "$day[0]\n";
        close(EXDAYLIS);        
        print DAILYLOG "Batch is beyond $limit, add $day[0] into $DELAYED_DAY_LIST;\n";
        
        system("mailx -s '[$SUBJECT_NAME Monitor]: $SUBJECT_NAME run past $now.' $mail");
    }
    else{
        if($record >=1){ ### only send this email when delayed jobs are found.
        system("cat $TMPDIR/${SUBJECT_AREA}_delay.tmp | mailx -s '[$SUBJECT_NAME Monitor]: Jobs delayed.' $mail");
        }
    }
}
    
print DAILYLOG "\n<End checking>\n\n";

open(DAILYLOG,"$DAILY_LOG")||die "cannot open $DAILY_LOG.\n";
print <DAILYLOG>;
close(DAILYLOG);
## remove all .tmp files.
chdir $TMPDIR;
unlink(glob("*.tmp"));
###########################End of program############################ 