#!/usr/bin/perl
use CGI;
### Declaring Variables ###
@version = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 sysconfig -a/;
@aggr = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -Ah |grep -v .snap |sed -e '1d' |awk '{print \$1"\t\t:\tData Utilized:\t\t"\$5}'/;
@vol = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -h |grep -v .snap |sed -e '1d' |awk '{print \$1"\t\t:\tData Utilized:\t\t"\$5}'/;
@ifcfg = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 ifconfig -a/;
@lunsho = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 lun show -v/;
@messages = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 rdfile \/etc\/messages/;
#@scap = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -Ak |sed -e '1d' |awk '{print \$2}'|rev |cut -c3-|rev/;
@ucap = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 aggr status -r |egrep -i 'parity|dparity|data|spare' |grep -i \//;
@cifs = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 rdfile \/etc\/cifsconfig_share.cfg |grep -v ^# |grep -i \'\\-add\'/;
@nfsval = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 exportfs/;
@license = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 license | grep -v \"not license\" | sed "s\/^\ *\/\/g" /;
@snapmirror = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 snapmirror status |sed  -e '1,2d'/;
@snapvault = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 snapvault status |sed  -e '1,2d'/;
@expire = grep(/expired/,@license);
@crict = grep(/critical/i,@messages);
@failed = grep(/failed/i,@messages);
@error = grep(/error/i,@messages);
$val1 = $#crict + 1;
$val2 = $#failed + 1;
$val3 = $#error + 1;
@ucap = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 aggr status -r |egrep -i 'parity|dparity|data|spare' |grep -i \/ |sed 's\/^\ *\/\/g'/;
foreach $uc (@ucap)
{
    @uc1 = split(/\//,$uc);
    $uc2 = $uc1[0];
    @uc12 = split(/\s+/,$uc2);
    $uc22 = $uc12[9];
    push @scap,$uc22;
}
print "Content-type: text/html\n\r\n";
print "<img src=/images/isanlogo.png></br>";
print "<h3 align =left><font color =red>NetApp Inventor V.01</h3></font>";
print "<BR>";
$sum = 0;
for (@scap)
{
   $sum += $_;
}
$usedcap = (($sum)/(1024**2));
$fval = sprintf("%.3f",$usedcap);

foreach $cif (@cifs)
{
        @cifs1 = split(/"/,$cif);
        $share = $cifs1[1];
#        $volpath = $cifs1[3];
        $str1 = "\\\\192.168.1.7".'\\'.$share;
#        $cfinal = $str1.":----:"."Volume path:".$volpath;
        push @cifsa, $str1;
}
print "<BR>";
print "<b><u><font color=\"blue\">Storage Name:</font><font color=\"red\">192.168.1.7</font></u></b><BR>";
print "<BR>";

print "<b><u><font color=\"blue\">Storage Usable capacity(Including HA): $fval tb</font></u></b><BR>\n";
print "<BR>";

print "<b><u><font color=\"blue\">Current Alerts!:</font></u></b>\n";
print "<BR>";
print "<BR>";

print "<left> <a href=\"/cgi-bin/crict.pl\">Criticals<font color=red>($val1)</font></a><BR>";
print "<a href=\"/cgi-bin/failed.pl\">Fails<font color=red>($val2)</font></a><BR>";
print "<a href=\"/cgi-bin/error.pl\">Errors<font color=red>($val3)</font></a> </left><BR>";
print "<BR>";
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
foreach $i (@ifcfg1)
{
        @arr = split(/:/,$i);
        $iface = $arr[0];
        push @keyarr, $iface;
}
foreach $i2a (@keyarr)
{
         @ifcon = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 ifconfig $i2a/;
         @ifcfg3 = grep(/inet/,@ifcon);
         if(@ifcfg3)
         {
                foreach $j (@ifcfg3)
                {
                        @arr1 = split(/\s/,$j);
                        $ip = $arr1[2];
                        push @valarr, $ip;
                }
         }
         else
         {
                $ip = "No-IP-Configured";
                push @valarr, $ip
         }
}
@hash {@keyarr} = @valarr;
print "<b><u><font color = \"blue\">Network configs:</font></u></b>\n";
print "<ul>";
while(($key,$value) = each (%hash))
{
        print "<li>Interface:\t$key\t:----:\t IP Address:\t$value</li>";
}
print "</ul>";

@lunsho1 = grep(/\/vol\//,@lunsho);
foreach $i1 (@lunsho1)
{
        @lsarr = split(/\s+/,$i1);
        $lpath = $lsarr[1];
        $lsize = $lsarr[2];
        $lstatus = $lsarr[5];
        chop($lstatus);
        $dummy = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 lun show -m $lpath/;
        if ($dummy =~ m/not/)
        {
           $mstring = "lun has no mapping";
        }
        else
        {
        	@dummy1 = split(/\s+/, $dummy);
	        $mstring = $dummy1[1];
        }
        $final_string = "LunPath:".$lpath.":-----:"."LunSize:".$lsize.":-----:"."LunStatus:".$lstatus.":-----:"."client:".$mstring;
        push @key1arr,$final_string;
}
print "<b><u><font color = \"blue\">Block Details:</font></u></b>\n";
print "<ul>";
foreach $ixy (@key1arr)
{
        print "<li>$ixy</li>";
}
print "</ul>";

print "<b><u><font color=\"blue\">Cifs Shares Details:</font></u></b>\n";
print "<BR>";
print "<ul>";
foreach $cif2 (@cifsa)
{
       print "<li>$cif2</li>";
}
print "</ul>";

print "<b><u><font color=\"blue\">Active NFS Paths:</font></u></b>\n";
print "<BR>";
print "<ul>";
@nunic = grep(!/^\s+/,@nfsval);
@nfsval3 = grep(/rw=|root=/,@nunic);
foreach $inf1 (@nfsval3)
{
        @nfstring = split(/\s/,$inf1);
        $nfspath = $nfstring[0];
        print "<li>$nfspath</li>";
}
print "</ul>";
print "<b><u><font color=\"blue\">Licensed Features:</font></u></b></br>";
foreach $keyarray (@license)
{
   @keymain = split(/ /,$keyarray);
   $main = $keymain[0];
   push @keym, $main;
}
print "<ul>";
foreach $arr (@keym)
{
      print "<li>$arr</li>";
}
print "</ul></br>";

print "<ul>";
if (@expire)
{
    print "Expired Features:\n";
    foreach $iexp (@expire)
    {
        print "<li>$iexp</li>";
    }
}
print "</ul>";

print "<b><u><font color=\"blue\">SnapMirror Status:</font></u></b></br>";
print "<ul>";
$tab = "&nbsp;&nbsp;";
if(@snapmirror)
{
    foreach $snap (@snapmirror)
    {
        @smarr = split(/\s+/,$snap);
        $source = $smarr[0];
        $dest = $smarr[1];
        $status = $smarr[2];
        $lag = $smarr[3];
        $state = $smarr[4];
        $smstring = "Source:$tab".$source.":----:$tab$tab$tab"."Destination:$tab".$dest.":----:$tab$tab$tab"."Status:$tab".$status.":----:$tab$tab$tab"."Lag:$tab".$lag.":----:$tab$tab$tab"."State:$tab".$state;
        push @smarr1, $smstring;
    }
    foreach $ism1 (@smarr1)
    {
        print "<li>$ism1</li>";
    }
}
else
{
    print "<li> No SnapMirror Relations Identified!</li>";
}
print "</ul>";

print "<b><u><font color=\"blue\">SnapVault Status:</font></u></b></br>";
print "<ul>";
if(@snapvault)
{
    foreach $snap1 (@snapvault)
    {
        @svarr = split(/\s+/,$snap1);
        $source1 = $svarr[0];
        $dest1 = $svarr[1];
        $status1 = $svarr[2];
        $lag1 = $svarr[3];
        $state1 = $svarr[4];
        $svstring = "Source:$tab".$source1.":----:$tab$tab$tab"."Destination:$tab".$dest1.":----:$tab$tab$tab"."Status:$tab".$status1.":----:$tab$tab$tab"."Lag:$tab".$lag1.":----:$tab$tab$tab"."State:$tab".$state1;
        push @svarr1, $svstring;
    }
    foreach $isv1 (@svarr1)
    {
        print "<li>$isv1</li>";
    }
}
else
{
    print "<li> No SnapVault Relations Identified!</li>";
}
print "</ul>";
