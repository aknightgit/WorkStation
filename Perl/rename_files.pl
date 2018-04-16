#!/usr/local/bin/perl

($workdir,$filetype,$prefix)=@ARGV?@ARGV:(`cd`,"jpg",'jpg_');

# $workdir=`cd`;
chomp $workdir;
$workdir=~s/\\/\//g;


chdir $workdir;

print "we're now renaming $filetype files from $workdir...\n";

opendir (WORKDIR,"$workdir")|| die "cannot open $workdir.\n";
@filelist=readdir WORKDIR;
@filelist=splice (@filelist,2);

print "FIles found...\n";

#open TMP,">>$workdir/work.tmp"|| die "can not creat work.tmp file.\n";
$n=0;
foreach(@filelist){
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime((stat $_)[9]);
    $tmp=sprintf "%04d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;
    #print TMP $tmp,"\t",$_,"\n" if /$filetype/;
	if(/$filetype/){
		print $tmp,"\t",$_,"\n";
		if(defined $hash{$tmp} or defined $hash{$tmp."--$n"}){
				$tmp=$tmp."$n";
				$hash{$tmp}=$_;
				$n++;
    }
    else{
            $hash{$tmp}=$_;
        }
	}
}
#open TMP,"$workdir";
print "\n";

foreach(sort keys %hash){
    print $_,"\t",$hash{$_},"\n";
}

print "\n";
$m=1;
foreach(sort keys %hash){
    $filename=$hash{$_};
    $newname=sprintf "%s%04d.$filetype",$prefix,$m;
    
        if($filename eq $newname){
            $m++;
			next;
        }
        
        if(-e $newname){
            print "Renaming ",$filename," to $newname.bak...\n";
                rename $filename,$newname.".bak" || die "cannot rename\n";      
            if(-e $filename.".bak"){
                print "Renaming ",$filename.".bak to $filename...\n";
                rename $filename.".bak",$filename|| die "cannot rename\n";      
            }
            $m++;
        }
        else{
            print "Renaming ",$filename," to $newname...\n";
            rename $filename,$newname|| die "cannot rename\n"; 
            if(-e $filename.".bak"){
                print "Renaming ",$filename.".bak to $filename...\n";
                rename $filename.".bak",$filename|| die "cannot rename\n";      
            }
            $m++;
        }
}

print "Done!\n";