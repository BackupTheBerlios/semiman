# Arad::Types::Template - a template for an Arad type implementation.
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain
package Arad::Types::Template;

use strict;

sub check_value
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value = shift;
}

sub compare_values
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;
}

sub get_type_params
{
    return ("type_id",
        {
            'check_value' => \&check_value ,
            'compare' => \&compare_values,
        }
        );
}

1;
