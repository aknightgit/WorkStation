#!/usr/local/bin/perl

$usage = "\nUSAGE: $0 [stage dir]\n\n";

$rmmail  = 'dblado@ebay.com dprocter@ebay.com vngo@ebay.com';
$rmmail  = 'dl-ebay-it-imrm@ebay.com';
$opsmail = 'dl-ebay-it-imd-ops@ebay.com';

$mailx = '/usr/bin/mailx';

$pwd = `pwd`; chomp $pwd;
$user       = $ENV{LOGNAME};
$homedir    = "/export/home/$user";
$stagedir   = "/export/home/$user/releases/stage";
$releaseDir = "/export/home/$user/releases/$label";
$tmpDir     = "/export/home/$user/releases/$label/tmp";

$hostname = `/usr/bin/hostname`; chomp $hostname;

$stagedir = $ARGV[0] if ($ARGV[0]);
$qa = $1 if ($user =~ /dw_adm_(\S+)/);

if ($hostname =~ /sjditdb01/i) {
   if ($qa eq 'auto') {
      $env = 'QA-Auto';
   } elsif ($qa eq 'itg') {
      $env = 'QA-Itg';
   } elsif ($qa eq 'repl') {
      $env = 'QA-Repl';
   } else {
      $env = 'Unknown';
   }
} elsif ($hostname =~ /taz/i) {
      $env = 'QA-Taz';
} elsif ($hostname =~ /sjcitetl02/i) {
   if ($qa eq 'auto') {
      $env = 'QA-AbInitio-Auto';
   } elsif ($qa eq 'itg') {
      $env = 'QA-AbInitio-Itg';
   } elsif ($qa eq 'repl') {
      $env = 'QA-AbInitio-Repl';
   } else {
      $env = 'Unknown';
   }
} elsif ($hostname =~ /srwimdetl10/i) {
      $env = 'PROD-AbInitio';
} elsif ($hostname =~ /Oncilla/i) {
      $env = 'PROD-Oncilla';
} elsif ($hostname =~ /phxitetl01/i) {
      $env = 'PROD-Pascal';
} else {
      $env = 'Unknown';
}

opendir(STG, "$stagedir") or die "\nError: Cannot open $stagedir: $!\n\n";
@alltarfiles = readdir(STG);
closedir(STG);

@tarfiles = ();
foreach $tarfile (@alltarfiles) {
   next if ($tarfile =~ /_ELF_/);
   push (@tarfiles, $tarfile);
   if ( $tarfile =~ /([^\/]+)-Unix\.tar$/ ) {
      $label = $1;
   } elsif ( $tarfile =~ /([^\/]+)-Onetime\.tar$/ ) {
      $label = $1;
   } elsif ( $tarfile =~ /([^\/]+)-AbInitio\.tar$/ ) {
      $label = $1;
    } elsif ($tarfile =~ /([^\/]+)-UC4\.tar$/ ) {
       $label = $1;
   }else {
      next;
   } 
   $releaseDir = "/export/home/$user/releases/$label";
   system "mkdir $releaseDir" if (!-e $releaseDir);
   if (-e "$releaseDir/$tarfile") { system "mv -f $releaseDir/$tarfile $releaseDir/$tarfile$$"; }
   system "mv -f $stagedir/$tarfile $releaseDir";
}

