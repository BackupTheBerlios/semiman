# MySQL dump 8.16
#
# Host: localhost    Database: test_seminars
#--------------------------------------------------------
# Server version	3.23.47

#
# Table structure for table 'associations'
#

CREATE TABLE associations (
  Subject_ID int(11) NOT NULL default '0',
  Seminar_ID int(11) NOT NULL default '0',
  PRIMARY KEY (Subject_ID, Seminar_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'associations'
#


#
# Table structure for table 'clubs'
#

CREATE TABLE clubs (
  Club_ID int(11) NOT NULL auto_increment,
  Clubname varchar(30) default NULL,
  Name varchar(255) default NULL,
  Homepage varchar(255) default NULL,
  Description mediumblob,
  PRIMARY KEY  (Club_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'clubs'
#

INSERT INTO clubs VALUES (1,'haifux','Haifa Linux Club','http://linuxclub.il.eu.org/homepage','A club for discussing Linux');
INSERT INTO clubs VALUES (8,'clubnet','Club-Net','http://comnet.technion.ac.il/','Discuss Computer Networks.');

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

INSERT INTO permissions VALUES (1,1,0,0);
INSERT INTO permissions VALUES (2,1,0,0);
INSERT INTO permissions VALUES (3,1,0,0);
INSERT INTO permissions VALUES (4,1,1,1);
INSERT INTO permissions VALUES (5,1,0,0);
INSERT INTO permissions VALUES (6,8,1,0);
INSERT INTO permissions VALUES (6,1,0,0);
INSERT INTO permissions VALUES (1,8,0,0);
INSERT INTO permissions VALUES (2,8,0,0);
INSERT INTO permissions VALUES (3,8,0,0);
INSERT INTO permissions VALUES (4,8,1,1);
INSERT INTO permissions VALUES (5,8,0,0);

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
  Subject_ID int(11) NOT NULL auto_increment,
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
  User_ID int(11) NOT NULL auto_increment,
  Name varchar(255) default NULL,
  Username varchar(30) default NULL,
  Super_Admin tinyint(4) default NULL,
  Password varchar(255) default NULL,
  Email varchar(255) default NULL,
  PRIMARY KEY  (User_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'users'
#

INSERT INTO users VALUES (1,'Haifa Linux Club Esq.','shlomif',1,'Hello',NULL);
INSERT INTO users VALUES (2,'Roy Glasberg','roi',1,'roi','roy@roy.org');
INSERT INTO users VALUES (3,'Yoram Yihyieuuu','yoramy',0,'yoram','yoramy@ee.technion.ac.il');
INSERT INTO users VALUES (4,'Google','hello',0,'toyo','hello@google.com');
INSERT INTO users VALUES (5,'Yahoo','yahoo',0,'hojoj','shlomif@vipe.stud.technion.ac.il');
INSERT INTO users VALUES (6,'pop','pop',0,'pop','pop@t2.technion.ac.il');

