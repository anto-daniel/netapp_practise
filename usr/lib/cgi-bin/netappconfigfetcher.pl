#!/usr/bin/perl
use CGI;
@version = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 sysconfig -a/;
@aggr = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -Ah |grep -v .snap |sed -e '1d' |awk '{print \$1"\tData Utilized:\t\t"\$5}'/;
@vol = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -h |grep -v .snap |sed -e '1d' |awk '{print \$1"\tData Utilized:\t\t"\$5}'/;
@ifcfg = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 ifconfig -a/;
print "Content-type: text/html\n\r\n";
print "<img src=/images/isanlogo.png></br>";
print "<hr color=\"blue\" size=\"3px\">";
print "<h3 align =left><font color =red>NetApp Storage Config Details</h3></font>";
print "<BR>";
print "<b><u><font color=\"blue\">Product Details:</font></u></b>\n";
print "<BR>";
print "<ul>";
foreach $a (@version)
{
    if($a =~ m/Release/)
    {
        print "<li>$a</li>";

    }
    if($a =~ m/System Serial/)
    {
        print "<li>$a</li>";
    }
    if($a =~ m/system id/i)
    {
        print "<li>$a</li>";
    }
    if($a =~ m/model/i)
    {
        print "<li>$a</li>";
    }
}
print "</ul>";
print "<b><u><font color=\"blue\">Aggregate Status:</font></u></b>\n";
print "<BR>";
print "<ul>";
foreach $b (@aggr)
{
    print "<li>$b</li>";

}
print "</ul>";
print "<b><u><font color = \"blue\">Volume Status:</font></u></b>\n";
print "<BR>";
print "<ul>";
foreach $c (@vol)
{
    print "<li>$c</li>";
}
print "</ul>";
@ifcfg1 = grep(/^[a-zA-Z0-9]/,@ifcfg);
@ifcfg2 = grep(/inet/,@ifcfg);
foreach $i (@ifcfg1)
{
        @arr = split(/:/,$i);
        $iface = $arr[0];
        push @keyarr, $iface;
}
foreach $j (@ifcfg2)
{
        @arr1 = split(/\s/,$j);
        $ip = $arr1[2];
        push @valarr, $ip;
}
@hash {@keyarr} = @valarr;
print "<b><u><font color = \"blue\">Network configs:</font></u></b>\n";
print "<ul>";
while(($key,$value) = each (%hash))
{
        print "<li>Interface:$key  -> IP Address:$value</li>";
}
print "</ul>";












###space for Bottom page###
#print "<head>";
print "<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>";
#print "<style>";
#print "ul {";
#print "    list-style-type: none;";
#print "    margin: 0;";
#print "    padding: 0;";
#print "}";
##
#print "li {";
#print "    display: inline;";
#print "}";
#print "</style>";
#print "</head>";
#<body>
#
#print "<ul>";
print " <center> <a href=\"/cgi-bin/warning.pl\">Warning</a>";
print "  <a href=\"/cgi-bin/notice.pl\">Notice</a> </center>";
#print "</ul>";

