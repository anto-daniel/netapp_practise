#!/usr/bin/perl

# Connect Module #

use DBI;

$dbh = DBI->connect(
  "dbi:mysql:dbname=namedb",
  "root",
  "mysql123",
  { RaiseError=>1 },
) or die $DBI::errstr;

# Statement Handler Module #

$sth = $dbh->prepare("SELECT VERSION()");
$sth->execute();
$info = $sth->fetch();
print "Type of variable info: ref($info)\n";
print "@$info[0]\n";
$sth->finish();
$dbh->disconnect();