foreach $tarfile (@tarfiles) {
   chomp $tarfile;
   next unless ($tarfile =~ /\.tar$/);

   $date = `date '+20%y%m%d.%H%M'`;
   chomp $date;
   print "$date:\t deploying $stagedir/$tarfile\n";

   if ( $tarfile =~ /([^\/]+)-Unix\.tar$/ ) {
      $label = $1;
      $releaseDir = "/export/home/$user/releases/$label";
      $tarfile = "$releaseDir/$tarfile";
      $logfile = "$releaseDir/Unix_email.txt";
      $bkfile  = "$releaseDir/$label-Unix-ROLLBACK.tar";
      open (LOG,">>$logfile") or die "\nError: Cannot create $logfile\n\n";

      print "ClearCase Label: $label\n";
      print "Tar file:  $tarfile\n\n";
      print LOG "ClearCase Label: $label\n";
      print LOG "Tar file:  $tarfile\n\n";

      chdir("$releaseDir");
      system `tar xf $tarfile notify-Unix.txt`;
      $notify = `cat notify-Unix.txt`; chomp $notify;
      $notify =~ s/\,/ /g;

      if ($qa) {
         $tmpDir = "$releaseDir/tmp";
         if (-e "$tmpDir") { system "mv -f $tmpDir $tmpDir$$"; }
         print "\n- Modifying users with suffix $qa in $tarfile ...\n";
         system "mkdir $tmpDir";
         chdir("$tmpDir");
         system "tar xvf $tarfile";
         opendir(TMP, "$tmpDir") or die "\nError: Cannot open $tmpDir\n\n";
         @dir_list = readdir(TMP);
         closedir(TMP);
         foreach $d (@dir_list) {
            chomp $d;
            next if ($d =~ /^\./);
            print "- Renaming $d to $d\_$qa\n";
            rename($d, "$d\_$qa") or die "\nError: Cannot rename $d\n\n";
         }
         @flst_files = `find $releaseDir -name \"*.flst\" -print`;
         foreach $f (@flst_files) {
            chomp $f;
            open (IF,"<$f") or die "\nError: Cannot open $f\n\n";
            open (OF,">$f$$") or die "\nError: Cannot create $f$$\n\n";
            while (<IF>) {
               s/home\/dw_adm/home\/dw_adm_$qa/g;
               print OF $_;
            }
            close(IF);
            close(OF);
            print "Update $f\n";
            system "mv -f $f$$ $f";
         }
         rename($tarfile, "$tarfile.ORIG") or die "\nError: Cannot rename $tarfile\n\n";
         system "tar cvf $tarfile *";
      }

      @bfiles = `tar tf $tarfile`;
      if (-e $bkfile) { system "mv -f $bkfile $bkfile$$"; }
      print "\n- Backing up Unix rollback files: $bkfile\n";
      print LOG "\n- Backing up Unix rollback files: $bkfile\n";
      chdir("/export/home");
      for $f (@bfiles) {
         chomp $f;
         if ($f =~ /[^\/]+\/[^\/]+\/\S+/) {
            if (-e $bkfile) {
               system "tar uvf $bkfile $f > /dev/null";
            } else {
               system "tar cvf $bkfile $f > /dev/null";
            }
            system "tar xvf $tarfile $f";
            if ($f =~ /[^\/]+\/bin\/\S+/) {
               system "chmod 755 $f";
            } elsif ($f =~ /[^\/]+\/sql\/\S+/) {
               system "chmod 755 $f";
            }
         }
      }

      $ufiles = `tar tvf $tarfile`;
      print "\nExtracting Unix files to /export/home\n";
      print "---------------------------------------\n";
      print LOG "\nExtracting Unix files to /export/home\n";
      print LOG "---------------------------------------\n";
      print $ufiles;
      print LOG $ufiles;
      close(LOG);
      system "$mailx -s \"[$env]: $label (Unix files) is deployed on $hostname.\" $rmmail $notify < $logfile"; 

   } elsif ( $tarfile =~ /([^\/]+)-AbInitio\.tar$/ ) {
      $label = $1;
      $releaseDir = "/export/home/$user/releases/$label";
      $homeDir = "/dw/etl/home/prod";
#/export/home/abinitio";
      $tarfile = "$releaseDir/$tarfile";
      $logfile = "$releaseDir/AbInitio_email.txt";
      $bkfile  = "$releaseDir/$label-AbInitio-ROLLBACK.tar";
      open (LOG,">>$logfile") or die "\nError: Cannot create $logfile\n\n";

      chdir("$releaseDir");
      system `tar xf $tarfile notify-AbInitio.txt`;
      $notify = `cat notify-AbInitio.txt`; chomp $notify;
      $notify =~ s/\,/ /g;

      print "ClearCase Label: $label\n";
      print "Tar file:  $tarfile\n\n";
      print LOG "ClearCase Label: $label\n";
      print LOG "Tar file:  $tarfile\n\n";

      print "\n- Backing up AbInitio rollback files: $bkfile\n";
      print LOG "\n- Backing up AbInitio rollback files: $bkfile\n";
      @bfiles = `tar tf $tarfile`;
      # 22 Feb 2007 DLuhman Add .gz for new zipped file we're using
      $bkfilegz = $bkfile . '.gz'; 
      if (-e $bkfilegz) { system "mv -f $bkfilegz $bkfilegz$$"; }
      if ($qa) { $homeDir = "$homeDir/$qa"; }
      chdir($homeDir);
      for $f (@bfiles) {
         chomp $f;
         if ($f =~ /[^\/]+\/\S+/) {
            if (-e $bkfile) {
               system "tar uvf $bkfile $f > /dev/null";
            } else {
               system "tar cvf $bkfile $f > /dev/null";
            }
            system "tar xvf $tarfile $f";
            system "chmod 755 $f";
         }
      }
      # 22 Feb 2007 DLuhman - only archive needed dirs - not log and tmp
#      system "tar cvf $bkfile arc bin cfg cmp dat dbc dml lib  mfs mp sql src watch xfr  > /dev/null 2>&1";
      system "gzip --best $bkfile > /dev/null 2>&1";  # Add 22 Feb 2007 DLuhman to save file space
      $afiles = `tar tvf $tarfile`;
      print "\nExtracting AbInitio files to $homeDir\n";
      print "---------------------------------------\n";
      print LOG "\nExtracting AbInitio files to $homeDir\n";
      print LOG "---------------------------------------\n";
      print LOG $afiles;
      close(LOG);
      system "$mailx -s \"[$env]: $label (AbInitio files) is deployed on $hostname.\" $rmmail $notify < $logfile";

   } elsif ( $tarfile =~ /([^\/]+)-Onetime\.tar$/ ) {
      $label = $1;
      $releaseDir = "/export/home/$user/releases/$label";
      $tarfile = "$releaseDir/$tarfile";
      $logfile = "$releaseDir/Onetime_email.txt";
      $dbafile = "$releaseDir/ddl_email.txt";
      open (LOG,">>$logfile") or die "\nError: Cannot create $logfile\n\n";

      chdir("$releaseDir");
      system `tar xf $tarfile notify-Onetime.txt`;
      $notify = `cat notify-Onetime.txt`; chomp $notify;
      $notify =~ s/\,/ /g;
       system `tar xf $tarfile dbastats-Onetime.txt`;
      $dba_stats = `cat dbastats-Onetime.txt`; 

      print "ClearCase Label: $label\n";
      print "Tar file:  $tarfile\n\n";
      print LOG "ClearCase Label: $label\n";
      print LOG "Tar file:  $tarfile\n\n";

      $ofiles = `tar tvf $tarfile`;
      print "\nExtracting Onetime files to /export/home/$user/releases\n";
      print "----------------------------------------------------\n";
      print LOG "\nExtracting Onetime files to /export/home/$user/releases\n";
      print LOG "----------------------------------------------------\n";
      print LOG $ofiles;

      chdir("/export/home/$user/releases");
      system "tar xvf $tarfile";
      system "chmod -Rf 755 $releaseDir/*";

      @ddl_files = `find $releaseDir -name \"*.sql\" -print`;
      @ddl_files2 = `find $releaseDir -name \"*.SQL\" -print`;
      push(@ddl_files, @ddl_files2);
      if ($ddl_files[0]) {
         $emails = $rmmail;
         $td_files = '';
         $ora_files = '';
         open (DBA,">$dbafile") or print LOG "\nError: Cannot create $dbafile\n\n";
         foreach (@ddl_files) {
            if (/td[_\.]+[^\/]+\s*$/i) {
               $td_files .= $_;
            } elsif (/ora_[^\/]+\s*$/i) {
               $ora_files .=  $_;
            } else {
               print DBA "Developer,\n\n";
               print DBA "We don't know if execute this DDL/DML under Teradata or Oracle.\n";
               print DBA "\t$_\n";
               print DBA  "\nError: Must have \"_td_\" or \"_ora_\" in $_\n";
               print LOG "\nError: Must have \"_td_\" or \"_ora_\" in $_\n";
            }
         }
         if ($td_files) {
            if ($hostname =~ /sqwitetl01/i) {
               print DBA "DBA oncall,\n\n";
               $emails .= " $opsmail";
            } else {
               print DBA "Release team,\n\n";
            }
           print DBA $dba_stats; 
            print DBA "Please validate and execute below Onetime TERATDATA DDL scripts on $hostname:\n";
            print DBA "-----------------------------------------------------------------------------\n";
            print DBA $td_files;
         }
         if ($ora_files) {
            print DBA "\n\nRelease team,\n\n";
            print DBA "Please validate and execute below Onetime ORACLE DDL scripts on $hostname:\n";
            print DBA "-----------------------------------------------------------------------------\n";
            print DBA $ora_files;
         }
         close(DBA);
         system "$mailx -s \"[DBA TASK] on [$env] for $label DDL rollout scripts on $hostname\" $emails $notify < $dbafile"; 
      } else {
         print LOG "\n- NO DDL Rollout scripts\n";
      }

      update_entry('efload');
      update_entry('etpump');

      close(LOG);
      system "$mailx -s \"[$env] $label (Onetime files) is extracted on $hostname.\" $rmmail $notify < $logfile"; 
   }  elsif ( $tarfile =~ /([^\/]+)-UC4\.tar$/ ) {
         $label = $1;
         $releaseDir = "/export/home/$user/releases/$label";
         $homeDir = "$releaseDir/UC4";
         $tarfile = "$releaseDir/$tarfile";
         $logfile = "$releaseDir/UC4_email.txt";
          open (LOG,">>$logfile") or die "\nError: Cannot create $logfile\n\n";
         system "mkdir $homeDir" if (!-e $homeDir);
         chdir("$homeDir");
         system `tar xf $tarfile notify-UC4.txt`;
         $notify = `cat notify-UC4.txt`; chomp $notify;
         $notify =~ s/\,/ /g;
   
         print "ClearCase Label: $label\n";
         print "Tar file:  $tarfile\n\n";
         print LOG "ClearCase Label: $label\n";
         print LOG "Tar file:  $tarfile\n\n";
   
         system "tar xvf $tarfile ";
      system "chmod -Rf 755 $homeDir/*";
   
        # system "tar cvf $bkfile *  > /dev/null 2>&1";
         $ufiles = `tar tvf $tarfile`;
         print "\nExtracting UC4  files to $homeDir\n";
         print "---------------------------------------\n";
         print LOG "\nExtracting UC4 files to $homeDir\n";
         print LOG "---------------------------------------\n";
         print LOG $ufiles;
         close(LOG);
       # Search and replace code for xml
        $cmd =" find $homeDir -name \"*.xml\" -print";
        print $cmd;
         @xml_files = `find $homeDir -name \"*.xml\" -print`;
         foreach (@xml_files) {
           $filename = $_;
           chomp($filename);
           system "perl -i -pe \'s/Text3=\"SJCITDEV04\"/Text3=\"SRWIMDETL10\"/g\'  $filename";
          system "perl  -i  -pe \'s/Text3=\"SJCITDEV01\"/Text3=\"PHXITETL01\"/g\'  $filename";
           system "perl -i -pe \'s/\<HostDst\>SJCITDEV04/\<HostDst\>SRWIMDETL10/g\' $filename";
          system "perl -i -pe \'s/\<HostDst\>SJCITDEV01/\<HostDst\>PHXITETL01/g\' $filename";
system "perl -i -pe \'s/\<HostDst\>UNIX\\|SJCITDEV01/\<HostDst\>UNIX\|PHXITETL01/g\' $filename";
       system "perl -i -pe \'s/\<HostDst\>UNIX\\|SJCITDEV04/\<HostDst\>UNIX\|SRWIMDETL10/g\' $filename";
   
         }
      system "$mailx -s \"[$env]: $label (UC4 files) is deployed on $hostname.\" $rmmail $notify < $logfile";}
       else {
      print "Error: Unknown tarfile: $tarfile\n";
   }

}

