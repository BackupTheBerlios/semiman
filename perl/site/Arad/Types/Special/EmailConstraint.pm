# Arad::Types::Special::EmailConstraint - an E-mail constraint
# (for a string)
#
# Requires the ckaddr script by Tom Christiansen (available on CPAN)

package Arad::Types::Special::EmailConstraint;

use strict;


my $length_param = 'len';

sub check_value
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value = shift;

    return (((system("ckaddr", $value) / 256) == 0) ? (0, ""): (1,"Invalid E-mail address"));
}

sub get_type_params
{
    return ("email_constraint",
        {
            'check_value' => \&check_value ,
        }
        );
}

1;
