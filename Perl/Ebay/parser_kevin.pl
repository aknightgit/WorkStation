#!/usr/local/bin/perl 
###################################################################################################
# NAME  : parser_monitor.pl 
# TYPE  : perl
# OUTPUT: shows the real time DW_ATTR_PARSER status. ETC given.
#
#
# Usage:
# /export/home/aiwang/sla/parser.pl
#
#
# Date              Ver#         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-4-12          1.0         Kevin                   Initial Version
# 2008-5-15          1.1         Kevin                   ETC setup
# 2008-5-20          1.2         Kevin                   consider the restart case
####################################################################################################

use strict;

my $home="/export/home/dx_wang";
my $mytmp="$home/tmp";

##################################################################################################
#                     part 1   Definition
###################################################################################################
#define the past 10days.
my @day; 
foreach(@day=(0..9)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$_);     
    $_=sprintf "%4d%02d%02d",$year+1900,$mon+1,$mday;
}

#minus function
sub minus {
    my ($bigger,$little,$total);
    ($bigger,$little)=@_;
    $total=substr($bigger,0,2)*3600+substr($bigger,3,2)*60+substr($bigger,6,2)-substr($little,0,2)*3600-substr($little,3,2)*60-substr($little,6,2);
    sprintf "%02d:%02d:%02d",$total/3600,$total%3600/60,$total%60;  
    }
#time plus function
sub plus {
    my ($a,$b,$total)=@_;
    $total=substr($a,0,2)*3600+substr($a,3,2)*60+substr($a,6,2)+substr($b,0,2)*3600+substr($b,3,2)*60+substr($b,6,2);
    sprintf "%02d:%02d:%02d",$total/3600,$total%3600/60,$total%60; 
    }

my $DW_HOME="/dw/etl/home/prod";
my $DW_LOG="$DW_HOME/log";
my $DW_IN="$DW_HOME/in";
my $DW_ARC="$DW_HOME/arc";
my $DW_CFG="$DW_HOME/cfg";
my $DW_DAT="$DW_HOME/dat";
my $ETL_ID="dw_attr.item_attr_info";
my ($SUBJECT,$TABLE_ID)=split(/\./,$ETL_ID);
my $JOB_TYPE="extract";
my $JOB_TYPE_ID="ex";
my $JOB_HANDLER="dw_attr.dw_attr_parser_handler.ksh";
my $HANDLER=(split(/\./,$JOB_HANDLER))[1];

my ($tmp,$i,$FINISH,@tmp,$logcontent,%IS_CATY,$ETC,$status,$rate);
my ($INFO_DATA,$ARC_FILE,$CHECK_LOG,$LOG_FILE,$LOG_FILE_0,$ATT_FILE,$FIELD_LOG,$SRC_LIS_FILE);
my ($SEQ_NUM,$SRC_ID,$START_TIME,$END_TIME,$JOB_START,$JOB_FINISH,$COST_TIME,$TOT_TIME,$TOT_b,$att_queue);
my (@ATT_QUEUE,@DATA_FILE,@ATT_FILE,@LOG_FILE,@ARC_FILE,@TARGET_ETL_ID,@TARGET_TABLE,@TARGET_CFG,@FIELD_ID,@TOT_REC,@AVG_REC);
my $slash="="x80;
my $slash1="-"x80;

@ATT_FILE=<$DW_LOG/$JOB_TYPE/$SUBJECT/$TABLE_ID.$JOB_TYPE.parse.$day[0]-*.att>;
$ATT_FILE=@ATT_FILE[-1];

@LOG_FILE=(<$DW_ARC/$JOB_TYPE/$SUBJECT/$TABLE_ID.$JOB_TYPE_ID.$SUBJECT.$HANDLER.$day[0]-*.log>,<$DW_LOG/$JOB_TYPE/$SUBJECT/$TABLE_ID.$JOB_TYPE_ID.$SUBJECT.$HANDLER.$day[0]-*.log>);
$LOG_FILE=$LOG_FILE[-1];
if (@ATT_FILE>1){
        $LOG_FILE_0=$LOG_FILE[0];
}
else{
        $LOG_FILE_0=$LOG_FILE;
}

@ARC_FILE=(<$DW_ARC/$JOB_TYPE/$SUBJECT/$TABLE_ID.$JOB_TYPE_ID.$SUBJECT.$HANDLER.$day[7]-*.log>);
$ARC_FILE=@ARC_FILE[-1];

my $SEQ_NUM_FILE="$DW_DAT/$JOB_TYPE/$SUBJECT/$TABLE_ID.parse.batch_seq_num.dat";
my $CATY_SRC_LIST="$DW_CFG/dw_caty.sources.lis";
my $CHECK_LOG="$mytmp/parser_check.output.$day[0]";
my $INC_LOG="$mytmp/parser_inc.output.$day[0]";
###################################################################################
#                    part 2  check if parser complete or not
###################################################################################

