package Technion::Seminars::Config;

use strict;

use Exporter;

use vars qw(%config);

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(%config);

BEGIN {
    %config = 
    (
        # The URL of the HTTP Read-only Tree
        'http_url' => 
            {
                'host' => "localhost",
                'path' => "seminars",
            },
        # The URL of the HTTPS Admin Tree
        'https_url' =>
            {
                'host' => "localhost",
                'path' => "seminars",
            },
        # Browser Compatibility Flag - make the code less standard
        # and more compatible with common browser bugs.
        'browser_compatibility' => 1,

    );
};

1;
