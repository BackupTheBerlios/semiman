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

    # If a user with this username was not found -
    # make him a readonly user.
    if (!defined($data))
    {
        return "readonly";
    }

    # Check if the password match
    if ($data->[0] eq $password)
    {
        # The Super_Admin flag determines the level of the user
        return ($data->[1] ? "site" : "club");
    }
    else
    {
        # The passwords do not match - fall back to read only.
        return "readonly";
    }
}

1;


