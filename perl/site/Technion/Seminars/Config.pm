package Technion::Seminars::Config;

use strict;

use Exporter;

use vars qw(%config);

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(%config);

BEGIN {
    %config = 
    (
        'crypt_file' => "/etc/seminars-crypt-file",
        # The URL of the HTTP Read-only Tree
        'http_url' => 
            {
                'url' => "http://localhost/seminars/",
                'host' => "localhost",
                'path' => "seminars",
            },
        # The URL of the HTTPS Admin Tree
        'https_url' =>
            {
                'url' => "https://localhost/seminars/",
                'host' => "localhost",
                'path' => "seminars",
            },
        # Browser Compatibility Flag - make the code less standard
        # and more compatible with common browser bugs.
        'browser_compatibility' => 1,
        'database' =>
            {
                'dsn' => "DBI:mysql:database=test_seminars",
                'user' => "nobody",
                'password' => "",
                'tables' =>
                {
                    'users' =>
                    {
                        'fields' =>
                        [
                            {
                                'name' => "User_ID",
                                'type' => "int32",
                                'input' => { 'type' => "auto", 'method' => "get-new-id", "primary_key" => 1, },
                                'display' => { 'type' => "hidden" },
                            },
                            {
                                'name' => 'Name',
                                'type' => "varchar",
                                'type_params' => { 'len' => 255 },
                            },
                            {
                                'name' => 'Username',
                                'type' => "varchar",
                                'type_params' => { 'len' => 30 },
                                'input_params' => 
                                [
                                    { 
                                        'type' => 'unique',
                                    }, 
                                    { 
                                        'type' => "not_match",
                                        'regex' => '^new$', 
                                        'comment' => "new is a reserved word and cannot be assigned as a username",
                                    },
                                    {
                                        'type' => 'match',
                                        'regex' => '^[a-zA-Z]\w*$' ,  
                                        'comment' => "The username must start with a letter and extend with letters, digits and underscores",
                                    },

                               ],
                               'display' => { 'type' => "constant" },
                            },
                            {
                                'name' => "Super_Admin",
                                'title' => "Super Admin Flag",
                                'type' => "bool",
                                'input' => { 'type' => "auto", 'method' => "by-value", 'value' => 0}
                            },
                            {
                                'name' => "Password",
                                'type' => "varchar",
                                'type_params' => { 'len' => 255 }, 
                                'display' => {'type' => "password" },
                            },
                            {
                                'name' => "Email",
                                'title' => "E-Mail",
                                'type' => "email",
                                'type_params' => { 'len' => 255 },
                            },
                        ],
                        'derived-tables' => [ "permissions" ],
                        'triggers' => 
                        {
                            'add' =>
                            [
                                "INSERT INTO permissions (User_ID, Club_ID, Seminars, Subjects) SELECT \$F{User_ID}, clubs.Club_ID, 0, 0 FROM clubs",
                            ],
                            'delete' =>
                            [
                                "DELETE FROM permissions WHERE User_ID = \$F{User_ID}",
                            ],
                        },
                    },
                    'clubs' =>
                    {
                        'fields' =>
                        [
                            {
                                'name' => "Club_ID",
                                'type' => "int32",
                                'input' => { 'type' => "auto", 'method' => "get-new-id", "primary_key" => 1, },
                                'display' => { 'type' => "hidden" },
                            },
                            {
                                'name' => 'Name',
                                'type' => "varchar",
                                'type_params' => { 'len' => 255 },
                            },
                            {
                                'name' => 'Clubname',
                                'type' => "varchar",
                                'type_params' => { 'len' => 30 },
                                'input_params' => 
                                [
                                    { 
                                        'type' => 'unique',                                        
                                    }, 
                                    { 
                                        'type' => 'not_match',
                                        'regex' => '^new$', 
                                        'comment' => "new is a reserved word and cannot be assigned as a username",
                                    },
                                    {
                                        'type' => "match",
                                        'regex' => '^[a-zA-Z]\w*$',
                                        'comment' => "The username must start with a letter and extend with letters, digits and underscores",
                                    },

                               ],
                               'display' => { 'type' => "constant" },
                            },
                            {
                                'name' => 'Homepage',
                                'type' => "url",
                                'type_params' => { 'len' => 30 },
                            },
                            {
                                'name' => "Description",
                                'type' => "varchar",
                                'type_params' => { 'len' => 64*1024 },
                                'widget_params' => 
                                { 
                                    'type' => "textarea", 
                                    'height' => 10,
                                    'width' => 50,
                                },
                            },
                        ],
                        'derived_tables' => [ 'permissions' ],
                        'triggers' => 
                        {
                            'add' =>
                            [
                                "INSERT INTO permissions (User_ID, Club_ID, Seminars, Subjects) SELECT users.User_ID, \$F{Club_ID}, 0, 0 FROM users",
                            ],
                            'delete' =>
                            [
                                "DELETE FROM permissions WHERE Club_ID = \$F{Club_ID}",
                            ],
                        },                        
                    },
                    'permissions' =>
                    {
                        'fields' =>
                        [
                            {
                                'name' => "User_ID",
                                'type' => "int32",
                                'input' => 
                                { 
                                    'primary_key' => 1, 
                                    'type' => "auto", 
                                    'method' => "base-table",
                                },
                                'base' =>
                                {
                                    'table' => "users",
                                },
                            },
                            {
                                'name' => "Club_ID",
                                'type' => "int32",
                                'input' => 
                                { 
                                    'primary_key' => 1, 
                                    'type' => "auto", 
                                    'method' => "base-table",
                                },
                                'base' =>
                                {
                                    'table' => "clubs",
                                },
                            },
                            {
                                'name' => "Seminars",
                                'title' => "Edit Seminars",
                                'type' => "bool",
                                'input' => { 'type' => "auto", 'method' => "by-value", 'value' => 0},
                            },
                            {
                                'name' => "Subjects",
                                'title' => "Edit Subjects",
                                'type' => "bool",
                                'input' => { 'type' => "auto", 'method' => "by-value", 'value' => 0},
                            },
                        ],
                    },
                    'seminars' =>
                    {
                        'fields' =>
                        [
                            {
                                'name' => "Seminar_ID",
                                'type' => "int32",
                                'input' => 
                                { 
                                    'type' => "auto", 
                                    'method' => "get-new-id", 
                                    "primary_key" => 1
                                },
                                'display' => { 'type' => "hidden" },
                            },
                            {
                                'name' => 'Subject_ID',
                                'title' => "Subject ID",
                                'type' => "int32",
                                'input' => 
                                {
                                    'type' => "dep-get",
                                    'method' => "choose-from-query",
                                    'query' => "SELECT Subject_ID FROM subjects WHERE Club_ID = \$PF{Club_ID}",
                                },
                                'input_params' =>
                                [
                                    {
                                        'type' => "query-pass",
                                        'query' => "SELECT count(*) FROM subjects WHERE Club_ID = \$PF{Club_ID} AND Subject_ID = \$VALUE{}",
                                        'comment' => "The subject must belong to the club",
                                    },
                                ],
                                'display' => { 'type' => "constant" },
                                'widget_params' =>
                                {
                                    'type' => "combobox",
                                },
                            },
                            {
                                'name' => "Title",
                                'type' => "varchar",
                                'type_params' => { 'len' => 255 },
                            },
                            {
                                'name' => "Description",
                                'type' => "varchar",
                                'type_params' => { 'len' => 64*1024 },
                                'widget_params' => 
                                { 
                                    'type' => "textarea", 
                                    'height' => 10,
                                    'width' => 50,
                                },                                
                            },
                            {
                                'name' => "Date",
                                'type' => "date",
                            },
                            {
                                'name' => "Time",
                                'type' => "time",
                            },
                            {
                                'name' => "Room",
                                'type' => "varchar",
                                'type_params' => { 'len' => 255 },
                            },
                            {
                                'name' => "Lecturer",
                                'type' => "varchar",
                                'type_params' => { 'len' => 255 },
                            },
                            {
                                'name' => "ContactInfo",
                                'title' => "Contact Info",
                                'type' => "varchar",
                                'type_params' => {'len' => 64*1024 },
                                'widget_params' => 
                                { 
                                    'type' => "textarea", 
                                    'height' => 10,
                                    'width' => 50,
                                },
                            },
                        ],
                        'triggers' =>
                        {
                            'add' =>
                            [
                                "INSERT INTO associations (Subject_ID, Seminar_ID) VALUES (\$F{Subject_ID}, \$F{Seminar_ID})",
                            ],
                        },
                        'parent' => "clubs",
                    },
                },
            },
    );
};

1;