if($LOG_FILE){

    $tmp=$1 if($LOG_FILE_0=~/\-(.*)\./);
    $START_TIME=sprintf("%02s:%02s:%02s",substr($tmp,0,2),substr($tmp,2,2),substr($tmp,4,2));

    print "$slash\nPaser started at $START_TIME";

    open(LOGFILE,"$LOG_FILE")||die "can not open or write file";
    $logcontent=do { local $/; <LOGFILE>; };
    $FINISH=1 if($logcontent=~/Removing the complete and multi_complete files/);

if($FINISH==1){
    $END_TIME=sprintf("%02s:%02s:%02s",(localtime((stat($LOG_FILE))[9]))[2,1,0]);
    print ", and finished at $END_TIME.\n";
    open(SEQNUM,"$SEQ_NUM_FILE")||die "seq num file no found:$?";
    $SEQ_NUM=<SEQNUM>+0;
    close(SEQNUM);      
    $slash1="\n";
    }
else{
    print ", and it's still running.\n";
    open(SEQNUM,"$SEQ_NUM_FILE")||die "seq num file no found:$?";
    $SEQ_NUM=<SEQNUM>+1;
    close(SEQNUM);
    }
    close(LOGFILE);
}
else{
    print "\tDW_ATTR_PARSER has not started yet.\n\texiting...\n";
    exit;
}
#  part 1
#####################################################################################
#                        part 3  IS_CATY  &  FIELD_ID
#####################################################################################
my $TARGET_ETL_ID_LIST="$DW_CFG/$ETL_ID.parse.target_etl_id.lis";
open(TARGETID,"$TARGET_ETL_ID_LIST")||die "can not open target_etl_id file:$?";
@TARGET_ETL_ID=<TARGETID>;
chomp @TARGET_ETL_ID;
foreach(@TARGET_ETL_ID){
    $tmp="$_\.cfg";
    push(@TARGET_CFG,$tmp);
    $tmp=(split(/\./,$_))[-1];
    push(@TARGET_TABLE,$tmp);
    }
close(TARGETID);
keys %IS_CATY=@TARGET_CFG;
foreach(@TARGET_CFG){
    open(TARGETCFG,"$DW_CFG/$_")||die "can not open cfg file:$?";
    $tmp=do { local $/; <TARGETCFG>; };
    $IS_CATY{$_}=1 if($tmp=~/IS_CATY           1/);
    close(TARGETCFG);
}

open(CATYSRC,"$CATY_SRC_LIST")||die "can not open caty source lis file";
@tmp=<CATYSRC>;
chomp(@tmp);
foreach(@tmp){
    ($tmp)=split(' ',$_);
    push(@FIELD_ID,$tmp);
}
close(CATYSRC);

my %search=('dw_attr_parse_detail_w'=>'Flow_37 Gather_Parse_Detail',
            'dw_attr_parse_detail_values_w'=>'Flow_33 Gather_Detail_Values',
            'dw_attr_parse_lstg_dtl_w'=>'Flow_34 Gather_Listing_Detail',
            'dw_attr_parse_shpmt_dtl_w'=>'Flow_35 Gather_Shipping_Detail')
            ;
######################################################################################
#                        part 4  start program...
######################################################################################
my $Now=sprintf('%02d:%02d:%02d',(localtime(time()))[2,1,0]);
chdir "$DW_IN/$JOB_TYPE/$SUBJECT/";

open(CHECKLOG,">$CHECK_LOG") || die "can not open or write file";
close(CHECKLOG);
open(INCLOG,">$INC_LOG") || die "can not open or write file";
close(INCLOG);
open(ATTFILE,"$ATT_FILE")||die "can not open or write file";
@ATT_QUEUE=<ATTFILE>;
$att_queue=sprintf "@ATT_QUEUE";
close(ATTFILE);
open(CHECKLOG,">>$CHECK_LOG") || die "can not open or write file";
open(INCLOG,">>$INC_LOG") || die "can not open or write file";

