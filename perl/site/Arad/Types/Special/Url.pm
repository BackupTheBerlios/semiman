package Arad::Types::Special::Url;

use strict;

sub get_type_params
{
    return ("url",
        {
            'inherits' => [ "varchar", "url_constraint"],
        },
    );
}

1;

