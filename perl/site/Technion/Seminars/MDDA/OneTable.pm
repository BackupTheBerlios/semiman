#
# This module is responsible for the Meta-Data Database Access routines
# of the seminars package.
#

package Technion::Seminars::MDDA::OneTable;

use strict;

use vars qw(@ISA);

use Gamla::Object;

@ISA=qw(Gamla::Object);

sub initialize
{
    my $self = shift;

    my $table_name = shift;
    my $table_spec = shift;

    $self->{'table_name'} = $table_name;
    $self->{'table_spec'} = $table_spec;

    return 0;
}

sub render_add_form
{
    my $self = shift;

    my $o = shift;

    my $table_spec = $self->{'table_spec'};

    # Output a form with which one can add a new user.

    $o->print("<h1>Add a New User</h1>\n\n");

    $o->print("<form method=\"post\" action=\"add.cgi\">\n");
    # Loop over all the fields and output an edit box for each 
    # relevant one.
    foreach my $field (@{$table_spec->{'fields'}})
    {
        # If it's an auto field than it is not filled by the user.
        if ($field->{'input'}->{'type'} eq "auto")
        {
            next;
        }
        $o->print("<b>" .
            (exists($field->{'title'}) ? 
                $field->{'title'} : 
                $field->{'name'}
            ) . 
            "</b>: <input type=\"" . 
            (($field->{'display'}->{'type'} eq "password") ? 
                "password" : 
                "text"
            ) . 
            "\" name=\"" . 
            $field->{'name'} . 
            "\" /><br />\n"
            );
    }
    $o->print("\n\n<input type=\"submit\" value=\"Add\" />\n\n");
    $o->print("</form>\n");

}

1;

