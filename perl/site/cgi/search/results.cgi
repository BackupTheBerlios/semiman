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

    my $where_clause = "";
    my $groupby_clause = " GROUP BY seminars.Seminar_ID";

    my @clauses;

    push @clauses, "seminars.Seminar_ID = associations.Seminar_ID";

    my %tables = ("seminars" => 1, "associations" => 1);

    if ($q->param("keywords"))
    {
        my $keywords = $q->param("keywords");
        $keywords = substr($keywords, 0, 500);
        push @clauses, ("MATCH(seminars.Title,seminars.Description) AGAINST (" . $dbh->quote($keywords).")");
    }

    if ($q->param("lecturer"))
    {
        my $lecturer = $q->param("lecturer");
        $lecturer = substr($lecturer, 0, 100);
        push @clauses, ("MATCH(seminars.Lecturer) AGAINST (" . $dbh->quote($lecturer).")");
    }

    if ($q->param("subjects"))
    {
        my @ids = $q->param("subjects");
        if (scalar(@ids) > 500)
        {
            @ids = @ids[0 .. 499];
        }
        my (%clubs);
        foreach my $id (@ids)
        {
            if ($id eq "all")
            {
                goto SKIP_SUBJECTS_PARAM;
            }
            elsif ($id =~ /^club-(\d{1,9})$/)
            {
                $clubs{$1}->{'all'} = 1;
            }
            elsif ($id =~ /^subj-(\d{1,9})-(\d{1,9})$/)
            {
                $clubs{$1}->{'subj'}->{$2} = 1;
            }
            else
            {
                # Do Nothing - invalid ID
            }
        }
        # Filter out the clubs who were marked entirely
        # and the subject IDs whose clubs were not marked entirely
        my @club_ids = (grep { exists($clubs{$_}->{'all'}) } keys(%clubs));
        my @subj_ids = 
            (map 
                { 
                    (exists($clubs{$_}->{'all'})) ? 
                        () : 
                        keys(%{$clubs{$_}->{'subj'}}) 
                } 
                keys(%clubs)
            );

        my $is_club_ids = (scalar(@club_ids) > 0);
        my $is_subj_ids = (scalar(@subj_ids) > 0);

        if ($is_club_ids || $is_subj_ids)
        {
            @tables{qw(clubs associations subjects)} = (1,1,1);

            my $my_clause = "associations.Seminar_ID = seminars.Seminar_ID AND ";
            if ($is_club_ids && $is_subj_ids)
            {
                $my_clause .= "(associations.Subject_ID IN (" . join(",", @subj_ids) . ") OR (associations.Subject_ID = subjects.Subject_ID AND subjects.Club_ID IN (" . join(",", @club_ids) .")))";
            }
            elsif ($is_club_ids)
            {
                $my_clause .= "(associations.Subject_ID = subjects.Subject_ID AND subjects.Club_ID IN (" . join(",", @club_ids) ."))";
            }
            else
            {
                $my_clause .= "(associations.Subject_ID IN (" . join(",", @subj_ids). "))";
            }

            push @clauses, $my_clause;            
        }
        
        SKIP_SUBJECTS_PARAM:
    }

    my $get_date = sub {
        my $prefix = shift;

        my $year = $q->param($prefix . "_year");
        my $month = $q->param($prefix . "_month");
        my $mday = $q->param($prefix . "_mday");
        
        $year = substr($year, 0, 4) + 0;
        $month = substr($month, 0, 2) + 0;
        $mday = substr($mday, 0, 2) + 0;
        
        return sprintf("%.4d-%.2d-%.2d", $year, $month, $mday);
    };
    
    my $start_year = $q->param("start_year");
    if ($start_year && ($start_year ne "none"))
    {
        my $start_date = $get_date->("start");
        push @clauses, "seminars.Date >= " . $dbh->quote($start_date);
    }

    my $end_year = $q->param("end_year");
    if ($end_year && ($end_year ne "none"))
    {
        my $end_date = $get_date->("end");
        push @clauses, "seminars.Date <= " . $dbh->quote($end_date);
    }
    

    if (scalar(@clauses))
    {
        $where_clause = "WHERE " . join(" AND ", (map { "($_)" } @clauses));
    }

    my $query = "SELECT seminars.Seminar_ID, seminars.Title, seminars.Date FROM " . join(",", keys(%tables)) . " $where_clause $groupby_clause ORDER BY seminars.Date";

    print STDERR "\$query=$query\n";
    
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
