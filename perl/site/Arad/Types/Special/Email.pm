package Arad::Types::Special::Email;

use strict;

sub get_type_params
{
    return ("email",
        {
            'inherits' => [ "varchar", "email_constraint"],
        },
    );
}

1;

