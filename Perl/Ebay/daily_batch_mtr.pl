#!/usr/local/bin/perl 
###################################################################################################
# NAME  : daily_batch_mtr.pl 
# TYPE  : perl
# Usage   show the delayed jobs list.
#               implement special daily tasks for indivisual subject area.
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-6-3          1.0         Kevin                   Initial Version
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
my $DAILY_MTR_CFG="$CFGDIR/daily_batch_mtr.cfg";
my $ADD_TASK;
my $slash_a='#'x100;
my ($symbol,$SUBJECT_AREA,$delay,$select,$limit);
chdir $EXEDIR;
open(MTRCFG,"$DAILY_MTR_CFG")||die "cannot open daily_batch_mtr.cfg $!\n";
    foreach(<MTRCFG>){
        ($symbol,$SUBJECT_AREA,$delay,$select,$limit)=split(' ',$_);
        if($symbol eq '+'){
            print "$slash_a\n";
            system("$EXEDIR/touch_mtr.pl $SUBJECT_AREA $delay $select");

            ($ADD_TASK)=glob("$SUBJECT_AREA"."_additional.*");
            if($ADD_TASK){
                print "$slash_a\n";
                print "Start running $SUBJECT_AREA daily additional tasks.\n";
                system("$EXEDIR/$ADD_TASK");
            }
        }
    }
close(MTRCFG);