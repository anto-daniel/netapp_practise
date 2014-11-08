#!/usr/bin/perl

@notice = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 rdfile \/etc\/messages.0  | egrep -i ':error'/;
print "Content-Type: text/html\n\r\n";

print "<h4><font face=\"Arial\" color=\"blue\"><u>Notice messages from Storage Array</u></font>";
print "<ul>";
foreach $cnt (@notice) {
    print "<li>$cnt</li>";
}
print "</ul>";
