#!/usr/bin/perl

print "Content-Type: text/html\n\n\r\r";
@warn = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 rdfile \/etc\/messages.0  /;
print "<br/>@warn<br/>";
