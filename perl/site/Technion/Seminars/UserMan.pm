package Technion::Seminars::UserMan;

use Technion::Seminars::DBI;

use strict;

sub new
{
    my $class = shift;

    my $self = {};

    bless $self, $class;

    $self->initialize(@_);

    return $self;
}

my %users = 
    (
        "shlomif" => { 'admin' => 1, "password" => "Hello"}, 
        "roi" => { 'admin' => 1, "password=" => "blah"}, 
        "tilda" => {'admin' => 1, "password" => "cool_jives"},
    );
    
sub initialize
{
    my $self = shift;

    return 0;
}

sub get_admin_level
{
    my $self = shift;

    my $user = shift;
    my $password = shift;

    my $dbh = Technion::Seminars::DBI->new();

    my $sth = $dbh->prepare("SELECT Password, Super_Admin FROM users WHERE Username = " . $dbh->quote($user));
    my $rv = $sth->execute();

    my $data = $sth->fetchrow_arrayref();

    if ($data->[0] eq $password)
    {
        return ($data->[1] ? "site" : "club");
    }
    else
    {
        return "readonly";
    }
}

1;


