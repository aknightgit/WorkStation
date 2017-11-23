#!/usr/bin/perl 

###################### SLA touchfile deadline check ############################
use strict;

## minus function
sub minus {
    my ($bigger,$little)=@_;
    my $total=(split(':',$bigger))[0]*60+(split(':',$bigger))[1]-(split(':',$little))[0]*60-(split(':',$little))[1];
    return $total;
    }
## env definition
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()); 
my $today=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
my $now=sprintf "%02d:%02d",$hour,$min;
my $slash="#"x50;

my $HOME="/export/home/dx_wang/kevin/batch";
my $CFGDIR="$HOME/cfg";
my $LOGDIR="$HOME/log";
my $logname=(split('/',$0))[-1];
$logname=~s/pl/log/g;

my $CFGFILE="$CFGDIR/dw_sla_deadline.cfg";
my $LOGFILE="$LOGDIR/$logname";
my $CHKFILE="$LOGDIR/dw_sla_touch_status.$today";        # -------------------> status of the exist files.

my ($TH_FILE,$DEADLINE,$UCJOB,$done);
my (@TH_FILE,@done,@tmp);
my (%DEADLINE,%DESC,%UCJOB);

open(CFG, "$CFGDIR/dw_sla_deadline.cfg");
foreach(<CFG>){
    chomp $_;
    ($TH_FILE,$DEADLINE,$UCJOB,@tmp)=(split(' ',$_));
    push(@TH_FILE,$TH_FILE);
        if($wday == 5){
                $DEADLINE=sprintf "%02d:%02d",(split(':',$DEADLINE))[0]+1,(split(':',$DEADLINE))[1];    
        }
    $DEADLINE{$TH_FILE}=$DEADLINE;
    $UCJOB{$TH_FILE}=$UCJOB;
        $DESC{$TH_FILE}=sprintf "@tmp";
}
close CFG;

open(CHKFILE,"$CHKFILE")||die "cannot open $CHKFILE\n";
    foreach(<CHKFILE>){
            chomp;
                $done=(split(' ',$_))[-1];
                push(@done,$done);
        }
close(CHKFILE);

foreach $done (@done){
        @TH_FILE=grep {$_ if $_ ne $done} @TH_FILE;
}

exit if(scalar(@TH_FILE)==0); 
open(LOG,">>$LOGFILE")||die "cannot creat or write file";
print LOG "Checking SLA TH files at $now;\n";
foreach(@TH_FILE){
	print LOG "\tFiles found not ready: $_;";
	    unless(minus($now,$DEADLINE{$_})<0){
            my $msg="\tAction required!!! \n\n\tA SLA job is found beyond its deadline\:\n\n\t$slash";
            my $msg2="\n\tTouch file\:\t$_\n\tDeadline\:\t$DEADLINE{$_}\n\tUC_JOB\:\t$UCJOB{$_}\n\tDescription\:\t$DESC{$_}\n\t$slash\n";
            my $msg3="\n\n\tThis may impact/delay today's SLA job. Check what's going on!!!\n";
        open(MAL,"|/usr/lib/sendmail -t");
        print MAL "To: aiwang\@ebay.com \n";
        print MAL "From: dx_wang\@pascal.vip.ebay.com\n";
        print MAL "Subject:[Action Required]\: SLA Jobs Deadline Notification!!!\n";
        print MAL "\n${msg}${msg2}${msg3}";
        close(MAL);   
		
		print LOG " and late beyond the deadline $DEADLINE{$_};"
        }
	print LOG "\n";
}
close(LOG);
############################ end of program ##############################