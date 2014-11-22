#!/usr/bin/perl
# Connect Module #
use DBI;
$dbh = DBI->connect(
  "dbi:mysql:dbname=namedb",
  "root",
  "mysql123",
  { RaiseError=>1 },
) or die $DBI::errstr;
$dbh->do("INSERT INTO employee_details VALUES('Erajkumar',5,'Confirmed')");
$id = $dbh->last_insert_id("", "", "namedb", "");
print "Inserted Data in row id : $id\n";
$dbh->disconnect();

