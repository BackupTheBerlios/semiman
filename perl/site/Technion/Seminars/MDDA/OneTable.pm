#
# This module is responsible for the Meta-Data Database Access routines
# of the seminars package.
#

package Technion::Seminars::MDDA::OneTable;

use strict;

use vars qw(@ISA);

use Gamla::Object;

@ISA=qw(Gamla::Object);

use Technion::Seminars::DBI;
use Technion::Seminars::TypeMan;

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

sub perform_add_operation
{
    my $self = shift;
    # The CGI query handle
    my $q = shift;
    # The output stream
    my $o = shift;
    # The optional OK message
    my $ok_message = shift || "Database was updated succesfully.";

    my $table_spec = $self->{'table_spec'};
    my $table_name = $self->{'table_name'};

    eval {

        # Init a database handle
        my $dbh = Technion::Seminars::DBI->new();

        # Construct a query
        my (@query_fields, @query_values);
        my $type_man = Technion::Seminars::TypeMan::get_type_man();


        foreach my $field (@{$table_spec->{'fields'}})
        {
            # This variable would be assigned the value of the field
            my $value = "";
            # Determine how to input the field
            my $input = $field->{'input'} || { 'type' => "normal", };
                                
            if ($input->{'type'} eq "auto")
            {
                # We generate the value of this field automatically;
                
                # by-value means this field is assigned a constant
                # value
                if ($input->{'method'} eq "by-value")
                {
                    $value = $input->{'value'};
                }
                # get-new-id generates a new id based on what already
                # exists in the database
                elsif ($input->{'method'} eq "get-new-id")
                {
                    # Note: MySQL Specific
                    $value = 0;
                }
            }
            else
            {
                # Retrieve the value from the CGI field
                $value = $q->param($field->{'name'});
                # Check that its type agrees with it
                my ($status, $error_string) = ($type_man->check_value($field->{'type'}, $field->{'type_params'}, $value));
                # If it does not.
                if ($status)
                {
                    # Throw an error

                    # Substitute the field name into the '$F' macro.
                    $error_string =~ s/\$F/$field->{'name'}/ge;
                    
                    die ($field->{'name'} . " could not be accepted: $error_string");
                }

                # Get the input constraints.
                my $input_params_arr = $field->{'input_params'};
                if ($input_params_arr)
                {
                    # Iterate over the input constraints
                    foreach my $input_params ((ref($input_params_arr) eq "ARRAY") ? (@$input_params_arr) : ($input_params_arr))
                    {
                        # Check if this field is required to be unique
                        if ($input_params->{'unique'})
                        {
                            # Query the database for the existence of the same value
                            my $sth = $dbh->prepare("SELECT count(*) FROM $table_name WHERE " . $field->{'name'} . " = " . $dbh->quote($value));
                            my $rv = $sth->execute();
                            my $ary_ref = $sth->fetchrow_arrayref();
                            # If such value exists
                            if ($ary_ref->[0] > 0)
                            {
                                die ($field->{'name'} ." must be unique while a duplicate entry already exists!");
                            }
                        }
                        
                        # This specifies that the input must not
                        # match a regexp.
                        if ($input_params->{'not_match'})
                        {
                            my $pattern = $input_params->{'not_match'};
                            if ($value =~ /$pattern/)
                            {
                                die $input_params->{'comment'};
                            }
                        }

                        # This specifies that the input must match
                        # a regexp.
                        if ($input_params->{'match'})
                        {
                            my $pattern = $input_params->{'match'};
                            if ($value !~ /$pattern/)
                            {
                                die $input_params->{'comment'};
                            }
                        }
                    }
                }
            }

            # Push the field name
            push @query_fields, $field->{'name'};                    

            push @query_values, $value;
        }

        # Sanity checks are over - let's insert the values into the table

        # Construct the query.
        my $sql_insert_query = "INSERT INTO $table_name (" . join(",", @query_fields) . ") VALUES (" . join(",", map { $dbh->quote($_) } @query_values) . ")";

        # Execute it.
        my $sth = $dbh->prepare($sql_insert_query);
        
        my $rv = $sth->execute();

        $o->print("<h1>OK</h1>\n");
        $o->print("<p>$ok_message</p>\n");
    };

    # Handle an exception throw
    if ($@)
    {
        $o->print("<h1>Error in Input!</h1>\n\n");
        $o->print("<p>" . $@ . "</p>");
    }
}


1;

