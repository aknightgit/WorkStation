package Time;

use strict;

sub new{  ## class method
    my $class=shift;
    my $ref=\@_;
    return bless $ref,$class;
} 

sub check{
    my $self=shift;
        my @timelist=@$self;
        my $ret = 1;  # return code defaulted as 1;
        if (@timelist eq 0){    #return 0 if argv is null, return $_ if it's incorrect form
            $ret = 0;
        }
        else{
            foreach(@timelist){
                my ($h,$m,$s)=split(':',$_);
                $ret = $_ unless($_=~/\d\d\:\d\d\:\d\d/ and $h < 24 and $h >= 0 and $m <60 and $s < 60);
            }
        }
        return $ret;
}

sub reform{
    my $self=shift;
        my @timelist=@$self;
        foreach(@timelist){
            if($_=~/[0-9][0-9][0-9][0-9][0-9][0-9]/){  #reform which looks like 065120
                $_=sprintf "%02d:%02d:%02d",substr($_,0,2),substr($_,2,2),substr($_,4,2);
            }
            elsif($_=~/^\d\d\:\d\d\>/){ # reform which looks like 15:20
                $_=sprintf "$_:00";
            }   
        }
    return @timelist;   
}

sub seconds{   ## class method
    my $self=shift;
        my @timelist=@$self;
        my $ret;
        if(@timelist == 0){
            return 0;
        }
        else{
		    ($self->check == 1) || (@timelist=$self->reform);
		    foreach (@timelist){
            $_=(split(':',$_))[0]*3600+(split(':',$_))[1]*60+(split(':',$_))[2];			
			}
			return @timelist;
        }
}

sub max{
    my $self=shift;
        my @timelist=@$self;
        my $ret;
        my $max;
        if (@timelist < 2){
            $ret = 0;
        }
        else{
		    ($self->check == 1) || (@timelist=$self->reform);
            foreach(@timelist){
                my $tmp=(split(':',$_))[0]*3600+(split(':',$_))[1]*60+(split(':',$_))[2];
                if($tmp > $max){
                    $max=$tmp;
                    $ret=$_;
                }
            }
        }
        return $ret;
}

sub min{
    my $self=shift;
        my @timelist=@$self;
        my $max=24*3600;
        my $ret;
        if (@timelist < 2){
            $ret = 0;
        }
        else{
		    ($self->check == 1) || (@timelist=$self->reform);
            foreach(@timelist){
                my $tmp=(split(':',$_))[0]*3600+(split(':',$_))[1]*60+(split(':',$_))[2];
                    if($tmp < $max){
                        $max=$tmp;
                        $ret=$_;                        
                    }
            }
        }
        return $ret;
}

sub minus{
    my $self=shift;
        my @timelist=@$self;
        my $ret;
        if(@timelist ne 2){  # return 0 if argv num is not 2
            $ret = 0;
        }
        else{
	        @timelist=$self->seconds;
            $ret=($timelist[0]-$timelist[1]);         
        }       
        return $ret;
}

sub div{
    my $self=shift;
        my @timelist=@$self;
        my $ret;
        if(@timelist ne 2){  # return 0 if argv num is not 2
            $ret = 0;
        }
        else{
            my $tmp=$self->minus;
            $tmp=~s/^\-//;
            $ret = sprintf "%02d:%02d:%02d",$tmp/3600,$tmp%3600/60,$tmp%60;
        }
        return $ret;
}

sub sum{
    my $self=shift;
        my @timelist=@$self;
        my $sum;
        my $ret;
        if (@timelist eq 0){    #return 0 if argv is null, return $_ if it's incorrect form
            $ret = 0;
        }
        else{
		    @timelist=$self->seconds;
            foreach(@timelist){
                $sum+=$_;
            }
            $ret=$sum;
        }
        return $ret;
}

sub avg{
    my $self=shift;
        my @timelist=@$self;
        my $ret;
        if (@timelist eq 0){    #return 0 if argv is null, return $_ if it's incorrect form
            $ret = 0;
        }       
        else{
		    ($self->check == 1) || (@timelist=$self->reform);
            my $avg=$self->sum / @timelist;
            $ret = sprintf "%02d:%02d:%02d",$avg/3600,$avg%3600/60,$avg%60;
        }
        return $ret;
}

1;