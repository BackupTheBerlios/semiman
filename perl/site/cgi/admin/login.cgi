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

    my $verdict = ($url =~ /^admin\/login.cgi$/) ? 1 : 0;
    
    return ($verdict, "admin/login.cgi");
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url, "https");

my ($user, $password);

$user = $q->param('username');
$password = $q->param('password');

my $user_man = Technion::Seminars::UserMan->new();

my $admin_level = $user_man->get_admin_level($user, $password);

my $failed_login = 0;

open O, ">>/tmp/login.cgi-dump.txt";
print O "\$admin_level=$admin_level\n";
close(O);

if ($admin_level eq "readonly")
{
    $failed_login = 1;
    print $q->header();
}
else
{
    my $cookie = 
        $q->cookie(
            -name => "seminars_auth",
            -value => { 'user' => $user, 'password' => $user_man->encrypt($password) },
            -path => ( $config{'https_url'}->{'path'} . "/admin/" ),
            -domain => $config{'https_url'}->{'host'},
            -expires => "+12h",
            -secure => 1,
            );
    print $q->header(-cookie => $cookie);
    
    print ("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" . 
        "<html>\n<head>\n<title>Redirecting to Site</title>\n<meta http-equiv=\"REFRESH\" content=\"0; URL=./\" />\n</head>\n<body>\n</body>\n</html>\n");
    exit(0);
}

my $title = "Login Failed";

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
    
    $o->print("<h1>Failed Login</h1>\n\n");
    $o->print("<p>You failed to log in into the site. Please try again.\n</p>");
}

$layout->render($o, \&draw_page);
