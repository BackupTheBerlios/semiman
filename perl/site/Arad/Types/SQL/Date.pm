# Arad::Types::SQL::Date - an SQL date datatype.
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain

package Arad::Types::SQL::Date;

use strict;

use Time::DaysInMonth;

sub check_value
{
    my $typeman = shift;
    my $type = shift;
    my $params = shift;
    my $value = shift;
    

    if ($value =~ /^-?\d+-\d{1,2}-\d{1,2}$/)
    {
        my @parts = split(/-/, $value);

        # In case the year is a negative one
        if ($value =~ /^-/)
        {
            @parts = ('-'.$parts[1], @parts[2..3]);
        }

        # Neither we nor the databases are Y10K compliant

        if (($parts[1] < 1) || ($parts[1] > 12))
        {
            return (1, "The month in \$F must be in the range 1-12.");
        }
        else
        {
            my $max_days = days_in(expand_year($parts[0]), $parts[1]);
            if (($parts[2] < 1) || ($parts[2] > $max_days))
            {
                return (1, "The day of the month in \$F must be in the range 1-" . $max_days);
            }
            else
            {
                return (0, "");
            }                
        }
    }
    elsif (($value eq '') || ($value eq undef))
    {
        return (0, "");
    }
    else
    {
        return (1, "\$F is a date and must be in the form YYYY-MM-DD");
    }
}

# Expands years given as 1, 2, 3 or 4 digits to a 4-digit precision
# year value.
sub expand_year
{
    my $entered = shift;
    my ($new_year);

    my @curr_time = localtime(time());
    my $curr_year = $curr_time[5]+1900;

    if ($entered < 0)
    {
        return $entered;
    }    
    elsif (length($entered) == 1)
    {
        $new_year = $curr_year - ($curr_year % 10) + $entered;
    }
    elsif (length($entered) == 2)
    {
        # In case somebody decides to travel back in time and still use this software... :-)
        if (($curr_year >= 0) && ($curr_year <= 99))
        {
            $new_year = $curr_year - ($curr_year % 100) + $entered;
        }
        else
        {
            # Create a window from $curr_year-50 to $curr_year+50 
            $new_year = ($curr_year-50 + (($entered - ($curr_year % 100) + 50) % 100));
        }
    }
    elsif (length($entered) == 3)
    {
        if (($curr_year >= 0) && ($curr_year <= 999))
        {
            $new_year = $curr_year - ($curr_year % 1000) + $entered;
        }
        else
        {
            # Create a window from $curr_year-500 to $curr_year+500 
            $new_year = ($curr_year-500 + (($entered - ($curr_year % 1000) + 500) % 1000));
        }
    }
    else
    {
        $new_year = $entered;
    }

    return $new_year;
}


sub compare_values
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my @p1 = split(/-/, $value1);
    if ($value1 =~ /^-/)
    {
        @p1 = ('-'.$p1[1], @p1[2..3]);
    }
    
    my @p2 = split(/-/, $value2);
    if ($value2 =~ /^-/)
    {
        @p2 = ('-'.$p2[1], @p2[2..3]);
    }

    return (($p1[0] <=> $p2[0]) || 
            ($p1[1] <=> $p2[1]) || 
            ($p1[2] <=> $p2[2])
           );
}


sub get_type_params
{
    return ("date", 
        { 
            'check_value' => \&check_value ,
            'compare' => \&compare_values ,
        }
        );
}

1;

