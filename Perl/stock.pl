#!/usr/perl5/bin/perl 

use strict;

########## 
#  this is a tool handler my stocks
##########
my $int= "=&=" x 25;
my $home=qq(/home/i/u/aknight/888);
my $savefile=qq($home/stock.sav);
my $logfile=qq($home/stock.log);
my $cfgfile=qq($home/stock.cfg);
my $today=sprintf "%04d%02d%02d",(localtime(time()))[0,1,2];

my(%cfg,$answer);

open(CFG,$cfgfile)||die "cannot open $cfgfile. $!\n";
    foreach(<CFG>){
	    my ($key,$value)=($1,$2) if($_=~/([\S]+)[\s]+=[\s]+([\S]+)/);
		$cfg{$key}=$value;
	}
close(CFG);

LABEL1: {
print <<EOF;
$int
Please choose your option:
    [1]. Check my stocks
    [2]. Buy new stocks
    [3]. Sell my stocks
    [4]. Exit 
EOF
}
print "Your option :";

chomp($answer=<STDIN>);
if($answer eq 1){
LABEL2:{
print <<EOF;
$int
Check my stocks. Please choose:
    [1]. show all stocks I have
    [2]. show my net assets
    [3]. update my stock value
    [4]. back
EOF
}
print "Your option :";

    chomp($answer=<STDIN>);
    if($answer eq 4){
	    goto LABEL1;
	}
	elsif($answer eq 1){
	
	}
	elsif($answer  eq 2){
	
	}
	elsif($answer eq 3){
	
	)
	else{
	    exit;
	}

}
elsif($answer eq 2){

LABEL3:{
print <<EOF;
$int
Buy new stocks. Please input:
EOF
print "Stock code: ";
chomp(my $sn=<STDIN>);

}
    
}
elsif($answer eq 3){
    print "Sell my stocks";
}
else{
    exit;
}

