#!/usr/bin/perl
use DBI;

@ary = DBI -> available_drivers();
print @ary,"\n";
