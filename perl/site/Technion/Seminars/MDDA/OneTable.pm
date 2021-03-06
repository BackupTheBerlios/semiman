# This module is responsible for the Meta-Data Database Access routines
# of the seminars package.
#

package Technion::Seminars::MDDA::OneTable;

use strict;

use vars qw(@ISA);

use Gamla::Object;

@ISA=qw(Gamla::Object);

use CGI;

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
    $self->{'parent_fields'} = {};

    if (scalar(@_))
    {
        my $name = shift;
        my $value = shift;
        if ($name eq "parent-field")
        {
            $self->{'parent_fields'}->{$value->{'name'}} = $value->{'value'};
        }
    }

    return 0;
}

sub check_input_params
{
    my $self = shift;
    my $field = shift;
    my $value = shift;

    my $dbh = shift;
    my $type_man = shift;

    my $table_name = $self->{'table_name'};

    # Get the input constraints.
    my $input_params_arr = $field->{'input_params'};
    
    if ($input_params_arr)
    {
        # Iterate over the input constraints
        foreach my $input_params ((ref($input_params_arr) eq "ARRAY") ? (@$input_params_arr) : ($input_params_arr))
        {
            my $type = $input_params->{'type'};
            # Check if this field is required to be unique
            if ($type eq "unique")
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
            elsif ($type eq "not_match")
            {
                my $pattern = $input_params->{'regex'};
                if ($value =~ /$pattern/)
                {
                    die $input_params->{'comment'};
                }
            }
            # This specifies that the input must match
            # a regexp.
            elsif ($type eq "match")
            {
                my $pattern = $input_params->{'regex'};
                if ($value !~ /$pattern/)
                {
                    die $input_params->{'comment'};
                }
            }
            elsif ($type eq "query-pass")
            {
                my $query = $input_params->{'query'};
                $query =~ s/\$PF{(\w+)}/$self->{'parent_fields'}->{$1}/ge;
                $query =~ s/\$VALUE{}/$value/;
                my $sth = $dbh->prepare($query);
                my $rv = $sth->execute();

                my $row = $sth->fetchrow_arrayref();
                if ($row->[0])
                {
                    # OK
                }
                else
                {
                    die $input_params->{'comment'};
                }
            }
            elsif ($type eq "compare")
            {
                my $compare_type = $input_params->{'compare_type'};
                my $compare_to = $input_params->{'compare_to'};
                my $compare_value;
                if ($compare_to->{'type'} eq "function")
                {
                    if ($compare_to->{'function'} eq "get-current-date")
                    {
                        my ($sec,$min,$hour,$mday,$mon,
                            $year,$wday,$yday,$isdst) = localtime(time());
                        $year += 1900;
                        
                        $compare_value = sprintf("%4i-%2i-%2i", $year, $mon, $mday);
                    }
                    else
                    {
                        die "Unknown function!\n";
                    }
                }
                else
                {
                    die "Unknown compare_to type!";
                }

                my $verdict = 
                    $type_man->compare_values(
                        $field->{'type'},
                        $field->{'type_params'},
                        $value,
                        $compare_value
                    );

                if ($compare_type eq ">=")
                {
                    if ($verdict < 0)
                    {
                        die $input_params->{'comment'};
                    }
                }
                else
                {
                    die "Unknown compare type $compare_type!";
                }
            }
        }
    }
    
    return 0;
}

sub check_record_wide_input_params
{
    my $self = shift;
    my $dbh = shift;
    my $type_man = shift;
    my $query_fields = shift;
    my $query_values = shift;

    my $table_spec = $self->{'table_spec'};

    my %field_indexes;
    @field_indexes{@$query_fields} = (0 .. (scalar(@$query_fields)-1));

    if (!exists($table_spec->{'input_params'}))
    {
        return 0;
    }

    my $constraint;

    my $eval_operand = sub {
        my $operand = shift;

        if ($operand->{'type'} eq "field")
        {
            my $name = $operand->{'name'};
            my $index = $field_indexes{$name};
            return ($table_spec->{'fields'}->[$index]->{'type'},
                $table_spec->{'fields'}->[$index]->{'type_params'},
                $query_values->[$index]);
        }
        else
        {
            die "Unknown operand type" . $operand->{'type'};
        }
    };

    foreach $constraint (@{$table_spec->{'input_params'}})
    {
        if ($constraint->{'type'} eq "compare")
        {
            my @left = $eval_operand->($constraint->{'left'});
            my @right = $eval_operand->($constraint->{'right'});
            my $verdict = 
                $type_man->compare_values(
                    $left[0],
                    $left[1],
                    $left[2],
                    $right[2]
                );

            if ($verdict > 0)
            {
                # Do nothing
            }
            else
            {
                die $constraint->{'comment'};
            }                
        }
        else
        {
            die "Unknown constraint type!\n";
        }
    }

    return 0;
}

