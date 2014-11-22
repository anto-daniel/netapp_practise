#!/usr/bin/perl
@snapmirror = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 snapmirror status |sed  -e '1d'/;
print "@snapmirror";

