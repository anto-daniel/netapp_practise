#!/usr/bin/perl
@ucap = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 aggr status -r |egrep -i 'parity|dparity|data|spare' |grep -i \/ |sed 's\/^\ *\/\/g'/;
foreach $uc (@ucap)
{
@uc1 = split(/\//,$uc);
$uc2 = $uc1[0];
@uc12 = split(/\s+/,$uc2);
$uc22 = $uc12[9];
print $uc22,"\n";
}

