#!/usr/bin/perl 

###################### imk touchfile deadline check ############################
use strict;

## minus function
sub minus {
    my ($bigger,$little)=@_;
    my $total=(split(':',$bigger))[0]*60+(split(':',$bigger))[1]-(split(':',$little))[0]*60-(split(':',$little))[1];
    return $total;
    }
## env definition
my $HOME="/export/home/dx_wang/kevin/batch";
my $CFGDIR="$HOME/cfg";
my $LOGDIR="$HOME/log";
my $TMPDIR="$HOME/tmp";
my $CFGFILE="$CFGDIR/dw_imk_deadline.cfg";
my $LOGFILE="$LOGDIR/dw_imk_additional.log";
my $WFL="$TMPDIR/etl10.wfl";        # -------------------> where's our watch file list from 

my ($TH_FILE,$DEADLINE,$CONTACT,$done);
my (@TH_FILE,@COMPLETE_LIST);
my (%DEADLINE,%CONTACT);

my $now=sprintf "%02d:%02d",(localtime(time()))[2,1];
my $slash="#"x50;

open(CFG, "$CFGDIR/dw_imk_deadline.cfg");
foreach(<CFG>){
        chomp $_;
        ($TH_FILE,$DEADLINE,$CONTACT)=(split(' ',$_));
        push(@TH_FILE,$TH_FILE);
        $DEADLINE{$TH_FILE}=$DEADLINE;
        $CONTACT{$TH_FILE}=$CONTACT;
}
close CFG;


open(LOG,"$LOGFILE")||open(LOG,">$LOGFILE");
        @COMPLETE_LIST=<LOG>;
        chomp @COMPLETE_LIST;
close(LOG);

## delete the unwanted elements,   just check the ones which are unavailable now 
foreach $done (@COMPLETE_LIST){
    @TH_FILE=grep{$_ if($done ne $_)} @TH_FILE;  
}

## look for file into etl10.wfl
open(WFL,"$WFL")||die "can not open etl10.wfl\n";
my $TOUCH_L=do{local $/;<WFL>;};
close(WFL);

open(LOG,">>$LOGFILE")||die "can not wright into $LOGFILE\n";
foreach(@TH_FILE){
        unless(minus($now,$DEADLINE{$_})<0){  #----------------->  wait till deadline time, or skip checking
                if($TOUCH_L!~/$_/){
                        my $msg="\tA touch file was found beyond its deadline\:\n\n\t$slash\n\tTouch file\:\t$_\n\tDeadline\:\t$DEAD
LINE{$_}\n\t$slash\n";
                        my $msg1="\n\n\tThis file is still unaviable, please contact $CONTACT{$_} ASAP!!!!!\n";
                        open(MAL,"|/usr/lib/sendmail -t");
                        print MAL "To: aiwang\@ebay.com dl-ebay-sha-imd-dima-cdc-oncall\@ebay.com\n";
                        print MAL "From: dx_wang\@pascal.vip.ebay.com\n";
                        print MAL "Subject:[Action Required]\: IMK Touchfile Deadline Notification!!!\n";
                        print MAL "\n${msg}${msg1}";
                        close(MAL);     
                }
                print LOG "$_\n";    #--------->  log this file, whether it exists or not. Then it will not send the notification ag
ain.
        }       
}
close(LOG);

############################ end of program ##############################