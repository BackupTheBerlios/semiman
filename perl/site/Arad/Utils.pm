# Arad::Utils - various utility functions that are used in Arad.
#
# Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 1999
# This code is under the public domain. (It's uncopyrighted)

package Arad::Utils;

use strict;


# $ret = is_in($item, \@array);
# Returns whether $item is in @array.

sub is_in_eq
{
    my $item = shift;
    my $array = shift;
    
    return (scalar(grep {$_ eq $item} @{$array}) > 0);
}

sub is_in_cmp
{
    my $item = shift;
    my $array = shift;
    
    return (scalar(grep {$_ == $item} @{$array}) > 0);    
}

sub is_in_generic
{
    my $item = shift;
    my $array = shift;
    
    my $cmp_func = shift;
    
    return (scalar(grep {$cmp_func->($item,$_)==0} @{$array}) > 0);
}

sub to_arrayref
{
    my $value = shift;
    
    if (ref($value) eq "ARRAY")
    {
    	return $value;
    }
    else
    {
    	return [ $value];
    }
}

if (0)
{
sub is_in
{
    my $item = shift;
    my $array = shift;

    my ($a, $len);

    $len = scalar(@{$array});

    for($a=0;$a<$len;$a++)
    {
        if ($item eq ($array->[$a]))
        {
            return 1;
        }
    }
    return 0;
}
}

# $ret = backslash_string($string, $characters, $flags);
# Returns the string with special characters converted to backslash+characters
# sequence.
#
# $characters is a string containing charcters to be backslashed too.
#
# $flags is a comma separated string containing options. The currently supported
# options are:
# -oct - use \OOO instead \xHH.
sub backslash_string
{
    my $value = shift;

    my $characters = shift;
    
    my $oct;

    my $opt;
    
    while ($opt = shift)
    {
        if ($opt eq '-oct')
        {
            $oct = !!shift;
        }
    }

    my (@chars);

    @chars = split(//, $characters);

    my ($slashed, $len, $a, $chr, $ascii);

    $slashed = '';
    $len = length($value);

    for($a=0;$a<$len;$a++)
    {
        $chr = substr($value,$a,1);
        $ascii = ord($chr);

        if (($chr eq "\\") || is_in($chr, \@chars))
        {
            $slashed .= "\\" . $chr;
        }
        elsif ($chr eq "\n")
        {
            $slashed .= "\\n";
        }
        elsif ($chr eq "\t")
        {
            $slashed .= "\\t";
        }
        elsif ($chr eq "\r")
        {
            $slashed .= "\\r";
        }
        elsif (($ascii < 32) || ($ascii >= 127))
        {
            if ($oct)
            {
                $slashed .= sprintf("\\%.3o", $ascii);
            }
            else
            {
                $slashed .= sprintf("\\x%.2X", $ascii);
            }
        }
        else
        {
            $slashed .= $chr;
        }
    }

    return $slashed;
}

# $ret = unbackslash_string($backslashed_string);
#
# Converts all backslash sequences in a string into normal characters. Returns
# The converted string.

sub unbackslash_string
{
    my $slashed = shift;

    my ($a, $chr, $len, $string);

    $len = length($slashed);
    $string = '';

    for($a=0;$a<$len;$a++)
    {
        $chr = substr($slashed, $a, 1);
        
        if ($chr eq "\\")
        {
            $a++;
            $chr = substr($slashed, $a, 1);
            if ($chr eq "n")
            {
                $string .= "\n";
            }
            elsif ($chr eq "t")
            {
                $string .= "\t";
            }
            elsif ($chr eq "r")
            {
                $string .= "\r";
            }
            elsif ($chr eq "b")
            {
                $string .= "\b";
            }
            elsif ($chr eq "a")
            {
                $string .= "\a";
            }
            elsif ($chr eq "e")
            {
                $string .= "\e";
            }
            elsif ($chr eq "b")
            {
                $string .= "\b";
            }
            elsif ($chr eq "x")
            {
                my $hex_num = substr($slashed, $a+1, 2);
                $a += 2;
                $string .= chr(hex($hex_num));
            }
            elsif ($chr =~ /[0-7]/)
            {
                my $oct_num = $chr . substr($slashed, $a+1, 2);
                $a += 2;
                $string .= chr(oct($oct_num));
            }
            else
            {
                $string .= $chr;
            }            
        }
        else
        {
            $string .= $chr
        }
    }

    return $string;    
}

1;
