#!/bin/sh

############################################################
#This shell is used to check the batch status for given SAs.
#Designer:              Kevin
#Last Modified:         2008/03/12
#Action:                #Add last run statistics  2007/12/06
            #Add avg time of last 7 run
            #sort output 
            #Regroup tfl files and pull flst from pascal and etl03  2008/03/15
############################################################

###################   Set Various   #########################

Batch=/export/home/dx_wang/kevin/batch
EXE=$Batch/bin
ARC=$Batch/arc
TMP=$Batch/tmp
LOG=$Batch/log
AGT=$Batch/agt
CFG=$Batch/cfg
DAT=$Batch/dat

. /export/home/dx_wang/kevin/home/10day
Estday=$day1
Today=`date +%Y%m%d`
File_exist=1
Num=1
Subject_areas="`cat $DAT/Subject_area_list`"
Line_str="--------------------------------------------------------------------------------------------------------"

CHECK_LOG=$LOG/batch_status_check.log."$Today"
> $CHECK_LOG

############### avgtime function definition ##################

. /export/home/dx_wang/kevin/home/avgtime

###############################################################
#               Step1.    Generate touch files list           #
###############################################################

ls -tl /export/home/dw_adm/WatchFiles > $TMP/pascal.wfl
/usr/local/bin/ssh dx_wang@liono.vip.ebay.com "ls -tl /dw/etl/home/prod/watch/primary" > $TMP/liono.wfl
/usr/local/bin/ssh dx_wang@sqwitetl03.smf.ebay.com "ls -tl /dw/etl/home/prod/watch/primary" > $TMP/etl03.wfl

###############################################################
#               Step2.    Starting check Touch files.         #
###############################################################

for SA in $Subject_areas
do
#set various env

TMP_FILE=$TMP/"$SA"_status.tmp."$Today"
TMP_FILE_1=$TMP/"$SA"_status.tmp."$Estday"
TMP_FILE_2=$TMP/"$SA"_status.tmp."$day2"
TMP_FILE_3=$TMP/"$SA"_status.tmp."$day3"
TMP_FILE_4=$TMP/"$SA"_status.tmp."$day4"
TMP_FILE_5=$TMP/"$SA"_status.tmp."$day5"
TMP_FILE_6=$TMP/"$SA"_status.tmp."$day6"
TMP_FILE_7=$TMP/"$SA"_status.tmp."$day7"
LOG_FILE=$LOG/"$SA"_status.log."$Today"

if [ `grep $SA $CFG/Check_option.cfg |awk '{print $2}'` = 0 ] 
then
        > $LOG_FILE
        cat $DAT/"$SA".tfl|awk '{print "\t"$2}' > $TMP/0.spool
        paste $TMP/"$SA"_null.bak $TMP/0.spool > $TMP_FILE
else

#### clear and arch old files, also generate today's touch file list
#-------------------------------------------------------------------
   if [ -r $LOG_FILE ]
   then
   mv $LOG_FILE $ARC/ 
   fi
> $TMP_FILE
> $TMP/$SA.avg.spool

### generate status in $TMP and log in $LOG
echo "\n\t****Starting check Touch files for [ $SA ]****\n" >> $LOG_FILE
  if [ -r $TMP_FILE_1 ]
  then
  echo "$Today\t$day1\tAvg_7d\tTouchfile_name\n$Line_str" >> $LOG_FILE
  else
  echo "$Today\t\tAvg_7d\tTouchfile_name\n$Line_str" >> $LOG_FILE
  fi
        for df in `cat $DAT/$SA.tfl|awk '{print $2}'`   #df for touch files.
        do
                if [ `grep $df $DAT/$SA.tfl | awk '{print $1}'` = liono.vip.ebay.com ]
                    then WF_LST=$TMP/liono.wfl
                elif [ `grep $df $DAT/$SA.tfl | awk '{print $1}'` = sqwitetl03.smf.ebay.com ]
                    then WF_LST=$TMP/etl03.wfl
                else
                    WF_LST=$TMP/pascal.wfl
                fi

                if [ `grep -c $df $WF_LST` = 0 ]
                    then 
                    echo "Null\t\t$df" >> $TMP_FILE
                else
                    printf "`grep "$df\>" $WF_LST |awk '{print $8"\t\t"$9}'`\n" >> $TMP_FILE
                fi
        done 
        
#ajust SLA avg time -1h.  

    if [ `date | awk '{print $1}'` = Fri ] && [ $SA = dw_sla ] && [ `grep -c Null $TMP_FILE` = 0 ]
                then
                cat $TMP_FILE | awk -F":" '{print "0"$1-1":"$2}'  >  fri.spool
                mv fri.spool $TMP_FILE
    fi        
#add the last run timestamp
        cut -f1,2 $TMP_FILE > $TMP/1.spool
        cut -f1,2 $TMP_FILE_1 > $TMP/2.spool
        cut -f2,3 $TMP_FILE > $TMP/0.spool
                
#figure out last 7 day run
        cut -f1 $TMP_FILE_2 > $TMP/3.spool
        cut -f1 $TMP_FILE_3 > $TMP/4.spool
        cut -f1 $TMP_FILE_4 > $TMP/5.spool
        cut -f1 $TMP_FILE_5 > $TMP/6.spool
        cut -f1 $TMP_FILE_6 > $TMP/7.spool
        cut -f1 $TMP_FILE_7 > $TMP/8.spool
        cd $TMP
        paste $TMP/2.spool $TMP/3.spool $TMP/4.spool $TMP/5.spool $TMP/6.spool $TMP/7.spool $TMP/8.spool > $TMP/tt.spool
        tr -d "Null" < $TMP/tt.spool > $TMP/ttable
        line=1
        until [ $line -gt `wc -l $TMP/ttable` ]
        do
        sed -n "$line"p $TMP/ttable > $TMP/ttext
        avgtime $TMP/ttext >> $TMP/$SA.avg.spool
        line=`expr $line + 1`
        done   
        paste $TMP/1.spool $TMP/2.spool $TMP/$SA.avg.spool $TMP/0.spool | sort >> $LOG_FILE
            if [ $SA = dw_sla ]
                then 
                cd $TMP
                for file in `ls -1 dw_sla_status.tmp*|grep -v "$Today"|grep -v "$day8"` 
                        do
                        sort $file|tail -1|cut -f1 >> $TMP/slavg.spool
                        done
                        echo "SLA avg complete time for last 7 day : `avgtime $TMP/slavg.spool`AM" >> $LOG_FILE
                echo "**(1h has been ajusted to Friday SLA complete time)**" >> $LOG_FILE
            fi
        echo $Line_str >> $LOG_FILE
fi
sed '1,$s/^.*.$/Null/g' $DAT/"$SA".tfl > $TMP/"$SA"_null.bak            #touch null rows 
cat $LOG_FILE >> $CHECK_LOG

done 
#clean up unwanted files.
        rm $TMP/ttext
        rm $TMP/ttable  
        rm $TMP/*.spool 

cd $LOG
find $LOG -mtime +0 -exec mv {} $ARC \;
cd $TMP
find $TMP -mtime +7 -exec mv {} $ARC \;
## Send report email
if [ `cat $DAT/Subject_area_list|wc -l` != 1 ]
  then 
  cat $CHECK_LOG | mailx -s "Batch touch files status" aiwang@ebay.com liawu@ebay.com
fi