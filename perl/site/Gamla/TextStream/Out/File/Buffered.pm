package Gamla::TextStream::Out::File::Buffered;

use Gamla::TextStream::Out::Indirect::Buffered;
use Gamla::TextStream::Out::File;

sub new
{
    my $class = shift;

    my $glob = shift;

    my $buf_size = shift;
    
    my $file_stream = Gamla::TextStream::Out::File->new($glob);
    my $buffered_file_stream = 
        Gamla::TextStream::Out::Indirect::Buffered->new(
            $file_stream,
            $buf_size
            );

    return $buffered_file_stream;
}

1;
