#!/usr/bin/perl -w

# This is meant to suppress these annoying "subroutine redefined" warnings
no warnings "redefine";

use strict;

use CGI;

use Technion::Seminars::Config;
use Technion::Seminars::Layout;
use Technion::Seminars::SlashUrl;
use Technion::Seminars::UserMan;

use Gamla::TextStream::Out::File;

my $q = CGI->new();

sub check_url
{
    my $url = shift;

    my $verdict = ($url =~ /^admin(\/index.cgi(\/)?)?$/) ? 1 : 0;
    
    return ($verdict, "admin/");
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url, "https");

my (%cookie);
my ($user, $password, $user_id);
my $admin_level = "readonly";

my $user_man = Technion::Seminars::UserMan->new();

if (%cookie = $q->cookie('seminars_auth'))
{
    ($user, $password) = $user_man->get_user_and_password($q);

    ($admin_level, $user_id) = $user_man->get_admin_level($user, $password);
}

### TO BE REMOVED
$admin_level = "site";

print $q->header();

my $title = "Administrator Login";

my $layout = 
    Technion::Seminars::Layout->new(
        'path' => "admin",
        'title' => $title,
        'admin_level' => $admin_level,
    );

my $o = Gamla::TextStream::Out::File->new(\*STDOUT);

sub draw_page
{
    my $o = shift;    
    
    $o->print("<h1>$title</h1>\n\n");
    
    if ($admin_level eq "readonly")
    {
        $o->print("<form method=\"post\" action=\"login.cgi\">\n");
        $o->print("<p><b>Username:</b><br />\n");
        $o->print("<input type=\"text\" name=\"username\" size=\"10\" /></p>\n");
        $o->print("<p><b>Password:</b><br />\n");
        $o->print("<input type=\"password\" name=\"password\" size=\"10\" /></p>\n");
        $o->print("<p><input type=\"submit\" value=\"Login\" /></p>\n");
        $o->print("</form>\n");
    }
}

$layout->render($o, \&draw_page);
