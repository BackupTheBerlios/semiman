package Gamla::TextStream::Out::Buffer;

use strict;

use Gamla::TextStream::Out::Base;

use vars qw(@ISA);

@ISA=qw(Gamla::TextStream::Out::Base);

sub initialize
{
    my $self = shift;

    $self->SUPER::initialize();

    $self->{'buffer'} = "";

    return 0;
}

sub append
{
    my $self = shift;

    my $text = shift;

    $self->{'buffer'} .= $text;

    return $self->SUPER::append($text);
}

sub get_buffer
{
    my $self = shift;

    return $self->{'buffer'};
}
1;
