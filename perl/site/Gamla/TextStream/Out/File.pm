package Gamla::TextStream::Out::File;

use strict;

use Gamla::TextStream::Out::Base;

use vars qw(@ISA);

@ISA=qw(Gamla::TextStream::Out::Base);

require 'flush.pl';

sub initialize
{
    my $self = shift;

    my $glob = shift;

    $self->SUPER::initialize();

    $self->{'to'} = $glob;

    return 0;
}

sub append
{
    my $self = shift;

    my $text = shift;

    print {*{$self->{'to'}}} $text;

    return $self->SUPER::append($text);
}

sub flush_
{
    my $self = shift;

    &flush( $self->{'to'} );
}

1;
