#!/usr/bin/perl
use DBI;

$dbh = DBI->connect(
    "dbi:mysql:dbname=namedb",
    "root",
    "mysql123",
    {RaiseError => 1},
)or die $DBI::errstr;
$sth = $dbh->prepare("SELECT * FROM employee_details");
$sth->execute();
while(($name,$id,$status) = $sth->fetchrow())
{
    print "$name\t$id\t$status\n";
}
$fields = $sth->{NUM_OF_FIELDS};
$rows = $sth->rows();
$sth->finish();
$dbh->disconnect();
#print "$name\t\t$id\t\t$status\n";
print "We have selected $fields Field(s)\n";
print "We have selected $rows Rows(s)\n";

