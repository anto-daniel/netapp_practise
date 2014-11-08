#!/usr/bin/perl
use CGI;
use Data::Dumper;

my @hashes;
@version = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 sysconfig -a/;
@aggr = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -Ah |grep -v .snap |sed -e '1d' |awk '{print \$1" Data Utilized:"\$5}'/;
@vol = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -h |grep -v .snap |sed -e '1d' |awk '{print \$1"\tData Utilized:"\$5}'/;
print "Content-type: text/html\n\r\n";
print "<h2 align =left><font color =red>NetApp Storage Config Details</h2></font>";
print "<img src=/images/isanlogo.png></br>";


foreach $var (@version) {
    my ($k, $v) = split /:/;
    $var->{$k} = $v;
    push @hashes, $var;
}

#foreach $arr (@hashes) {
#    print "$arr<br>";
#}
print @hashes[0];
print @hashes[1];
print @hashes[2];
print @hashes[3];
print @hashes[4];
print @hashes[5];

