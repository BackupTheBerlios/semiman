package Technion::Seminars::SlashUrl;

use strict;

use CGI;

use Exporter;

use vars qw(@EXPORT @ISA);

@EXPORT=qw(slash_url);
@ISA=qw(Exporter);

sub slash_url
{
    my $q = shift;
    my $myself = $q->self_url();

    $myself =~ m/^([^\?]*)((\?.*)?)$/;

    my $base = $1;
    my $rest = $2;
    if ($base !~ m/\/$/)
    {    
        print $q->redirect($base . "/" . $rest);
        exit;
    }
}
