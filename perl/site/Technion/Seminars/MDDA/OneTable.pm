# This module is responsible for the Meta-Data Database Access routines
# of the seminars package.
#

package Technion::Seminars::MDDA::OneTable;

use strict;

use vars qw(@ISA);

use Gamla::Object;

@ISA=qw(Gamla::Object);

use Technion::Seminars::Config;
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

    # Output a form with which one can add a new record.

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

sub render_edit_form
{
    my $self = shift;

    my $o = shift;

    my $key_field = shift;
    my $username = shift;

    my %options = (@_);

    my $ok_title = $options{'ok-title'} || "Editing \$V";

    my $error_title = $options{'error-title'} || "Unknown \$F - \$V";

    my $user_title = $options{'field-title'} || $username;

    foreach my $title ($ok_title, $error_title)
    {
        $title =~ s/\$V/$user_title/g;
        $title =~ s/\$F/$key_field/g;
    }
    

    my $table_name = $self->{'table_name'};
    my $table_spec = $self->{'table_spec'};

    my $dbh = Technion::Seminars::DBI->new();
    my $sth = $dbh->prepare("SELECT * FROM $table_name WHERE $key_field = '$username'");
    my $rv = $sth->execute();
    my $data;
    
    if ($data = $sth->fetchrow_hashref())
    {
        # We have a valid username
        $o->print("<h1>$ok_title</h1>\n\n");

        $o->print("<form method=\"post\" action=\"edit.cgi\">\n");
        foreach my $field (@{$table_spec->{'fields'}})
        {
            my $display_type = $field->{'display'}->{'type'};
            my $field_name = $field->{'name'};
            if ($display_type eq "hidden")
            {
                $o->print("<input type=\"hidden\" name=\"" . $field->{'name'} . "\" value=\"" . CGI::escapeHTML($data->{$field_name}) . "\" />\n");
            }
            elsif ($display_type eq "constant")
            {
                $o->print("<b>$field_name</b>: " . 
                    CGI::escapeHTML($data->{$field_name}) . 
                    "<br />\n");
            }
            else
            {
                $o->print("<b>$field_name</b>: " .
                    "<input name=\"$field_name\" " . 
                    (($display_type eq "password") ? "type=\"password\"" : "") .
                    " value=\"" . 
                    CGI::escapeHTML($data->{$field_name}) . 
                    "\" /><br />\n");
            }
        }
        $o->print("\n\n<input type=\"submit\" name=\"action\" value=\"Update\" />\n");
        $o->print("\n\n<input type=\"submit\" name=\"action\" value=\"Delete\" />\n");
        $o->print("\n\n</form>\n");
    }
    else
    {
        $o->print("<h1>$error_title</h1>");
    }
    

    return 0;
}

sub perform_edit_operation
{
    my $self = shift;

    my $q = shift;

    my $o = shift;

    my $id_field = shift;

    my $dependant_tables = shift || [];

    my %options = @_;

    my $id_field_title = $options{'id-field-title'} || $id_field;

    my $record_title = $options{'record-title'} || $id_field;

    my $table_name = $self->{'table_name'};

    my $table_spec = $self->{'table_spec'};


    my $dbh = Technion::Seminars::DBI->new();
    my $user_id = $q->param("$id_field");
    my $sth = $dbh->prepare("SELECT count(*) FROM $table_name WHERE $id_field = $user_id");
    my $rv = $sth->execute();

    my $data;

    $data = $sth->fetchrow_arrayref();

    if ($data->[0] == "0")
    {
        $o->print("<h1>Error - $id_field_title not found!</h1>\n\n<p>The $id_field_title $user_id was not found on this server.</p>\n\n");
    }
    if ($q->param("action") eq "Delete")
    {
        $sth = $dbh->prepare("DELETE FROM $table_name WHERE $id_field = $user_id");
        $rv = $sth->execute();
        foreach my $table (@$dependant_tables)
        {
            my $table_id_field = exists($table->{'id'}) || $id_field;;
            $dbh->prepare("DELETE FROM " . $table->{'name'} ." WHERE $table_id_field = $user_id");
            $rv = $sth->execute();
        }

        $o->print("<h1>OK</h1>\n\n<p>the $record_title was deleted</p>\n");
    }
    else
    {
        # Updating the user fields

        my (@query_fields, @query_values);
        my $type_man = Technion::Seminars::TypeMan::get_type_man();
        
        foreach my $field (@{$table_spec->{'fields'}})
        {
            # This variable would be assigned the value of the field
            my $value = "";
            # Determine how to input the field
            my $input = $field->{'input'} || { 'type' => "normal", };
             
            if ($input->{'primary_key'})
            {
                next;
            }
            if ($field->{'display'}->{'type'} eq "constant")
            {
                next;
            }
            
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

        my $edit_query = "UPDATE $table_name SET " . join(",", map { $query_fields[$_] . "=" . $dbh->quote($query_values[$_]) } (0 .. $#query_fields)) . " WHERE $id_field = $user_id";

        $sth = $dbh->prepare($edit_query);
        my $rv = $sth->execute();
        
        $o->print("<h1>OK</h1>\n\n<p>the $record_title was updated</p>\n");
    }
}

1;