foreach(@FIELD_ID){
    $i=$_;
    my ($FIELD_LOG)=(<$DW_LOG/$JOB_TYPE/$SUBJECT/$TABLE_ID.parse.$TABLE_ID.$i.dat.$SEQ_NUM.$day[0]-*.log>)[-1];
    my (@FIELDLOG,@DATA_REC,$DATA_REC,$LAST_REC); 
    $JOB_START=substr($1,-8) if($logcontent=~/item_attr_info\.$i\.dat\.$SEQ_NUM (.*) GMT/);
    $JOB_FINISH=sprintf '%02d:%02d:%02d',(localtime((stat $FIELD_LOG)[9]))[2,1,0] ;
    ($INFO_DATA)=<item_attr_info.$i.dat.$SEQ_NUM>;
    
    if(! defined $INFO_DATA){
    $status="unknown";
    }
    else{
    $status="pending";
    }

    if($att_queue=~/item_attr_info\.$i\.dat/){
    open(FIELDLOG,$FIELD_LOG)||die "can not open file:$?";
        
    if($ATT_QUEUE[-1]=~/item_attr_info\.$i\.dat/ and $FINISH!=1){
        @FIELDLOG=<FIELDLOG>;
        foreach(@TARGET_TABLE){
            $tmp=$search{$_};
            $LAST_REC=(grep /\[    :   1:    \]   0% $tmp/, @FIELDLOG)[-1];
            $DATA_REC=(split(' ',(split(/\[/,$LAST_REC))[0]))[-1];
            $DATA_REC=~s/,//g;
            push(@DATA_REC,$DATA_REC);
        }
        $COST_TIME=minus($Now,$JOB_START);      
        printf CHECKLOG "%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",$i,$JOB_START,' -'x2,$DATA_REC[0],$DATA_REC[1],$DATA_REC[2],$DATA_REC[3],$COST_TIME;
        }
    else{
        $tmp=do { local $/; <FIELDLOG>;};
        foreach(@TARGET_TABLE){
            $LAST_REC=$1 if($tmp=~/(.*) \[    :    :   1\]   0% $search{$_}/);
            $DATA_REC=(split(/ /,$LAST_REC))[-1];
            $DATA_REC=~s/,//g;
            push(@DATA_REC,$DATA_REC);
        }  
        $COST_TIME=minus($JOB_FINISH,$JOB_START);
        printf INCLOG "%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",$i,$JOB_START,$JOB_FINISH,$DATA_REC[0],$DATA_REC[1],$DATA_REC[2],$DATA_REC[3],$COST_TIME;
        }
        close(FIELDLOG);
    }
    else{
    @DATA_REC=(0,0,0,0);
    printf CHECKLOG "%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",$i,$status,' -'x2,@DATA_REC,' -'x2;
    }

    $TOT_REC[0]+=$DATA_REC[0];
    $TOT_REC[1]+=$DATA_REC[1];
    $TOT_REC[2]+=$DATA_REC[2];
    $TOT_REC[3]+=$DATA_REC[3];      
}
close(CHECKLOG);
close(INCLOG);
###################################################################################################
#                       part 5   ETC setup...
####################################################################################################

my $lastrun_s=sprintf "%02d:%02d:%02d",substr($ARC_FILE,-10,2),substr($ARC_FILE,-8,2),substr($ARC_FILE,-6,2);
my $lastrun_e=sprintf "%02d:%02d:%02d",(localtime((stat($ARC_FILE))[9]))[2,1,0];

$TOT_b=($FINISH==1)?$END_TIME:$Now;
$TOT_TIME=minus($TOT_b,$START_TIME);
my $TOT_SECOND=(split(/\:/,$TOT_TIME))[0]*3600+(split(/\:/,$TOT_TIME))[1]*60+(split(/\:/,$TOT_TIME))[2];

foreach(@TARGET_TABLE){
    my $seq=$SEQ_NUM-7;
    my $REC_CT_FILE=(<$mytmp/$_.record_count.dat.*>)[-7];
    open(REC_CT,"$REC_CT_FILE")||die "cannot open:$!";
        ($tmp)=<REC_CT>;
        chomp $tmp;
        push (@AVG_REC,$tmp);
    close (REC_CT);
}

foreach $i (0..3){
        my $tmp=($AVG_REC[$i]-$TOT_REC[$i])/$TOT_REC[$i];
  if($rate<$tmp){
        $rate=$tmp;
        }
        }

my $ETC_SECOND=$TOT_SECOND*$rate;
$ETC=sprintf"%02d:%02d:%02d",$ETC_SECOND/3600,$ETC_SECOND%3600/60,$ETC_SECOND%60;
$tmp=plus($ETC,$Now);

print "The ETC is :  $tmp\n" if($FINISH!=1);
print "\n";
print "For more details, please check the following:\n\n";

printf "\n%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",'ID','St_time','End_time','Detail','Detail_v','Lstg_d','Shpmt_d','Cost_time';
printf "%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",'-'x6,'-'x12,'-'x12,'-(rows)---','-(rows)---','-(rows)---','-(rows)---','-'x10;
system"sort -t: -n +0.6 +1 +2 $INC_LOG";
print $slash1,"\n";
system"sort -rn +1 $CHECK_LOG";
printf "%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",'Tot',$START_TIME,$TOT_b,$TOT_REC[0],$TOT_REC[1],$TOT_REC[2],$TOT_REC[3],$TOT_TIME;
if($FINISH!=1){
print "$slash1\n";
printf "%-6s%-12s%-12s%-10s%-10s%-10s%-10s%-8s\n",'Last',$lastrun_s,$lastrun_e,@AVG_REC,minus($lastrun_e,$lastrun_s);
}
print "$slash\n";

######################################### End of Program ############################################