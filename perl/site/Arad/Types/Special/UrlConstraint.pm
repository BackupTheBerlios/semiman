# Arad::Types::Special::EmailConstraint - an E-mail constraint
# (for a string)
#
# Requires the ckaddr script by Tom Christiansen (available on CPAN)

package Arad::Types::Special::UrlConstraint;

use strict;


my $length_param = 'len';

sub check_value
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value = shift;

    my($scheme, $authority, $path, $query, $fragment) =
    $value =~ m|^(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?|;
    
    if ($scheme ne "http")
    {
        return (1, "Not an HTTP URL");
    }
    my @array = gethostbyname($authority);
    if (! scalar(@array))
    {
        return (1, "Unknown host \"$authority\" in URL");
    }   

    return (0, "");
}

sub get_type_params
{
    return ("url_constraint",
        {
            'check_value' => \&check_value ,
        }
        );
}

1;
