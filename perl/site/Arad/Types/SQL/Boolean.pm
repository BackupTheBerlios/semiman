# Arad::Types::SQL::Boolean - a 0/1 boolean data type
#

package Arad::Types::SQL::Boolean;

use strict;

use Math::BigInt;

sub check_value
{
    my $typeman = shift;
    my $type = shift;
    my $params = shift;
    my $value = shift;
   
    if (!defined($value) || ($value eq "0") || ($value eq "1"))
    {
        return (0, "");
    }
    else
    {
        return (1, "A boolean value must be 0 or 1");
    }
}

sub compare_values
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    # Cool, eh eh he he he.
    return (($value1 ? 1 : 0) <=> ($value2 ? 1 : 0));
}


sub get_type_params
{
    return ("bool", 
        { 
            'check_value' => \&check_value ,
            'compare' => \&compare_values ,
        }
        );
}
