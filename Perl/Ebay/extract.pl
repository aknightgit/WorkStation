#!/usr/local/bin/perl 

#############################################
#    Nextgen daily extract status checker   #
#############################################
#
#Usage:      Check the status of a specified job. $etlid passed as parameter
#  e.g.      > extract.pl    dw_api.dw_appstats          
#            if the parameter is not given, the default parameter file will be passed. 
#            (filelist under /export/home/aiwang/sla/ex.lis)
# 
#  Date              Ver         Modified By             Comments
# ----------        -----       ------------          ------------------------
# 2008-4-01          1.0         Kevin                   Initial Version
# 2008-5-15          1.1         Kevin                   ETC setup


##################################################################################################
#                     part 1   Definition
##################################################################################################
use strict;

my ($i,$n,$m,@day); #define the past 10days.
foreach(@day=(0..9)){
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time()-86400*$i);
    $year=$year+1900;
    $mon=$mon+1;
    $_=sprintf "%4d%02d%02d",$year,$mon,$mday;
    $i++;
    }
        
# avg time function     
sub avgt {
    my ($i,$total,$h,$m,$s);
    foreach(@_){
        $i+=1;
        ($h,$m,$s)=split(/:/,$_);
        $total+=($h*3600+$m*60+$s);
        }
    my $ah=int $total/$i/3600;
    my $am=int $total/$i%3600/60;
    my $as=int $total/$i%60;
    if($s){
        printf "%02d:%02d:%02d\n",$ah,$am,$as;
        }
    else {
        sprintf "%02d:%02d\n",$ah,$am;
        }
    }
#minus function
sub minus {
    my ($bigger,$little,$total);
    ($bigger,$little)=@_;
    $total=substr($bigger,0,2)*3600+substr($bigger,3,2)*60+substr($bigger,6,2)-substr($little,0,2)*3600-substr($little,3,2)*60-substr($little,6,2);
    sprintf "%02d:%02d:%02d",$total/3600,$total%3600/60,$total%60;  
    }
sub dv{
    my ($bigger,$little,$total);
    ($bigger,$little)=@_;
    sprintf substr($bigger,0,2)*3600+substr($bigger,3,2)*60+substr($bigger,6,2)-substr($little,0,2)*3600-substr($little,3,2)*60-substr($little,6,2);
    }
    
###################################################################################
#                    part 2  env setting up
###################################################################################
my (@argv,$head);
if(!@ARGV){   # define the default argv file if the argv is not passed.
    open(ARGVFILE,"/export/home/aiwang/sla/ex.lis")||die "The argv file /export/home/aiwang/sla/ex.lis is unavailable.$!";
    @argv=<ARGVFILE>;
    chop(@argv);
    }
else{
    @argv=@ARGV;
    }

