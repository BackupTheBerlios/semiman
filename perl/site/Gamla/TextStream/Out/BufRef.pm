package Gamla::TextStream::Out::BufRef;

use strict;

use Gamla::TextStream::Out::Base;

use vars qw(@ISA);

@ISA=qw(Gamla::TextStream::Out::Base);

sub initialize
{
    my $self = shift;

    my $to = shift;

    $self->SUPER::initialize();

    $self->{'buf_ref'} = $to;

    return 0;
}

sub append
{
    my $self = shift;

    my $text = shift;

    ${ $self->{'buf_ref'} } .= $text;

    return $self->SUPER::append($text);
}

1;
