# This is the Type Manager for the Seminars Project

package Technion::Seminars::TypeMan;

use strict;

use Arad::Types;

use Arad::Types::SQL::Int32;
use Arad::Types::SQL::VarChar;
use Arad::Types::SQL::Double;
use Arad::Types::SQL::Boolean;

use Arad::Types::Abstract::Bounded;

use Arad::Types::Special::EmailConstraint;
use Arad::Types::Special::Email;

sub get_type_man
{
    my $sql_typeman = Arad::Types->new();
    $sql_typeman->register_type(Arad::Types::SQL::Int32::get_type_params());
    $sql_typeman->register_type(Arad::Types::SQL::VarChar::get_type_params());
    $sql_typeman->register_type(Arad::Types::SQL::Double::get_type_params());
    $sql_typeman->register_type(Arad::Types::SQL::Boolean::get_type_params());

    my $abstract_typeman = Arad::Types->new();

    $abstract_typeman->register_type(Arad::Types::Abstract::Bounded::get_type_params());

    my $typeman = Arad::Types->new(-inherits => [$sql_typeman, $abstract_typeman]);

    $typeman->register_type(Arad::Types::Special::EmailConstraint::get_type_params());
    $typeman->register_type(Arad::Types::Special::Email::get_type_params());

    return $typeman;
}

1;
