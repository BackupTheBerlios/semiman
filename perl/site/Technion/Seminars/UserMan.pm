package Technion::Seminars::UserMan;

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

    if (!exists($users{$user}))
    {
        return "readonly";
    }
    if ($users{$user}->{"password"} ne $password)
    {
        return "readonly";
    }
    return $users{$user}->{'admin'} ? "site" : "club";
}

1;


