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
use Technion::Seminars::Utils qw(@monthes_names);

use Gamla::TextStream::Out::File;

my $q = CGI->new();

sub check_url
{
    my $url = shift; 
    return (($url =~ /search\/(index.cgi)?/), "search/");    
}

# Make sure our URL ends with a slash.
&normalize_url($q, \&check_url);

print $q->header();

my $title = "Search for Seminars";

my $layout = 
    Technion::Seminars::Layout->new(
        'path' => "search", 
        'title' => $title,
    );

my $o = Gamla::TextStream::Out::File->new(\*STDOUT);

my $draw_page = sub {
    my $o = shift;
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());   
    
    my $selected = " selected=\"selected\" ";

    $year += 1900;

    $o->print("<h1>$title</h1>\n");

    $o->print("<form method=\"post\" action=\"./results.cgi\">\n");

    $o->print("<table>\n");

    for my $which ("start", "end")
    {
        $o->print("<tr>\n");
        
        $o->print("<td><b>" . ucfirst($which) . " Date:</b></td>");

        $o->print("<td align=\"left\"><select name=\"$which" . "_mday\">");

        $o->print(join("\n", map { "<option value=\"$_\" " . (($mday == $_) ? $selected : ""). ">$_</option>" } (1 .. 31) ));

        $o->print("</select></td>\n");

        $o->print("<td align=\"left\"><select name=\"$which" . "_month\">");

        $o->print(join("\n", map { "<option value=\"$_\" " . (($mon+1 == $_) ? $selected : ""). ">" . $monthes_names[$_-1] .  "</option>" } (1 .. 12) ));
        $o->print("</select></td>\n");

        $o->print("<td align=\"left\"><select name=\"$which" . "_year\">\n");

        
        foreach my $y (2002 .. ($year+10))
        {
            if ($y == $year)
            {
                $o->print("<option value=\"none\" $selected>--SELECT YEAR--</option>\n");
            }
            $o->print("<option value=\"$y\">$y</option>\n");
        }
        $o->print("</select></td>\n");

        $o->print("</tr>\n");
    }

    $o->print("<tr>\n");

    $o->print("<td><b>Keywords:</b></td>");

    $o->print("<td colspan=\"4\"><input name=\"keywords\" size=\"50\" /></td>\n");

    $o->print("</tr>\n");

    $o->print("<tr>\n");

    $o->print("<td><b>Lecturer:</b></td>");

    $o->print("<td colspan=\"4\"><input name=\"lecturer\" size=\"20\" /></td>\n");

    $o->print("</tr>\n");

    $o->print("<tr>\n");

    $o->print("<td valign=\"top\"><b>Subjects:</b></td>");

    $o->print("<td colspan=\"4\" valign=\"top\"><select name=\"subjects\" multiple=\"multiple\">");
    
    $o->print("<option value=\"all\" $selected>All</option>\n");

    my $dbh = Technion::Seminars::DBI->new();

    my $sth = $dbh->prepare("SELECT Club_ID, Name FROM clubs ORDER BY Name");

    my $rv = $sth->execute();

    while (my $row = $sth->fetchrow_arrayref())
    {
        my ($club_id, $name) = @$row;
        $o->print("<option value=\"club-$club_id\">" . CGI::escapeHTML("All $name" . "'s Subjects") . "</option>\n");
    }

    $sth = $dbh->prepare("SELECT clubs.Club_ID, clubs.Name, subjects.Subject_ID, subjects.Name FROM clubs, subjects WHERE subjects.Club_ID = clubs.Club_ID ORDER BY clubs.Name, subjects.Name");

    $rv = $sth->execute();

    while (my $row = $sth->fetchrow_arrayref())
    {
        my ($club_id, $club_name, $subj_id, $subj_name) = @$row;

        $o->print("<option value=\"subj-$club_id-$subj_id\">" . CGI::escapeHTML("$club_name :: $subj_name") . "</option>\n");
    }

    $o->print("</select></td>\n");

    $o->print("</tr>\n");

    $o->print("</table>\n");

    $o->print("<p><input type=\"submit\" value=\"Search\" /></p>\n");
    $o->print("</form>\n");
};

$layout->render($o, $draw_page);
