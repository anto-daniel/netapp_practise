#!/usr/bin/perl

print "Content-Type: text/html\n\n\r\r";
@warn = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 rdfile \/etc\/messages.0  /;
print "<h4 align=left><font color=\"blue\" face=\"Arial\"><u>Warning messages from NetApp Storage Array</u></font></h4>";

print "<ul>";
foreach $cnt (@warn) {
    print "<li>$cnt</li>";
}
print "</ul>";
