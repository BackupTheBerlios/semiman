#!/usr/bin/perl -w

use strict;

use Technion::Seminars::TypeMan;
use Data::Dumper;

my @value_tests =
(
{'t'=>"int32", 'p'=>{}, 'v'=>"5", 'v2' => "6"},
{'t'=>"int32", 'p'=>{}, 'v'=>"abc", 'v2' => "901"},
{'t'=>"int32", 'p'=>{}, 'v'=>"54857239857239487523984723948", 'v2' => "567"},
{'t'=>"varchar", 'p'=>{'len'=>20}, 'v'=>"hello", 'v2' => "your"},
{'t'=>"varchar", 'p'=>{'len'=>10}, 'v'=>"There's more than one way to do it.", 'v2' => "Wonderful"},
{'t'=>"double", 'p'=>{}, 'v'=>'-5.6e8', 'v2' => "-9.1e10"},
{'t'=>"double", 'p'=>{}, 'v'=>"5a89", 'v2' => "590.53"},
{
    't'=>"bounded_int", 
    'p' =>
    {
        'range_spec' => '[]',
        'min' => 9,
        'max' => 500,
    },
    'v' => 89,
    'v2' => 300,
},
{
    't'=>"bounded_int", 
    'p' =>
    {
        'range_spec' => '[]',
        'min' => 9,
        'max' => 500,
    },
    'v' => 5,
    'v2' => 300,
},
{
    't'=>"bounded_int", 
    'p' =>
    {
        'range_spec' => '[]',
        'min' => 9,
        'max' => 500,
    },
    'v' => 1000,
    'v2' => 300,
},
{
    't'=>"bounded_int", 
    'p' =>
    {
        'range_spec' => '(]',
        'min' => 9,
        'max' => 500,
    },
    'v' => 9,
    'v2' => 300,
},
{ 't' => "bool", 'v' => "0", 'v2' => "0" },
);

my $typeman = Technion::Seminars::TypeMan::get_type_man();

my ($a, @check_ret, $compare_ret);

foreach my $elem (@value_tests)
{
    print $a++, ":\n\n";
	@check_ret = $typeman->check_value(@{$elem}{qw(t p v)});
    $compare_ret = $typeman->compare_values(@{$elem}{qw(t p v v2)});
	my $d = Data::Dumper->new([@{$elem}{qw(t p v v2)}, \@check_ret, $compare_ret], [qw(type param value1 value2), "check", "compare"]);
	print $d->Dump();

	print "\n\n";
}
