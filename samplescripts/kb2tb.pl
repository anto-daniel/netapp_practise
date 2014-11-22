#!/usr/bin/perl
print "Enter the kb value:";
$a = <STDIN>;
chomp($a);
$tb = (($a)/(1024**3));
print "For the $a KB value is equal to $tb TB\n";

