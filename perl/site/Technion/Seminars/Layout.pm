package Technion::Seminars::Layout;

sub new
{
    my $class = shift;
    my $self = {};

    bless $self, $class;

    $self->initialize(@_);

    return $self;
}

sub initialize
{
    my $self = shift;

    my $path = "";
    while (scalar(@_))
    {
        my $arg = shift;
        my $param = shift;
        if ($arg =~ /^-?path$/)
        {
            $path = $param;
        }
    }

    $self->{'path'} = [ split(m!/!, $path) ] ;

    return 0;
}

1;

