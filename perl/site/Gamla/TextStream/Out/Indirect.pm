package Gamla::TextStream::Out::Indirect;

use strict;

use Gamla::TextStream::Out::Base;

use vars qw(@ISA);

@ISA=qw(Gamla::TextStream::Out::Base);

sub initialize
{
    my $self = shift;

    my $to = shift;
    
    $self->SUPER::initialize();

    $self->{'to'} = $to;

    return 0;
}

sub append
{
    my $self = shift;

    my $text = shift;

    $self->{'to'}->append($text);

    $self->SUPER::append($text);
}

sub flush_
{
    my $self = shift;

    return $self->{'to'}->flush_();
}

sub get_buffer
{
    my $self = shift;

    my $to = $self->{'to'};

    if ($to->can("get_buffer"))
    {
        return $to->get_buffer();
    }
}

1;
