#!/usr/bin/perl -w

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

    my $verdict = ($url =~ /^admin(\/index.cgi)?$/) ? 1 : 0;
    
    return ($verdict, "admin/");
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url, "https");

my $user = CGI::remote_user();

print $q->header();

my $title = "Administrator Login";

my $layout = 
    Technion::Seminars::Layout->new(
        'path' => "admin",
        'title' => $title,
        'admin_level' => (($user eq "shlomif") ? "site" : "club"),
    );

my $o = Gamla::TextStream::Out::File->new(\*STDOUT);

sub draw_page
{
    my $o = shift;

    $o->print("<h1>$title</h1>\n");

    $o->print("This would be a search form.");
}


$layout->render($o, \&draw_page);