sub update_entry($ini_name) {
      ($ini_name) = @_;
      $ini_file = "$homedir/lib/$ini_name.ini";
      if (!-e $ini_file) {
            print "\nError: $ini_file does not exist\n\n";
            return;
      }
      @alist     = ();
      %entries   = ();
      %fentries  = ();
      %aentries  = ();
      @ini_files = `find $releaseDir -name \"*$ini_name*\" -print`;
      if (!$ini_files[0]) {
         print "\n- No change for $ini_file\n";
         print LOG "\n- No change for $ini_file\n";
         return;
      }
      foreach $f (@ini_files) {
         chomp $f;
         open (IF,"<$f") or die "\nError: Cannot open $f\n\n";
         $entry   = '';
         $comment = '';
         while (<IF>) {
            if (/^\s*#/) {
               $comment .= $_;
            } elsif (/^\s*$/) {
               ;
            } elsif (/^\s*\[(.+)\]/) {
               $entry = $1;
               $entries{$entry} = $comment . $_;
               $fentries{$entry} = 2;
               $comment = '';
            } elsif (/^x\s*\[(.+)\]/i) {
               $entry = $1;
               $fentries{$entry} = -2;
            } elsif (/^delete\s+\[(.+)\]/i) {
               $entry = $1;
               $fentries{$entry} = -2;
            } elsif (/^remove\s+\[(.+)\]/i) {
               $entry = $1;
               $fentries{$entry} = -2;
            } else {
               $entries{$entry} .= $_;
            }
         } 
         close(IF);
      }
      open (IF,"<$ini_file") or die "\nError: Cannot open $ini_file\n\n";
      print "\nUpdating $ini_file:\n";
      print "------------------------------------------------------\n";
      print LOG "\nUpdating $ini_file:\n";
      print LOG "------------------------------------------------------\n";
      $entry   = '';
      $comment = '';
      $value   = '';
      while (<IF>) {
         if (/^\s*#/) {
            $comment .= $_;
         } elsif (/^\s*$/) {
            ;
         } elsif (/^\s*\[(.+)\]/) {
            $entry = $1;
            if ($fentries{$entry} == -2) { 
               $fentries{$entry} = -1;
               print "Remove \"$entry\" entry\n";
               print LOG "Remove \"$entry\" entry\n";
            } else {   
               push (@alist, $entry);
               if ($fentries{$entry} == 2) { 
                  print "Modify \"$entry\" entry as below:\n";
                  print "$entries{$entry}\n";
                  print LOG "Modify \"$entry\" entry as below:\n";
                  print LOG "$entries{$entry}\n";
                  $fentries{$entry} = 1;
                  $aentries{$entry} = $comment . $entries{$entry};
               } else {
                  $fentries{$entry} = 0;
                  $aentries{$entry} = $comment . $_;
               }
            }
            $comment = '';
         } else {
            if ($fentries{$entry} == 0) { 
               $aentries{$entry} .= $_;
            }
         }
      }
      close(IF);
            while (($entry, $value) = each(%entries)) {
         if ($fentries{$entry} == 2) { 
            print "Add \"$entry\" entry as below:\n";
            print "$value\n";
            print LOG "Add \"$entry\" entry as below:\n";
            print LOG "$value\n";
            $aentries{$entry} = $value;
            push (@alist, $entry);
         } elsif ($fentries{$entry} == -2) { 
            print "Error: Cannot remove \"$entry\" entry (not found)\n";
            print LOG "Error: Cannot remove \"$entry\" entry (not found)\n";
         }
      } 
      $date = `date '+20%y%m%d.%H%M%S'`;
      chomp $date;
      $bk_file = "$ini_file.$date";
      $tmp_file = "$ini_file.$date.tmp";
      open (OF,">$tmp_file") or print LOG "\nError: Cannot create $tmp_file\n\n";
            foreach $entry (@alist) {
         print OF "$aentries{$entry}\n";
      }
      close(OF);
      print "\nBackup File: $bk_file\n";
      print LOG "\nBackup File: $bk_file\n";
      rename($ini_file, $bk_file) || print LOG "Error: Unable to rename $ini_file to $bk_file";
      rename($tmp_file, $ini_file) || print LOG "Error: Unable to rename $tmp_file to $ini_file";
}