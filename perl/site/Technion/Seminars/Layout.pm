# This class manages the layout of the site - its general look and feel.
# 

package Technion::Seminars::Layout;

use strict;

use Technion::Seminars::Config;

# Standard Perl Constructor
sub new
{
    my $class = shift;
    my $self = {};

    bless $self, $class;

    $self->initialize(@_);

    return $self;
}

# I receive only one argument - path
sub initialize
{
    my $self = shift;

    my $path = "";
    my $title = "Technion Seminars";
    my $protocol = "http";
    my $admin_level = "readonly";
    while (scalar(@_))
    {
        my $arg = shift;
        my $param = shift;
        if ($arg =~ /^-?path$/)
        {
            $path = $param;
            next;
        }
        if ($arg =~ /^-?title$/)
        {
            $title = $param;
            next;
        }
        if ($arg =~ /^-?protocol$/)
        {
            $protocol = $param;
            next;
        }
        if ($arg =~ /^-?admin[-_]level$/)
        {
            $admin_level = $param;
            next;
        }
        if ($arg =~ /^-?cgi-query$/)
        {
            my $q = $self->{'cgi-query'} = $param;
            $self->{'printer_friendly_version'} = $q->param("printer_friendly_version");
        }
    }

    $self->{'path'} = [ split(m!/!, $path) ] ;
    $self->{'title'} = $title;
    $self->{'protocol'} = $protocol;
    $self->{'admin_level'} = $admin_level;

    return 0;
}

sub linkto
{
    my $self = shift;

    my $other_path = shift;

    my $end_with_slash = scalar(@_) ? shift(@_) : 1;
    
    my @this_url = @{$self->{'path'}};
    my @other_url = @{$other_path};

    while (
        scalar(@this_url) && 
        scalar(@other_url) && 
        ($this_url[0] eq $other_url[0]))
    {
        shift(@this_url);
        shift(@other_url);
    }
    
    my $ret = "./".join("/", ((map { ".." } @this_url), @other_url));
    if ((scalar(@this_url) + scalar(@other_url) > 0) && $end_with_slash)
    {
        $ret .= "/";
    }

    return $ret;
}

sub render
{
    my $self = shift;

    # This is the output class which we use to output things on the 
    # screen
    my $o = shift;

    my $contents = shift;

    #my $browser_compat = $config{'browser_compatibility'};
    my $browser_compat = 0;

    my @path = @{$self->{'path'}};

    my $admin_level = $self->{'admin_level'};

    my $pfriend = $self->{'printer_friendly_version'};
    
    $o->print("<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n");
    $o->print("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 " . 
        ($browser_compat ? "Transitional" : "Strict") .
        "//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-" . 
        ($browser_compat ? "transitional" : "strict") .
        ".dtd\">\n");
    $o->print("<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en-US\" lang=\"en-US\">\n");
    $o->print("<head>\n");
    $o->print("<title>" . $self->{'title'} . "</title>\n");
    $o->print("<link rel=\"StyleSheet\" href=\"" . $self->linkto(["style.css"], 0) . "\" type=\"text/css\" />\n");
    $o->print("</head>\n");
    $o->print("<body>\n");
    if (! $pfriend)
    {
        $o->print("<table summary=\"Layout Table: The first cell contains a navigation bar, the second the main page\" border=\"0\" width=\"99%\">\n");
        $o->print("<tbody>\n");
        $o->print("<tr>\n");
        $o->print("<td valign=\"top\" class=\"navbar\" style=\"width:20%\">\n");

        $o->print("<ul class=\"navbarmain\">\n");

        my $put_link = sub {
            my $path = shift;
            my $text = shift;
            $o->print("<li><a href=\"" . $self->linkto($path) . "\" class=\"navbar\">" .
                $text .
                "</a></li>\n"
            );
        };

        my $promote = sub {
            $o->print("<li><ul class=\"navbarnested\">\n");
        };

        my $demote = sub {
            $o->print("</ul></li>\n");
        };

        my $separator = sub {
            $o->print("<li><br /></li>\n");
        };
        
        $put_link->([], "Main");
        $separator->();
        $put_link->(["day"], "Daily Calendar");
        $put_link->(["week"], "Weekly Calendar");
        $put_link->(["month"], "Monthly Calendar");
        $separator->();
        $put_link->(["search"], "Search");
        $separator->();
        $put_link->(["club"], "The Clubs");
        $separator->();
        if ($admin_level eq "readonly")
        {
            $o->print("<li><a href=\"". ($config{'https_url'}->{'url'} . "admin/") . "\">Admin</a></li>\n");
        }
        else
        {
            $o->print("</ul>\n<h3 class=\"navbar\">Admin</h3>\n<ul class=\"navbarmain\">\n");
            $separator->();
            $put_link->(["admin", "clubs"], "Clubs");
            if (($path[0] eq "admin") && ($path[1] eq "clubs") && (scalar(@path) >= 3))
            {
                $promote->();
                $put_link->([ @path[0 .. 2] ], $path[2]);
                $demote->();
            }
            if ($admin_level eq "site")
            {
                $put_link->(["admin", "users"], "Users");
            }
            $put_link->(["admin", "logout.cgi"], "Log out");
        }

        $o->print("<li><br /></li>\n");
        $o->print("<li><a href=\"./?printer_friendly_version=1\">Printer Friendly Verions</a></li>\n");
        $o->print("</ul>\n");
        $o->print("</td>\n");
        $o->print("<td valign=\"top\" class=\"main\">\n");
    }
    if (!ref($contents))
    {
        $o->print($contents);
        $o->print("\n");
    }
    elsif (ref($contents) eq "CODE")
    {
        $contents->($o);
    }
    if (! $pfriend)
    {
        $o->print("</td>\n");
        $o->print("</tr>\n");
        $o->print("</tbody>\n");
        $o->print("</table>\n");
    }
    $o->print("</body>\n");
    $o->print("</html>\n");
}

1;

