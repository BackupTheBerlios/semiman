# Arad::Types::SQL::Double - a floating-point SQL data type
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain


package Arad::Types::SQL::Double;

use strict;

sub check_value
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value = shift;

    if ($value =~ /^[-+]?\d+(\.\d+)?((e|E)\d+)?$/)
    {
        return (0, "");
    }
    elsif ((!defined($value)) || ($value eq ''))
    {
        return (0,"");
    }
    else
    {
        return (1, "\$F must be an floating point value.");
    }

}

sub compare_values
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    return ($value1 <=> $value2);
}


sub get_type_params
{
    return ("double",
        {
            'check_value' => \&check_value ,
            'compare' => \&compare_values,
        }
        );
}

1;
