package Arad::Types::Abstract::Bounded;

use strict;

my $min_param = 'min';
my $max_param = 'max';
my $range_spec_param = 'range_spec';

sub check_value
{
    my $typeman = shift;
    my $type_spec = shift;
    my $type_params = shift;
    my $value = shift;

    my $min = exists($type_params->{$min_param})?$type_params->{$min_param}:0;
    my $max = exists($type_params->{$max_param})?$type_params->{$max_param}:0;

    my $range_spec = $type_params->{$range_spec_param};

    my $above_min = $typeman->compare_values(
        $type_spec, 
        $type_params, 
        $value,
        $min);

    my $below_max = $typeman->compare_values(
        $type_spec,
        $type_params,
        $value,
        $max);

    if (($range_spec =~ /[\(\[]/) && ($above_min < 0))
    {
        return (1, "\$F is below " . $min);
    }
    elsif (($range_spec =~ /\(/) && ($above_min <= 0))
    {
        return (1, "\$F is not greater than " . $min);
    }
    elsif (($range_spec =~ /[\]\)]/) && ($below_max > 0))
    {
        return (1, "\$F is above " . $max);
    }
    elsif (($range_spec =~ /\)/) && ($below_max >= 0))
    {
        return (1, "\$F is not lesser than " . $max);
    }
    else
    {
        return (0, "");
    }
}

sub get_type_params
{
    return ("bounded",
        {
            'check_value' => \&check_value,
        }
        );
}

1;
