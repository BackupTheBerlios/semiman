package Technion::Seminars::Utils;

use vars qw(@EXPORT);

use Exporter;

use vars qw(@ISA);

@ISA=qw(Exporter);

@EXPORT=qw(time_remove_secs);
@EXPORT_OK=qw(@week_days_abbrevs);

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


1;
