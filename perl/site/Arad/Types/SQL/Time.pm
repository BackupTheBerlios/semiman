# Arad::Types::SQL::Time - an SQL Time Value
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain

package Arad::Types::SQL::Time;

use strict;

sub check_value
{
    my $typeman = shift;
    my $type = shift;
    my $params = shift;
    my $value = shift;

    if ($value =~ /^\d{1,2}(:\d{1,2}(:\d{1,2}(\.\d{1,6})?)?)?$/)
    {
        my @parts = split(/:/, $value);

        if ($parts[0] > 23)
        {
            return (1, "The hour in \$F must be in the range 0-23");
        }
        elsif ((scalar(@parts) >= 2) && ($parts[1] > 59))
        {
            return (1, "The minutes in \$F must be in the range 0-59");
        }
        elsif ((scalar(@parts) >= 3) && ($parts[2] >= 60))
        {
            return (1, "The seconds in \$F must be in the range 0-59");
        }
        else
        {
            return (0,"");
        }
    }
    else
    {
        return (1, "\$F is a time and must be in the form HH:MM:SS");
    }
}

sub compare_values
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my @p1 = split(/:/, $value1);
    my @p2 = split(/:/, $value2);

    push @p1, (0,0,0);
    push @p2, (0,0,0);

    return (($p1[0] <=> $p2[0]) || 
            ($p1[1] <=> $p2[1]) || 
            ($p1[2] <=> $p2[2])
           );
}


sub get_type_params
{
    return ("time", 
        { 
            'check_value' => \&check_value ,
            'compare' => \&compare_values ,
        }
        );
}


