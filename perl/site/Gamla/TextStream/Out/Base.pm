package Gamla::TextStream::Out::Base;

use strict;

use Gamla::TextStream::Out::Indirect;

use Gamla::Object;

use vars qw(@ISA);

@ISA=qw(Gamla::Object);

sub initialize
{
    my $self = shift;

    $self->{'count'} = 0;
    $self->{'autoflush'} = 0;
}

# This method should be called _after_ the things are done by the 
# derived class' method.
sub append
{
    my $self = shift;

    my $text = shift;

    $self->{'count'} += length($text);

    if ($self->{'autoflush'})
    {
        $self->flush_();
    }
}

sub flush_
{
}

sub a
{
    my $self = shift;

    return $self->append(@_);
}

sub add
{
    my $self = shift;

    return $self->append(@_);
}

sub print
{
    my $self = shift;

    return $self->append(@_);
}

sub autoflush
{
    my $self = shift;

    my $af = shift;

    $self->{'autoflush'} = (!!$af);
}

sub get_autoflush
{
    my $self = shift;

    return $self->{'autoflush'};
}

sub redirect
{
    my $self = shift;

    my $to = shift;

    $self->destroy_();

    %{$self} = ();

    bless $self, "Gamla::TextStream::Out::Indirect";

    $self->initialize($to);
}

sub get_count
{
    my $self = shift;

    return $self->{'count'};
}

sub tell_
{
    my $self = shift;

    return $self->get_count();
}

1;
