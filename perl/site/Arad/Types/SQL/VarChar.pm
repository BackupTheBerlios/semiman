# Arad::Types::SQL::VarChar - an SQL "varchar" data type 
# (variable length string)
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain
package Arad::Types::SQL::VarChar;

use strict;


my $length_param = 'len';

sub check_value
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value = shift;

    if (length($value) > $type_params->{$length_param})
    {
        return (1, "The length of \$F must be shorter than " . $type_params->{$length_param} . " bytes.");
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

    return ($value1 cmp $value2);
}

sub get_type_params
{
    return ("varchar",
        {
            'check_value' => \&check_value ,
            'compare' => \&compare_values ,
        }
        );
}

1;
