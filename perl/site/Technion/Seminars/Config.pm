package Technion::Seminars::Config;

use strict;

use vars qw(%config);

use vars qw(@EXPORT);

@EXPORT=qw(%config);

BEGIN {
    %config = 
    (
        'http_url' => 
            {
                'host' => "localhost",
                'path' => "seminars",
            },
        'https_url' =>
            {
                'host' => "localhost",
                'path' => "seminars",
            },
    );
};

1;
