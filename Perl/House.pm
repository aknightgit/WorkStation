#!/usr/perl5/bin/perl
package House;

sub new{
    my $class=shift;
        my ($owner,$salary,$style)=@_;
        $ref={  "OWNER"=>$owner,
                        "SALARY"=>$salary,
                        "STYLE"=>$style,
                }       ;
        return bless($ref,$class);
}

sub display{
        my $self=shift;
        foreach $key (@_){
                print "$key: $self->{$key}\n";
        }
}
1;