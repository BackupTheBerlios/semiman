# Arad::Types::SQL::Int32 - a 32-bit signed integer SQL data type.
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain

package Arad::Types::SQL::Int32;

use strict;

use Math::BigInt;



my $min_value = Math::BigInt->new("-2147483648");
my $max_value = Math::BigInt->new("2147483647");

sub check_value
{
    my $typeman = shift;
    my $type = shift;
    my $params = shift;
    my $value = shift;
   
    my $big_int_value = Math::BigInt->new($value);
   
    if ((!defined($value)) || ($value eq ''))
    {
        return (0, "");
    }    
    elsif ($value !~ /^[-+]?\d+$/)
    {
        return (1, "\$F must be an integer.");
    }
    elsif (($big_int_value > $max_value) || ($big_int_value < $min_value))
    {
        return (1, ("\$F must be in the range " . $min_value . " - " . $max_value . "."));
    }
    else
    {
        return (0, "");
    }
}

sub compare_values
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my $b1 = Math::BigInt->new($value1);
    my $b2 = Math::BigInt->new($value2);

    my $bret = ($b1 <=> $b2);

    my $ret = ($bret<0)?(-1):(($bret>0)?1:0);

    return $ret;
}


sub get_type_params
{
    return ("int32", 
        { 
            'check_value' => \&check_value ,
            'compare' => \&compare_values ,
        }
        );
}
