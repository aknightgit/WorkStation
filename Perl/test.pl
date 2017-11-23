#!/usr/perl5/bin/perl

use strict;

###################################################################
##                                                    Jamping frogs
## 
##                              _@      _@      _@       _      @_      @_      @_
##                      ___________________________________
##
####################################################################

my $water='  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';
my $slash='#'x80;
my $slash2='-'x80;
my %start=('1'=>'R','2'=>'R','3'=>'R','4'=>'N','5'=>'L','6'=>'L','7'=>'L');
my @frogs=('-&@','-&@','-&@','___','@&+','@&+','@&+');
my $frogs=sprintf "@frogs";
my @target=reverse @frogs;
my $target=sprintf "@target";

printf "$slash\n\n\tWe have 7 frogs here:\n\t\t %-4s%-4s%-4s%-4s%-4s%-4s%-4s",(1..7);
printf "\n\n\t\t%-4s%-4s%-4s%-4s%-4s%-4s%-4s",@frogs;
printf "\n\t$water\n\t$water\n\tThree of them head forwart right, three head left, but only 1 rock between them.";
printf "\n\tThey're only allowed to jump to the 1st(or 2nd) free rock ahead of them.\n\tPlease help them to exchange and cross the river.";
printf "\n\tLike this:\n\n\t\t %-4s%-4s%-4s%-4s%-4s%-4s%-4s",(1..7);
printf "\n\n\t\t%-4s%-4s%-4s%-4s%-4s%-4s%-4s\n\t$water\n\t$water\n\n$slash",@target;

my ($jump,$next,$next1,$tmp,$change,$to_reset);
my %queue=%start;
#######################################################################

sub jump{
    ($jump,@frogs)=@_;
    if($frogs[$jump-1] eq '___'){return @frogs;}
    elsif($jump>=1 and $jump<=scalar(@frogs)){
        if($frogs[$jump-1] eq '-&@' and $jump<scalar(@frogs)){
        $next=$jump+1;
        $next1=$jump+2;
        }
        elsif($frogs[$jump-1] eq '@&+' and $jump>1){
        $next=$jump-1;
        $next1=$jump-2;
        }
        else{return @frogs;}    
                
        if($frogs[$next-1] eq '___'){
        $tmp=$frogs[$next-1];
        $frogs[$next-1]=$frogs[$jump-1];
        $frogs[$jump-1]=$tmp;            
        $to_reset=$next;
        $change=1;
        return @frogs;
        } 
        elsif($frogs[$next1-1] eq '___'){
        $tmp=$frogs[$next1-1];
        $frogs[$next1-1]=$frogs[$jump-1];
        $frogs[$jump-1]=$tmp;             
        $to_reset=$next1;
        $change=1;
        return @frogs;  
        }
        else{return @frogs;}
        }
    else{return @frogs;}
}
                
sub reset_up{
    my ($a,$b)=@_;
    ($frogs[$a-1],$frogs[$b-1])=($frogs[$b-1],$frogs[$a-1]);
    return @frogs;
}

@frogs=('-&@','-&@','-&@','___','@&+','@&+','@&+'); 
my %stage=("0"=>"$frogs");
my ($step,$try,@choice,$path);

sub nextgen{
    %stage=@_;
    foreach(keys %stage){
        $try=$_;
        $tmp=$stage{$try};
        @frogs=(split(' ',$tmp));
        delete $stage{$try};   ## delete the up_level stage
        foreach(1..7){
            $change=0;
            @frogs=jump($_,@frogs);
            if ($change==1){
                $path=sprintf "$try$jump";
                $stage{$path}=sprintf "@frogs";
                @frogs=reset_up ($jump,$to_reset);
            
                if($stage{$path} eq $target){
                    push(@choice,$path);
                    }
                }       
            } 
                        
        }
        return %stage;
}

print "\n";

foreach $step (0..100){
#    print "step$step:\n";
#    foreach (keys %stage){
#        print $_,"\t",$stage{$_},"\n";
#        }
#    print "\n";
    
    if(defined @choice){
        print "Fuck, you got it!\n";
        print "The right way can be:\n\n";
        foreach(@choice){
            print $_,"\t",$stage{$_},"\n";                   
            }                               
        last;
        }

        %stage=&nextgen(%stage);        
    }

## print step by step   
     
foreach(@choice){
	@frogs=('-&@','-&@','-&@','___','@&+','@&+','@&+');
	$path=$_;
  print "\n$slash\nStep by step:\n";
  foreach $step (0..100){
  	$jump=substr($path,0,1);
  	$tmp=length($path)-1;
  	$path=substr($path,1,$tmp);
  	
  	last if(! defined $path);
  	
  	print "step$step:\n"; 
  	print "which frog to jump: < $jump >\t";
  	@frogs=jump($jump,@frogs);
  	print "now we get:\n";
  	print "\t","@frogs","\n";
  	print $water,"\n\n";

    }
  }
  
  print $slash,"\n";