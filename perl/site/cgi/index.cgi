#!/usr/bin/perl -w

# This is meant to suppress these annoying "subroutine redefined" warnings
no warnings "redefine";

use strict;

use CGI;

use Technion::Seminars::Config;
use Technion::Seminars::Layout;
use Technion::Seminars::SlashUrl;

use Gamla::TextStream::Out::File;

my $q = CGI->new();

sub check_url
{
    my $url = shift; 
    my $verdict = ($url =~ /^(index\.cgi(\/)?)?$/) ? 1 : 0;
    return ($verdict, "");
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url);

print $q->header();

my $title = "Seminars Management";

my $layout = 
    Technion::Seminars::Layout->new(
        'path' => "", 
        'title' => $title,
    );

my $o = Gamla::TextStream::Out::File->new(\*STDOUT);

my $draw_page = sub {
    my $o = shift;

    $o->print("<h1>$title</h1>\n");

};

$layout->render($o, $draw_page);
