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
    while (scalar(@_))
    {
        my $arg = shift;
        my $param = shift;
        if ($arg =~ /^-?path$/)
        {
            $path = $param;
        }
        if ($arg =~ /^-?title$/)
        {
            $title = $param;
        }
    }

    $self->{'path'} = [ split(m!/!, $path) ] ;
    $self->{'title'} = $title;

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

    my $browser_compat = $config{'browser_compatibility'};

    my @path = @{$self->{'path'}};
    
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
    $o->print("<table summary=\"Layout Table: The first cell contains a navigation bar, the second the main page\" border=\"0\" width=\"99%\">\n");
    $o->print("<tbody>\n");
    $o->print("<tr>\n");
    $o->print("<td valign=\"top\" class=\"navbar\"" . 
        ($browser_compat ? " width=\"20%\"" : "") .
        ">\n");

    my $put_link = sub {
        my $path = shift;
        my $text = shift;
        $o->print("<a href=\"" . $self->linkto($path) . "\" class=\"navbar\">" .
            $text .
            "</a><br />\n"
        );
    };
    
    $put_link->([], "Main");
    $o->print("<br />\n");
    $put_link->(["day"], "Daily Calendar");
    $put_link->(["week"], "Weekly Calendar");
    $put_link->(["month"], "Monthly Calendar");
    $o->print("<br />\n");
    $put_link->(["search"], "Search");
    $o->print("<br />\n");
    $put_link->(["club"], "The Clubs");
    $o->print("<br />\n");
    $o->print("<a href=\"". ($config{'https_url'}->{'url'} . "admin/") . "\">Admin</a><br />\n");
    $o->print("</td>\n");
    $o->print("<td valign=\"top\" class=\"main\">\n");
    if (!ref($contents))
    {
        $o->print($contents);
        $o->print("\n");
    }
    elsif (ref($contents) eq "CODE")
    {
        $contents->($o);
    }
    $o->print("</td>\n");
    $o->print("</tr>\n");
    $o->print("</tbody>\n");
    $o->print("</table>\n");
    $o->print("</body>\n");
    $o->print("</html>\n");    
}

1;

