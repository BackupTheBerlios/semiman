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
  PRIMARY KEY  (Subject_ID,Seminar_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'associations'
#

INSERT INTO associations VALUES (1,1);
INSERT INTO associations VALUES (1,6);
INSERT INTO associations VALUES (4,1);
INSERT INTO associations VALUES (4,4);
INSERT INTO associations VALUES (5,4);
INSERT INTO associations VALUES (5,5);
INSERT INTO associations VALUES (5,6);

#
# Table structure for table 'clubs'
#

CREATE TABLE clubs (
  Club_ID int(11) NOT NULL auto_increment,
  Clubname varchar(30) default NULL,
  Name varchar(255) default NULL,
  Homepage varchar(255) default NULL,
  Description mediumblob,
  PRIMARY KEY  (Club_ID),
  KEY clubs_clubname (Clubname),
  KEY clubs_name (Name)
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
  User_ID int(11) NOT NULL default '0',
  Club_ID int(11) NOT NULL default '0',
  Seminars tinyint(4) default NULL,
  Subjects tinyint(4) default NULL,
  PRIMARY KEY  (User_ID,Club_ID)
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
  Seminar_ID int(11) NOT NULL auto_increment,
  Subject_ID int(11) default NULL,
  Title varchar(255) default NULL,
  Description mediumtext,
  Date date default NULL,
  Time time default NULL,
  EndTime time default NULL,
  Room varchar(255) default NULL,
  Lecturer varchar(255) default NULL,
  ContactInfo mediumblob,
  PRIMARY KEY  (Seminar_ID),
  FULLTEXT KEY Title (Title,Description),
  FULLTEXT KEY Lecturer (Lecturer),
  KEY seminars_date (Date,Time)
) TYPE=MyISAM;

#
# Dumping data for table 'seminars'
#

INSERT INTO seminars VALUES (1,4,'Using tcpdump','A lecture about using tcpdump','2002-08-27','18:30:00','20:30:00','Taub 6','Guy Keren Esq.','Orr Dunkleman, Guy Keren');
INSERT INTO seminars VALUES (4,4,'BGP','Hay Cohen will give a fascinating lecture about the Border Gateway Protocol','2002-08-30','18:30:00','19:30:00','Taub 6','Hay Cohen','Orr Dunkelman, Guy Keren');
INSERT INTO seminars VALUES (5,5,'Zavitan - Design and Implementation','Roy Glasberg and Shlomi Fish would cover the design of the Zavitan Seminars Management System	','2002-09-09','16:30:00','19:30:00','Taub 3','Shlomi Fish & Roy Glasberg','Shlomi Fish');
INSERT INTO seminars VALUES (6,5,'WebMetaLanguage','A lecture about WebMetaLanguage - a tool to \r\ncreate static HTML pages.','2002-08-30','13:30:00','15:30:00','Taub 6','Shlomi Fish','OrrD, Guy Keren');

#
# Table structure for table 'subjects'
#

CREATE TABLE subjects (
  Subject_ID int(11) NOT NULL auto_increment,
  Club_ID int(11) default NULL,
  Name varchar(255) default NULL,
  PRIMARY KEY  (Subject_ID),
  KEY subjects_name (Name),
  KEY subjects_club_id (Club_ID)
) TYPE=MyISAM;

#
# Dumping data for table 'subjects'
#

INSERT INTO subjects VALUES (1,8,'Internet');
INSERT INTO subjects VALUES (2,8,'ATM Works');
INSERT INTO subjects VALUES (3,8,'Ethernet');
INSERT INTO subjects VALUES (4,1,'Networking');
INSERT INTO subjects VALUES (5,1,'Development');

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
  PRIMARY KEY  (User_ID),
  KEY users_username (Username)
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

