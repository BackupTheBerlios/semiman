package Technion::Seminars::Utils;

use vars qw(@EXPORT);

use Exporter;

use vars qw(@ISA);

@ISA=qw(Exporter);

@EXPORT=qw(time_remove_secs);

sub time_remove_secs
{
    my $time_raw = shift;

    $time_raw =~ m/^(\d+):(\d+)/;
    return "$1:$2";
}

1;
