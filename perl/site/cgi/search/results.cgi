#!/usr/bin/perl -w

# This is meant to suppress these annoying "subroutine redefined" warnings
no warnings "redefine";

use strict;

use CGI;
use DBI;

use POSIX qw(strftime);

use Technion::Seminars::Config;
use Technion::Seminars::Layout;
use Technion::Seminars::SlashUrl;
use Technion::Seminars::DBI;

use Gamla::TextStream::Out::File;

my $q = CGI->new();

my @monthes_names = ("January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December");

sub check_url
{
    my $url = shift; 
    return (($url eq "search/results.cgi"), "search/results.cgi");    
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url);

print $q->header();

my $title = "Search Results";

my $layout = 
    Technion::Seminars::Layout->new(
        'path' => "search", 
        'title' => $title,
    );

my $o = Gamla::TextStream::Out::File->new(\*STDOUT);

my $draw_page = sub {
    my $o = shift;

    my $dbh = Technion::Seminars::DBI->new();

    my $query = "SELECT seminars.Seminar_ID, seminars.Title, seminars.Date FROM seminars ORDER BY seminars.Date";
    
    my $sth = $dbh->prepare($query);
    
    my $rv = $sth->execute();

    $o->print("<h1>Search Results</h1>\n\n");

    $o->print("<ul>\n");
    while (my $row = $sth->fetchrow_arrayref())
    {
        my ($id, $title, $date) = @$row;
        my ($year, $month, $mday) = split(/-/, $date);
        $o->print("<li><a href=\"../seminar/$id/\">$mday-$month-$year - $title</a></li>");
    }
    $o->print("</ul>\n");
};

$layout->render($o, $draw_page);