#!/usr/bin/perl -w

# This is meant to suppress these annoying "subroutine redefined" warnings
no warnings "redefine";

use strict;

use CGI;

use Gamla::TextStream::Out::File;

use Technion::Seminars::Config;
use Technion::Seminars::SlashUrl;
use Technion::Seminars::UserMan;
use Technion::Seminars::Layout;

my $q = CGI->new();

sub check_url
{
    my $url = shift;

    my $verdict = ($url =~ /^admin\/logout.cgi$/) ? 1 : 0;
    
    return ($verdict, "admin/logout.cgi");
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url, "https");

    my $cookie = 
        $q->cookie(
            -name => "seminars_auth",
            -value => { 'user' => "", 'password' => "" },
            -path => ( $config{'https_url'}->{'path'} . "/admin/" ),
            -domain => $config{'https_url'}->{'host'},
            -expires => "+1s",
            -secure => 1,
            );
    print $q->header(-cookie => $cookie);
    
my $title = "You have Logged out";

my $layout = 
    Technion::Seminars::Layout->new(
        'path' => "admin",
        'title' => $title,
        'admin_level' => "readonly",
    );

my $o = Gamla::TextStream::Out::File->new(\*STDOUT);

sub draw_page
{
    my $o = shift;    
    
    $o->print("<h1>You have Logged out</h1>\n");
}

$layout->render($o, \&draw_page);
