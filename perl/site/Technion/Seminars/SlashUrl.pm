package Technion::Seminars::SlashUrl;

use strict;

use CGI;

use Exporter;

use vars qw(@EXPORT @ISA);

@EXPORT=qw(normalize_url);
@ISA=qw(Exporter);

use Technion::Seminars::Config;

sub normalize_url
{
    # $q is the CGI query handler.
    my $q = shift;
    # This is a callback to check and normalize the URL
    my $normalize_url_callback = shift;

    # This is the protocol - http or https
    my $protocol = shift || "http";

    # Get the complete URL from the CGI query handle
    my $my_url = $q->self_url();

    # Get the base directory for the site
    my $site_url = 
        (($protocol eq "https") ? 
            $config{'https_url'}->{'url'} : 
            $config{'http_url'}->{'url'}
        );
    # Strip the base directory of the current URL.
    $my_url =~ s!^$site_url!!;
    # Split into two parts:
    # $base - what comes before the question mark
    # $rest - what comes afterwards
    $my_url =~ m/^([^\?]*)((\?.*)?)$/;
    my $base = $1;
    my $rest = $2;
    
    # Call the callback to find out if the URL is OK.
    my ($is_ok, $new_base) = $normalize_url_callback->($base);
    # If it's not - 
    if (! $is_ok)
    {
        # Redirect to the new URL
        print $q->redirect($site_url . $new_base . $rest);
        exit;
    }
    else
    {
        # Return the base directory for reference
        return $base;
    }
}
