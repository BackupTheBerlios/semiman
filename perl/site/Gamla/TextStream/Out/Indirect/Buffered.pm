package Gamla::TextStream::Out::Indirect::Buffered;

use strict;

use Gamla::TextStream::Out::Base;

use vars qw(@ISA);

@ISA=qw(Gamla::TextStream::Out::Base);

use vars qw($default_buffer_size);

$default_buffer_size = 1024;

sub initialize
{
    my $self = shift;

    my $to = shift;

    my $buf_size = shift || $default_buffer_size;
    
    $self->SUPER::initialize();

    $self->{'to'} = $to;

    $self->{'buffer'} = "";

    $self->{'buf_size'} = $buf_size;

    return 0;
}

sub append
{
    my $self = shift;

    my $text = shift;

    my $call_flush = 0;

    $self->{'buffer'} .= $text;

    if (length($self->{'buffer'}) > $self->{'buf_size'})
    {
        $call_flush = 1;
    }

    $self->SUPER::append($text);

    if ($call_flush)
    {
        $self->flush_();
    }
}

sub flush_
{
    my $self = shift;

    my $to = $self->{'to'};

    $to->append($self->{'buffer'});

    $self->{'buffer'} = "";

    return $to->flush_();
}


