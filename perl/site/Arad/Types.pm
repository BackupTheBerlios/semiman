# Arad::Types - a type manager. It holds a hash of various types and
# multiplexes their various functions. Check the types files for more 
# information regarding those types.
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
# This code is under the public domain. (It's uncopyrighted)
#
# Version 0.3.1

package Arad::Types;

use strict;

use Arad::Utils;
use Arad::Object;

use vars qw(@ISA);

@ISA=qw(Arad::Object);

sub initialize
{
    my $self = shift;
    
    $self->{'types'} = {};
    
    $self->{'parents'} = [];
    
    my $opt;
    
    while ($opt = shift)
    {
    	if ($opt eq '-inherits')
    	{
    	    $self->{'parents'} = Arad::Utils::to_arrayref(shift);
    	}
    }

}

#sub set_sql_driver
#{
#    my $self = shift;
#
#    my $sql_driver = shift;
#
#    $self->{'sql_driver'} = $sql_driver;
#}

sub destroy_
{
    my $self = shift;
    
    delete($self->{'inherits'});
    delete($self->{'types'});
}

sub register_type
{
    my $self = shift;
    
    my $id = shift;
    my $type_record = shift;
    
    $self->{'types'}->{$id} = $type_record;
    
    return 0;
}

sub find_type_man
{
    my $self = shift;
    
    my $type_id = shift;
    
    my $ret;

    if (exists($self->{'types'}->{$type_id}))
    {
        return $self;
    }
    
    foreach my $parent (@{$self->{'parents'}})
    {
    	$ret = $parent->find_type_man($type_id);
    	if ($ret)
    	{
    	    return $ret;
    	}
    }
    
    return undef;
}

# Parameters to pass to every method
# The typesman
# The type specifier
# The type parameters
# The value
# 

sub normalize_type
{
    my $type_id = shift;

    if (ref($type_id) eq "")
    {
        return {
            'inherits' => [ $type_id ],
        };
    }
    elsif (ref($type_id) eq "ARRAY")
    {
        return {
            'inherits' => [ @{$type_id} ],
        };
    }
    else
    {
        return $type_id;
    }
}

sub check_value_by_array
{
    my $self = shift;

    my $orig_type = shift;
    my $type_array = shift;
    my $type_params = shift;
    my $value = shift;

    my @ret;

    foreach my $parent (@{$type_array})
    {
        @ret = $self->check_value_proto(
            $orig_type,
            $parent,
            $type_params,
            $value
            );
        
        if ($ret[0])
        {
           return @ret;
        }
    }
    return (0, "");
}

sub check_value_by_type_record
{
    my $self = shift;
    
    my $orig_type = shift;
    my $type_record = shift; 
    my $type_params = shift;
    my $value = shift;
    
    my @ret;
    
    if (exists($type_record->{'inherits'}) && 
       (ref($type_record->{'inherits'}) eq "ARRAY"))
    {
        @ret = $self->check_value_by_array(
            $orig_type,
            $type_record->{'inherits'},
            $type_params,
            $value
            );
    
        if ($ret[0])
        {
            return @ret;
        }
    }
    
    if (exists($type_record->{'check_value'}))
    {
        return $type_record->{'check_value'}->(
            $self, 
            $orig_type,
            $type_params,
            $value,
            );
    }

    return (0, "");
}


sub check_value_by_type_id
{
    my $self = shift;

    my $orig_type = shift;
    my $type_id = shift; # Must be a string
    my $type_params = shift;
    my $value = shift;
    
    my $typeman = $self->find_type_man($type_id);
    if ($typeman)
    {
        my $type_record = $typeman->{'types'}->{$type_id};

        return $self->check_value_by_type_record(
            $orig_type,
            $type_record,
            $type_params,
            $value
            );
    }

    return (0,"");
}

sub check_value_proto
{
    my $self = shift;

    my $orig_type = shift;
    my $type_id = shift;
    my $type_params = shift;
    my $value = shift;

    if (ref($type_id) eq "")
    {
        return $self->check_value_by_type_id(
            $orig_type, 
            $type_id, 
            $type_params, 
            $value);
    }
    elsif (ref($type_id) eq "ARRAY")
    {
        return $self->check_value_by_array(
            $orig_type,
            $type_id,
            $type_params,
            $value);
    }
    else
    {
        return $self->check_value_by_type_record(
            $orig_type,
            $type_id,
            $type_params,
            $value);        
    }
}

# This method checks if a certain value which was inputted by the user
# is legal as far as the type and its parameters are concerned.
sub check_value
{
    my $self = shift;

    my $type_id = shift;
    my $type_params = shift;
    my $value = shift;

    return $self->check_value_proto(
        $type_id,
        $type_id,
        $type_params,
        $value);
}
# Returns:
# ($status, $error_string) = $types->check_value(...)
# $status - 0 - OK, 1 - Not OK.
#

sub compare_values_by_array
{
    my $self = shift;

    my $orig_type = shift;
    my $type_array = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my @ret;

    foreach my $parent (reverse(@{$type_array}))
    {
        @ret = $self->compare_values_proto(
            $orig_type,
            $parent,
            $type_params,
            $value1,
            $value2,
            );
        
        if ($ret[0])
        {
            return @ret;
        }
    }
    return (0,0);
}

