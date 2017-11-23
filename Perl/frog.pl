#!/usr/local/bin/perl

use strict;

###################################################################
##                      Jamping frogs
##
##            _@      _@      _@       _      @_      @_      @_
##        ___________________________________________________________
##
####################################################################

my $water='  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';
my $slash='#'x80;
my $slash2='-'x80;
my %start=('1'=>'R','2'=>'R','3'=>'R','4'=>'N','5'=>'L','6'=>'L','7'=>'L');
my @frogs=('-&@','-&@','-&@',' _','@&+','@&+','@&+');
my @target=reverse @frogs;

printf "$slash\n\n\tWe have 7 frogs here:\n\t\t%-4s%-4s%-4s%-4s%-4s%-4s%-4s",(1..7);
printf "\n\n\t\t%-4s%-4s%-4s%-4s%-4s%-4s%-4s",@frogs;
printf "\n\t$water\n\t$water\n\tThree of them head forwart right, three head left, but only 1 rock between them.";
printf "\n\tThey're only allowed to jump to the 1st(or 2nd) free rock ahead of them.\n\tPlease help them to exchange and cross the river.";
printf "\n\tLike this:\n\n\t\t%-4s%-4s%-4s%-4s%-4s%-4s%-4s",(1..7);
printf "\n\n\t\t%-4s%-4s%-4s%-4s%-4s%-4s%-4s\n\t$water\n\t$water\n\n$slash",@target;

my ($jump,$next,$next1,$tmp,$choice);
my $step=0;
my %queue=%start;

for(;;){
my $frogs=join(/ /,@frogs);
my $target=join(/ /,@target);
if($frogs eq $target){  ###cannot use "@frogs==@target"
        print "\n\t@@@@@@@@@@@@@@ Congratulations!!! @@@@@@@@@@@@@@\n\t\tYou'll make a good frog Mama!!!\n";
        exit;
        }

printf "\n\n  %-70s\n%-10s%-50s%10s",'*'x68,"  **","You're now at step $step, here're the frogs at:","**";
printf "\n%-10s%-10s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%22s","  **"," "x10,(1..7),"**";
printf "\n%-10s%-10s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%22s","  **"," "x10,@frogs,"**";
printf "\n%-10s%-50s%10s\n%-10s%-50s%10s","  **",$water,"**","  **",$water,"**";
printf "\n  %-70s\n\tNow please select which frog to jump\n\tType [r/R] to restart, [e] to exit:","*"x68,"**";

$jump=<STDIN>; 
chomp $jump;
if(!defined($jump)){next;}   ## if $jump is nother.     # "if(!$jump)" cannott exclude $jump=0.
elsif($jump eq 'e'){exit;}
else{
        if($jump eq 'r' or $jump eq 'R'){
        print "\n\tFrog has been reset.";
        $step=0;
        my ($jump,$next,$next1,$tmp);
    @frogs=('-&@','-&@','-&@',' _','@&+','@&+','@&+');
        %queue=%start;
        next;
        }
        elsif($queue{$jump} eq 'R'){
    $next=$jump+1;
        $next1=$jump+2;
        }
        elsif($queue{$jump} eq 'L'){
    $next=$jump-1;
        $next1=$jump-2;
        }
        elsif($queue{$jump} eq 'N'){
        printf "\n\n\tSelect which frog to jump, BUT NOT A ROCK!!!:";
        next;
        }
        elsif(int($jump)<=0 or int($jump) >=8){
        print "\n\t Do you know what a frog is??? ";
        next;
        }
        else{next;}
}


my ($next_ind,$next1_ind,$jump_ind);
if($next>7 or $next<1 or $next1>8 or $next1<0){
        print "\n\n\tThis frog has nowhere to move, do you want it to suicide??!!\n";
        next;
}
elsif($queue{$next} eq 'N'){
    $tmp=$queue{$next};
        $queue{$next}=$queue{$jump};
        $queue{$jump}=$tmp;
       
        $next_ind=$next-1;
        $jump_ind=$jump-1;
        $tmp=$frogs[$next_ind];
        $frogs[$next_ind]=$frogs[$jump_ind];
        $frogs[$jump_ind]=$tmp;
        $step++;

}
elsif($queue{$next1} eq 'N'){
    $tmp=$queue{$next1};
        $queue{$next1}=$queue{$jump};
        $queue{$jump}=$tmp;
       
        $next1_ind=$next1-1;
        $jump_ind=$jump-1;
        $tmp=$frogs[$next1_ind];
        $frogs[$next1_ind]=$frogs[$jump_ind];
        $frogs[$jump_ind]=$tmp;
        $step++;
}
else{
        print "\n\n\tThis frog has nowhere to move, do you think frogs can fly??!!\n";
        next;
}

}
