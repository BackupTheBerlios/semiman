# MySQL dump 8.16
#
# Host: localhost    Database: test_seminars
#--------------------------------------------------------
# Server version	3.23.47

#
# Table structure for table 'associations'
#

CREATE TABLE associations (
  Subject_ID int(11) default NULL,
  Seminar_ID int(11) default NULL
) TYPE=MyISAM;

#
# Dumping data for table 'associations'
#


#
# Table structure for table 'clubs'
#

CREATE TABLE clubs (
  Club_ID int(11) NOT NULL default '0',
  Name varchar(255) default NULL,
  Homepage varchar(255) default NULL,
  Description mediumblob,
  PRIMARY KEY  (Club_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'clubs'
#


#
# Table structure for table 'permissions'
#

CREATE TABLE permissions (
  User_ID int(11) default NULL,
  Club_ID int(11) default NULL,
  Seminars tinyint(4) default NULL,
  Subjects tinyint(4) default NULL
) TYPE=MyISAM;

#
# Dumping data for table 'permissions'
#


#
# Table structure for table 'seminars'
#

CREATE TABLE seminars (
  Seminar_ID int(11) NOT NULL default '0',
  Subject_ID int(11) default NULL,
  Title varchar(255) default NULL,
  Description mediumblob,
  Date date default NULL,
  Time time default NULL,
  Room varchar(255) default NULL,
  Lecturer varchar(255) default NULL,
  CONTACTINFO mediumblob,
  PRIMARY KEY  (Seminar_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'seminars'
#


#
# Table structure for table 'subjects'
#

CREATE TABLE subjects (
  Subject_ID int(11) NOT NULL default '0',
  Club_ID int(11) default NULL,
  Name varchar(255) default NULL,
  PRIMARY KEY  (Subject_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'subjects'
#


#
# Table structure for table 'users'
#

CREATE TABLE users (
  User_ID int(11) NOT NULL default '0',
  Name varchar(255) default NULL,
  Super_Admin tinyint(4) default NULL,
  Password varchar(255) default NULL,
  Email varchar(255) default NULL,
  PRIMARY KEY  (User_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'users'
#