foreach(@argv){
    my $etlid=$_;
    if(!$etlid){exit;}
    $head="# start checking $etlid #";
    printf "\n%s%s\n%s$head\n%s%s\n",' 'x(48-length($head)/2),'#' x length($head),' 'x(48-length($head)/2),' 'x(48-length($head)/2),'#' x length($head);

    my ($subject,$table)=split(/\./,$etlid);
    my $mytmp="/export/home/aiwang/tmp";
    my $etllog="/dw/etl/home/prod/log/extract";
    my $etlin="/dw/etl/home/prod/in/extract";
    my $etlarc="/dw/etl/home/prod/arc/extract";
    my $etlcfg="/dw/etl/home/prod/cfg";
    my $etldat="/dw/etl/home/prod/dat/extract";
    my $datadir="$etlin/$subject";
    my $logdir="$etllog/$subject";
    my $arcdir="$etlarc/$subject";
    my (@inputlog,@datafile,@srcid,@ctime,@sizea,@sizeb,@sizeh,@tmp);
    my ($inputlog,$stime,$seqnum,$arclog,$exist,$finish,$tmp,$ETC);
  
    $tmp=(<$etldat/$subject/$table.extract.batch_seq_num.dat>)[-1];
    open(SEQNUM,"$tmp")||die "can not open";
    my $tmp1=(localtime((stat $tmp)[9]))[3];
    my $tmp2=(localtime(time()))[3];
    if($tmp1==$tmp2){    # this is for daily ex. seq num will be only updated every day.
    $seqnum=<SEQNUM>+0;
        }
    else{
    $seqnum=<SEQNUM>+1;
        }
    close(SEQNUM);
#check start time
    my $start=sprintf('%02d:%02d:%02d',(localtime(time()))[2,1,0]);      
#define the datafiles for every @argv   
    chdir $arcdir;
    @inputlog=<$table.ex.*.input_table_extract.$day[4]*.log>;
    foreach(@inputlog){
        $m=$1 if(/ex\.(.*)\.input_table_extract/); 
        push(@tmp,int($m));
        @tmp=sort{$a<=>$b} @tmp;
        my %count; 
        @srcid=grep{ ++ $count{$_} < 2; } @tmp; 
        }
    foreach(@srcid){
        push(@datafile,"$table.$_.dat.$seqnum");
        }
## 1st check of the data sizes and the last-changed time.        
    chdir $datadir;
    $i=0;
    foreach(@datafile){
        $sizea[$i]=int((stat $_)[7]/1000);
        $i++;
        }
#sleep 5 secs to get the timeing gap, to calculate the speed.   
    sleep 5;    
#check end time
    my $end=sprintf('%02d:%02d:%02d',(localtime(time()))[2,1,0]);     

######################################################################################
#                        part 3  start program...
######################################################################################
open(PROLOG,">$mytmp/$etlid.output.$day[0]")||die "can not open or unwritable";
printf PROLOG "%-100s\n",'-'x96;
printf PROLOG "%-8s%-12s%-12s%-10s%-10s%-12s%-12s%-12s%-12s\n",'Src_ID','Crt_Size','Avg_Size','Crt_Spd','Avg_Spd','Str_time','End_time','Cost_time','ETC';
printf PROLOG "%-8s%-12s%-12s%-10s%-10s%-12s%-12s%-12s%-12s\n\n",'-'x8,'(kByte)-----','(kByte)-----','-(kb/s)---','-(kb/s)---','-'x12,'-'x12,'-'x12,'-'x8;
close(PROLOG);
open(INCLOG,">$mytmp/$etlid.inclog.$day[0]")||die "can not creat or open file";
printf INCLOG "# The ones not start yet #\t\t\t\tgiving the last run statistics...\n\n";
close(INCLOG);
open(PROLOG,">>$mytmp/$etlid.output.$day[0]")||die "can not open or unwritable";
open(INCLOG,">>$mytmp/$etlid.inclog.$day[0]")||die "can not creat or open file";


    $i=0;
    chdir $datadir;
    foreach(@datafile){
        my ($finish,$crtspd,$creaday,$sizeNday);
        my @sizeh=();
        $finish=0;
        $m=(split(/\./,$_))[1];
        $exist=(<$table.$m.*.$seqnum>)[0];
        $sizeb[$i]=int((stat $_)[7]/1000);
        $crtspd=int(($sizeb[$i]-$sizea[$i])/dv($end,$start));
        $creaday=(localtime((stat $_)[9]))[3];       #check the file generated date.
        $ctime[$i]=sprintf('%02d:%02d:%02d',(localtime((stat $_)[9]))[2,1,0]);
        #work out the value of avg size.        
        if(@datafile==1 and $m==1){
            $arclog="$arcdir/$table.ex.single_table_extract";
            }
        else{
            $arclog="$arcdir/$table.ex.$m.single_table_extract";
            }
        foreach((<$arclog.*.log>)[-7..-1]){ 
            open (ARCFILE,"$_")||die "can not open";
                foreach(<ARCFILE>){
                    if(/(.*)\[    :    :   1\]   0% Flow_11/){
                        $tmp=(split(' ',$1))[0];
                        $tmp=~s/,//g;
                        push(@sizeh,int($tmp/1000));
                        }
                    }
            close(ARCFILE);
            }
        foreach(@sizeh){$sizeNday+=$_;}
        my $AVGsize=int($sizeNday/scalar(@sizeh));
        #define the start time of each job, depend on the input log.    
        if(!$exist){
            $inputlog=((<$arcdir/$table.ex.$m.input_table_extract.$day[1]-*.log>),(<$logdir/$table.ex.$m.input_table_extract.$day[1]-*>))[-1];
            $ctime[$i]=sprintf('%02d:%02d:%02d',(localtime((stat $inputlog)[9]))[2,1,0]);
            open(FINISHLOG,$inputlog)||die "can not open:$!";
            $tmp=do { local $/; <FINISHLOG>; };
            $stime=substr($1,-13,8) if($tmp=~/(.*)\|Gather_Extract_Logs.000\|\|start\|Start\|/); 
            close(FINISHLOG);                   
            }
        else{
            $inputlog=(<$logdir/$table.ex.$m.input_table_extract.$day[0]-*.log>)[-1];
            open(FINISHLOG,$inputlog)||die "can not open:$!";
            $tmp=do { local $/; <FINISHLOG>; };
            $finish=1 if($tmp=~/\|\|finish\|End\|/);
            $stime=substr($1,-13,8) if($tmp=~/(.*)\|Gather_Extract_Logs.000\|\|start\|Start\|/); 
            close(FINISHLOG);
            }
        my $costime=minus($ctime[$i],$stime);
        my $rngtime=minus($end,$stime);         
    #select the output type.
        
    if($creaday<(localtime(time()))[3] or !$exist){
        printf INCLOG "%-8s%-12s%-12s%-10s%-10s%-12s%-12s%-12s%-12s\n","$m",' -'x2,$AVGsize,' -'x2,' -'x2,$stime,$ctime[$i],$costime,'last run';        
        }
    elsif($crtspd==0){            
        if($finish==1){
            printf PROLOG "%-8s%-12s%-12s%-10s%-10s%-12s%-12s%-12s%-12s\n","$m",$sizeb[$i],$AVGsize,' -'x2,int($sizeb[$i]/dv($costime,0)),$stime,$ctime[$i],$costime,'Finished';
            }
        else{
            printf PROLOG "%-8s%-12s%-12s%-10s%-10s%-12s%-12s%-12s%-12s\n","$m",$sizeb[$i],$AVGsize,'hanging','0',$stime,'?'x5,$rngtime,'?'x5;
            }               
        }
    else{
        if($sizeb[$i]>$AVGsize){
            $ETC='?'x5;
            }
        else{
            $tmp=($AVGsize-$sizeb[$i])/$crtspd;
            $ETC=sprintf("%02d:%02d:%02d",$tmp/3600,$tmp%3600/60,$tmp%60);
            }
        printf PROLOG "%-8s%-12s%-12s%-10s%-10s%-12s%-12s%-12s%-12s\n","$m",$sizeb[$i],$AVGsize,$crtspd,int($sizeb[$i]/dv($rngtime,0)),$stime,'?'x5,,$rngtime,$ETC;
        }
        $i++;
    }
######################################################################################
#                        part 4   print ouput...
######################################################################################    
    
close(INCLOG);
printf PROLOG "%-100s\n",'-'x96;
open(INCLOG,"$mytmp/$etlid.inclog.$day[0]")||die "can not open or unwritable:$!";
my @inclog=<INCLOG>;
if($#inclog!=1){
print PROLOG @inclog;
printf PROLOG "%-100s\n\n",'-'x96;
}
close(INCLOG);
close(PROLOG);
open(PROLOG,"$mytmp/$etlid.output.$day[0]")||die "can not open or unwritable:$!";
print <PROLOG>;
close(PROLOG);
chdir $mytmp;
unlink glob("*.inclog*");
unlink glob("*.$day[6]");
}
######################## End of program. #################