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

    my $my_url = $q->self_url();

    my $site_url = $config{'http_url'}->{'url'};
    $my_url =~ s!^$site_url!!;
    $my_url =~ m/^([^\?]*)((\?.*)?)$/;
    my $base = $1;
    my $rest = $2;
    
    my ($is_ok, $new_base) = $normalize_url_callback->($base);
    if (! $is_ok)
    {
        print $q->redirect($site_url . $new_base . $rest);
        exit;
    }
    else
    {
        return $base;
    }
}
