package Technion::Seminars::UserMan;

use Technion::Seminars::DBI;
use Technion::Seminars::Config;

use Crypt::Blowfish;
use MIME::Base64;

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

    open I, "<" . $config{'crypt_file'} || die "Cannot open Crypt file";
    my $text = join("", <I>);
    close(I);

    my $key = pack("a56", $text);

    $self->{'cipher'} = Crypt::Blowfish->new($key);

    return 0;
}

sub get_admin_level
{
    my $self = shift;

    my $user = shift;
    my $password = shift;

    my $dbh = Technion::Seminars::DBI->new();

    my $sth = $dbh->prepare("SELECT Password, Super_Admin, User_ID FROM users WHERE Username = " . $dbh->quote($user));
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
        return (($data->[1] ? "site" : "club"), $data->[2]);
    }
    else
    {
        # The passwords do not match - fall back to read only.
        return ("readonly", undef);
    }
}

sub can_edit_club
{
    my $self = shift;

    my $user_id = shift;
    my $club_id = shift;

    my $dbh = Technion::Seminars::DBI->new();

    my $sth = $dbh->prepare("SELECT count(*), Subjects FROM permissions WHERE User_ID = $user_id AND Club_ID = $club_id");
    my $rv = $sth->execute();
    my $row = $sth->fetchrow_arrayref();
    return (@$row);
}

sub decrypt
{
    my $self = shift;

    my $enc_password = shift;

    my $cipher = $self->{'cipher'};
    
    my $unenc = decode_base64($enc_password);
    my $unblown;

    my $pos;
    for ($pos = 0; $pos < length($unenc); $pos += 8)
    {
        $unblown .= $cipher->decrypt(substr($unenc, $pos, 8));
    }
    $unblown =~ s/\0*$//;

    return $unblown;
}

sub encrypt
{
    my $self = shift;

    my $password = shift;

    $password .= ("\0" x 8);

    my $cipher = $self->{'cipher'};

    my $blown = "";
    my $pos;
    
    for ( $pos = 0; (($pos+8) < length($password)) ; $pos += 8)
    {
        $blown .= $cipher->encrypt(substr($password, $pos, 8));
    }

    my $enc = encode_base64($blown, "");

    return $enc;
}

sub get_user_and_password
{
    my $self = shift;

    my $q = shift;

    my %cookie = $q->cookie('seminars_auth');
    
    my $user = $cookie{'user'};

    my $password = $self->decrypt($cookie{'password'});

    return ($user, $password);
}

1;