sub render_add_form
{
    my $self = shift;

    my $o = shift;

    my $table_spec = $self->{'table_spec'};

    # Output a form with which one can add a new record.

    $o->print("<form method=\"post\" action=\"add.cgi\">\n");
    $o->print("<table>\n");
    # Loop over all the fields and output an edit box for each 
    # relevant one.
    foreach my $field (@{$table_spec->{'fields'}})
    {
        $o->print("<tr>\n");
        # If it's an auto field then it is not filled by the user.
        my $input = $field->{'input'} || {};
        my $input_type = $input->{'type'} || "";
        if ($input_type eq "auto")
        {
            $o->print("<td colspan=\"2\"></td>\n");
            next;
        }
        
        my $widget_params = $field->{'widget_params'};
        my $widget_type = $widget_params->{'type'} || "";

        my $heading = "<b>" .
                (exists($field->{'title'}) ? 
                    $field->{'title'} : 
                    $field->{'name'}
                ) . 
                "</b>:";
        
        if ($widget_type eq "textarea")
        {
            $o->print("<td colspan=\"2\">$heading</td></tr><tr><td colspan=\"2\">\n" .
                "<textarea name=\"" . $field->{'name'} . "\" rows=\"" . $widget_params->{'height'} .
                "\" cols=\"" . $widget_params->{'width'} . "\">\n" .
                "</textarea></td>\n\n"
            );
        }
        elsif ($widget_type eq "combobox")
        {
            $o->print("<td>$heading</td><td><select name=\"" . $field->{'name'} . "\">\n");
            if ($input_type eq "dep-get")
            {
                if ($input->{'method'} eq "choose-from-query")
                {
                    my $query = $input->{'query'};
                    $query =~ s/\$PF{(\w+)}/$self->{'parent_fields'}->{$1}/ge;
                    my $dbh = Technion::Seminars::DBI->new();
                    my $sth = $dbh->prepare($query);
                    my $rv = $sth->execute();
                    while (my $row = $sth->fetchrow_arrayref())
                    {
                        $o->print("<option value=\"" . CGI::escapeHTML($row->[0]) . "\">" . CGI::escapeHTML($row->[1]) . "</option>\n");
                    }
                    $o->print("\n</select>\n</td>\n");
                }
                else
                {
                    die "Don't know what to do";
                }
            }
            else
            {
                die "Don't know what to do";
            }
        }       
        else
        {
            my $field_display_type = exists($field->{'display'}->{'type'}) ?
                $field->{'display'}->{'type'} : "";
                
            $o->print("<td>$heading</td><td>" . 
                "<input type=\"" .
                (($field_display_type eq "password") ? 
                    "password" : 
                    "text"
                ) . 
                "\" name=\"" . 
                $field->{'name'} . 
                "\" /></td>\n"
                );
        }
    }
    # I looove perl...
    continue
    {
        $o->print("</tr>\n");
    }
    $o->print("\n\n<tr><td colspan=\"2\"><input type=\"submit\" value=\"Add\" /></td>\n</tr>\n");
    $o->print("</table>\n");
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
        
        my $field_idx = 0;

        my $id_idx = -1;

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
                    $id_idx = $field_idx;
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

                my $ret = $self->check_input_params($field, $value, $dbh, $type_man);
            }

            # Push the field name
            push @query_fields, $field->{'name'};

            push @query_values, $value;

            $field_idx++;
        }

        my $ret = $self->check_record_wide_input_params($dbh, $type_man, \@query_fields, \@query_values);

        # Sanity checks are over - let's insert the values into the table

        # Construct the query.
        my $sql_insert_query = "INSERT INTO $table_name (" . join(",", @query_fields) . ") VALUES (" . join(",", map { $dbh->quote($_) } @query_values) . ")";

        # Execute it.
        my $sth = $dbh->prepare($sql_insert_query);
        
        my $rv = $sth->execute();

        if ($id_idx >= 0)
        {
            $query_values[$id_idx] = $sth->{'mysql_insertid'};
        }

        my $triggers = exists($table_spec->{'triggers'}->{'add'}) ? $table_spec->{'triggers'}->{'add'} : [];

        my %field_values;
        @field_values{@query_fields} = @query_values;

        foreach my $trig (@$triggers)
        {
            my $query = $trig;
            $query =~ s/\$F\{(\w+)\}/$field_values{$1}/ge;
            print STDERR "\$query=\"$query\"\n";
            my $sth = $dbh->prepare($query);
            
            my $rv = $sth->execute();
        }

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

    my $cancel_delete = $options{'no-delete-button'} || 0;

    my $script_url = $options{'script-url'} || "edit.cgi";

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
        if ($ok_title ne "none")
        {
            $o->print("<h1>$ok_title</h1>\n\n");
        }
        # We have a valid username

        $o->print("<form method=\"post\" action=\"$script_url\">\n");
        $o->print("<table>\n");
        foreach my $field (@{$table_spec->{'fields'}})
        {
            $o->print("<tr>\n");
            my $display_type = $field->{'display'}->{'type'} || "";
            my $field_name = $field->{'name'};
            my $field_title = exists($field->{'title'}) ? $field->{'title'} : $field_name;
            if ($display_type eq "hidden")
            {
                $o->print("<td><input type=\"hidden\" name=\"" . $field->{'name'} . "\" value=\"" . CGI::escapeHTML($data->{$field_name}) . "\" /></td>\n");
            }
            elsif ($display_type eq "constant")
            {
                $o->print("<td><b>$field_title</b>:</td><td>" . 
                    CGI::escapeHTML($data->{$field_name}) . 
                    "</td>");
            }
            else
            {
                my $widget_params = $field->{'widget_params'};
                my $widget_type = $widget_params->{'type'} || "";

                my $heading = "<b>$field_title</b>: ";

                if ($widget_type eq "textarea")
                {
                    $o->print("<td colspan=\"2\">$heading</td></tr><tr><td colspan=\"2\">\n" .
                        "<textarea name=\"" . $field->{'name'} . 
                        "\" rows=\"" . $widget_params->{'height'} . 
                        "\" cols=\"" . $widget_params->{'width'} . "\">\n" .
                        CGI::escapeHTML($data->{$field_name}) .
                        "</textarea></td>\n\n"
                    );
                }
                else
                {
                    $o->print("<td>$heading</td><td>" .
                        "<input name=\"$field_name\" " . 
                        (($display_type eq "password") ? "type=\"password\"" : "") .
                        " value=\"" . 
                        CGI::escapeHTML($data->{$field_name}) . 
                        "\" /></td>\n");
                }
            }
            $o->print("</tr>\n");
        }
        $o->print("\n\n<tr><td colspan=\"2\"><input type=\"submit\" name=\"action\" value=\"Update\" />\n");
        if (! $cancel_delete)
        {
            $o->print("\n\n<input type=\"submit\" name=\"action\" value=\"Delete\" />\n");
        }
        $o->print("</td></tr>\n");
        $o->print("</table>\n");
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

    my %options = @_;

    my $id_field_title = $options{'id-field-title'} || $id_field;

    my $record_title = $options{'record-title'} || $id_field;

    my $table_name = $self->{'table_name'};

    my $table_spec = $self->{'table_spec'};

    my $dependent_tables = $options{'dependent-tables'} || [];

    eval {


        my $dbh = Technion::Seminars::DBI->new();
        my $user_id = $q->param("$id_field");
        my $sth = $dbh->prepare("SELECT count(*) FROM $table_name WHERE $id_field = $user_id");
        my $rv = $sth->execute();

        my $data;

        $data = $sth->fetchrow_arrayref();

        if ($data->[0] == "0")
        {
            $o->print("<h1>Error - A $record_title with this $id_field_title not found!</h1>\n\n<p>The $id_field_title $user_id was not found on this server.</p>\n\n");
        }
        if ($q->param("action") eq "Delete")
        {
            $sth = $dbh->prepare("DELETE FROM $table_name WHERE $id_field = $user_id");
            $rv = $sth->execute();
            foreach my $table (@$dependent_tables)
            {
                my ($table_id_field, $table);
                if (ref($table) eq "")
                {
                    $table_id_field = $id_field;
                    $table_name = $table;
                }
                else
                {
                    $table_id_field = exists($table->{'id'}) || $id_field;
                    $table_name = $table->{'name'};
                }
                $dbh->prepare("DELETE FROM $table_name WHERE $table_id_field = $user_id");
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

                    my $ret = $self->check_input_params($field, $value, $dbh, $type_man);
                }

                # Push the field name
                push @query_fields, $field->{'name'};

                push @query_values, $value;
            }

            my $ret = $self->check_record_wide_input_params(
                $dbh, 
                $type_man, 
                \@query_fields, 
                \@query_values
                );

            my $edit_query = "UPDATE $table_name SET " . join(",", map { $query_fields[$_] . "=" . $dbh->quote($query_values[$_]) } (0 .. $#query_fields)) . " WHERE $id_field = $user_id";

            $sth = $dbh->prepare($edit_query);
            my $rv = $sth->execute();
            
            $o->print("<h1>OK</h1>\n\n<p>the $record_title was updated</p>\n");
        }

    };

    # Handle an exception throw
    if ($@)
    {
        $o->print("<h1>Error in Input!</h1>\n\n");
        $o->print("<p>" . $@ . "</p>");
    }


}

1;

