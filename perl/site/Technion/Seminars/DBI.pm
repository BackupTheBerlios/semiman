package Technion::Seminars::DBI;

use DBI;

use Technion::Seminars::Config;

sub new
{
    my $dbh = DBI->connect(@{$config{'database'}}{'dsn', 'user', 'password'});
    return $dbh;
}

1;