sub compare_values_by_type_record
{
    my $self = shift;
    
    my $orig_type = shift;
    my $type_record = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my @ret;

    if (exists($type_record->{'compare'}))
    {
        return (1, $type_record->{'compare'}->(
            $self,
            $orig_type,
            $type_params,
            $value1,
            $value2,
        ));
    }

    if (exists($type_record->{'inherits'}) &&
       (ref($type_record->{'inherits'}) eq "ARRAY"))
    {
        return $self->compare_values_by_array(
            $orig_type,
            $type_record->{'inherits'},
            $type_params,
            $value1,
            $value2);
    }

    return (0,0);
}

sub compare_values_by_type_id
{
    my $self = shift;

    my $orig_type = shift;
    my $type_id = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my $typeman = $self->find_type_man($type_id);
    if ($typeman)
    {
        my $type_record = $typeman->{'types'}->{$type_id};

        return $self->compare_values_by_type_record(
            $orig_type,
            $type_record,
            $type_params,
            $value1,
            $value2,
            );
    }

    return (0,0);
}

sub compare_values_proto
{
    my $self = shift;
    
    my $orig_type = shift;
    my $type_id = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;
    
    if (ref($type_id) eq "")
    {
        return $self->compare_values_by_type_id(
            $orig_type, 
            $type_id, 
            $type_params, 
            $value1,
            $value2);
    }
    elsif (ref($type_id) eq "ARRAY")
    {
        return $self->compare_values_by_array(
            $orig_type,
            $type_id,
            $type_params,
            $value1,
            $value2,
            );
    }
    else
    {
        return $self->compare_values_by_type_record(
            $orig_type,
            $type_id,
            $type_params,
            $value1,
            $value2,
            );        
    }
}    

# Compares two values from the same data type, and returns a positive number
# if the first is "greater" than the second. A negative one if it's lesser,
# and 0 if both values are equal.
sub compare_values
{
    my $self = shift;

    my $type_id = shift;
    my $type_params = shift;
    my $value1 = shift;
    my $value2 = shift;

    my @ret = $self->compare_values_proto(
        $type_id,
        $type_id,
        $type_params,
        $value1,
        $value2
        );

    return $ret[1];
}


## Converts a perl-style value to an SQL value that can be placed inside
## SQL clauses.
#sub convert_to_sql
#{
#    my $self = shift;
#
#    my $type = shift;
#    my $type_params = shift;
#    my $value = shift;
#
#    return $types{$type}->base_to_sql($self->{'sql_driver'}, $type_params, $value);
#}
## Returns:
## ($flags, $sql_value) = $types->convert_to_sql(...)
## $flags -
##      & 0x1 - Place inside single-quotes
##      & 0x2 - Breakable (can be put inside multiple UPDATE statements)
## $sql_value - the SQL value, unquoted, with no conversion of special characters
##              to \
##
#
## Converts a value that was received from the database, using SELECT
## into a value that is understood by perl.
#sub convert_from_sql
#{
#    my $self = shift;
#
#    my $type = shift;
#    my $type_params = shift;
#    my $sql_value = shift;
#
#    return $types{$type}->base_from_sql($self->{'sql_driver'}, $type_params, $sql_value);
#}
## Returns:
## $plain_value = $types->convert_from_sql(...)
#
#
## Checks a value as it is inputted. Currently the types do not support this
## function.
#sub dynamic_check_value
#{
#    my $self = shift;
#
#    my $type = shift;
#    my $type_params = shift;
#    my $old_value = shift;
#    my $new_value = shift;
#
#    return $types{$type}->base_dynamic_check_value($type_params, $old_value, $new_value);    
#}
## Returns:
## ($status, $updated_value, $error_string) = $types->dynamic_check_value(...);
##
## $status = 0 - input is OK
##       & 0x1 - should be modified to updated value
##       & 0x2 - display error string
##
## $updated_value - value to update in control
## $error_string - error message to display
##
#
## Compares two values from the same data type, and returns a positive number
## if the first is "greater" than the second. A negative one if it's lesser,
## and 0 if both values are equal.
#sub compare_values
#{
#    my $self = shift;
#
#    my $type = shift;
#    my $type_params = shift;
#    my $value1 = shift;
#    my $value2 = shift;
#
#    return $types{$type}->base_compare($type_params, $value1, $value2);
#}
## Returns:
## ($value1 cmp_func $value2)
#
## Quotes an SQL value, like a char or varchar so it can be passed to the SQL
## driver, inside a query. 
#sub quote_sql_value
#{
#    my $self = shift;
#
#    my $value = shift;
#
#	    my $sql_driver = $self->{'sql_driver'};
#
#    if (defined($sql_driver) && ($sql_driver->can("quote_sql_value")))
#    {
#        return $sql_driver->quote_sql_value($value);
#    }
#
#    return ("'" . Arad::Utils::backslash_string($value, "'", "oct") . "'");
#}


1;
