package Technion::Seminars::Utils;

use vars qw(@EXPORT);

use Exporter;

use vars qw(@ISA);

@ISA=qw(Exporter);

@EXPORT=qw(time_remove_secs);
@EXPORT_OK=qw(@week_days_abbrevs format_date get_future_day get_next_day);

use Time::DaysInMonth;

sub time_remove_secs
{
    my $time_raw = shift;

    $time_raw =~ m/^(\d+):(\d+)/;
    return "$1:$2";
}

use vars qw(@week_day_abbrevs);

BEGIN {
    @week_days_abbrevs= (qw(Sun Mon Tue Wed Thu Fri Sat));
}

sub format_date
{
    my ($y, $m, $d) = @_;

    return (sprintf("%.4d", $y), sprintf("%.2d", $m), sprintf("%.2d", $d));
};

# Get a date $inc days in the future.
# $inc must be lesser than 28, as this function does not
# overflow to monthes after the next properly.
sub get_future_day
{
    my $inc = shift;
    
    my ($y, $m, $d) = @_;

    $d += $inc;
    if ($d > days_in($y,$m))
    {
        $d -= days_in($y,$m);
        $m++;
        if ($m > 12)
        {
            $m = 1;
            $y++;
        }
    }
    return format_date($y,$m,$d);
};

sub get_next_day 
{
    return get_future_day(1,@_);
};


1;
