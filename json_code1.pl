#!/usr/bin/perl
use CGI;
use JSON::XS;

#QUERYING MODULE
@version = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 sysconfig -a/;
@ucap = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 aggr status -r |egrep -i 'parity|dparity|data|spare' |grep -i \//;
@aggr = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -Ah |grep -v .snap |sed -e '1d' |awk '{print \$1":Data Utilized:"\$5}'/;
@vol = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -h |grep -v .snap |sed -e '1d' |awk '{print \$1":Data Utilized:"\$5}'/;
@ifcfg = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 ifconfig -a/;
@lunsho = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 lun show -v/;
@cifs = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 rdfile \/etc\/cifsconfig_share.cfg |grep -v ^# |grep -i \'\\-add\'/;
@nfsval = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 exportfs/;
@license = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 license | grep -v \"not license\" | sed "s\/^\ *\/\/g" /;
@snapmirror = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 snapmirror status |sed  -e '1,2d'/;
@snapvault = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 snapvault status |sed  -e '1,2d'/;

#PRODUCT DETAILS MODULE
$maps = [];
foreach $a(@version)
{
    chomp($a);
    if($a =~ m/Release/)
    {
    push $maps,{release => $a};
	}
    if($a =~ m/System Serial/)
    {
    push $maps,{sysserial => $a};
    }
    if($a =~ m/system id/i)
    {
      push $maps,{systemid =>$a};
    }
    if($a =~ m/model/i)
    {
      push $maps,{model =>$a};
    }
}

#USABLE SIZE MODULE
$maps1 = [];
foreach $uc (@ucap)
{
    @uc1 = split(/\//,$uc);
    $uc2 = $uc1[0];
    @uc12 = split(/\s+/,$uc2);
    $uc22 = $uc12[9];
    push @scap,$uc22;
}
$sum = 0;
for (@scap)
{
   $sum += $_;
}
$usedcap = (($sum)/(1024**2));
$fval = sprintf("%.3f",$usedcap);
$fval1 = $fval."TB";
push $maps1,{usable_size =>$fval1};

#AGGREGATE SUMMARY MODULE
$maps2 = [];
foreach $b (@aggr)
{
    	chomp($b);
	push $maps2, {aggr_summary=>$b};
}

#VOLUME SUMMARY MODULE
$maps3 = [];
foreach $c (@vol)
{
    push $maps3,  {Vol_summary=> $c};
}

#NETWORK SUMMARY MODULE
$maps4 = [];
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
while(($key,$value) = each (%hash))
{
        $nicval = $key.":".$value;
	push $maps4, {NICSummary=>$nicval};
}

#LUN DETAILS MODULE
$maps5 = [];
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
        $final_string = "LunPath:".$lpath.","."LunSize:".$lsize.","."LunStatus:".$lstatus.","."client:".$mstring;
        push @key1arr,$final_string;
}
foreach $ixy (@key1arr)
{
        push $maps5,{Lun_details=>$ixy};
}

#ACTIVE CIFS SHARES SUMMARY MODULE
$maps6 = [];
foreach $cif (@cifs)
{
        @cifs1 = split(/"/,$cif);
        $share = $cifs1[1];
        $str1 = '\\192.168.1.7'.'\\'.$share;
        push @cifsa, $str1;
}
foreach $cif2 (@cifsa)
{
       push $maps6, {active_cifs_share=>$cif2};
}

#ACTIVE NFS SHARES SUMMARY MODULE
$maps7 = [];
@nunic = grep(!/^\s+/,@nfsval);
@nfsval3 = grep(/rw=|root=/,@nunic);
foreach $inf1 (@nfsval3)
{
        @nfstring = split(/\s/,$inf1);
        $nfspath = $nfstring[0];
        push $maps7, {nfs_shares=> $nfspath};
}
#LICENSE INFORMATION MODULE 
$maps8 = [];
$maps9 = [];
foreach $keyarray (@license)
{
   @keymain = split(/ /,$keyarray);
   $main = $keymain[0];
   push @keym, $main;
}
foreach $arr (@keym)
{
      push $maps8, {Active_License=>$arr};
}
if (@expire)
{
    foreach $iexp (@expire)
    {
        push $maps9, {Expired_License=>$iexp};
    }
}
#SNAPMIRROR STATUS MODULE
$maps10 = [];
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
        $smstring = "Source:".$source.",Destination:".$dest.",Status:".$status.",Lag:".$lag.",State:".$state;
        push @smarr1, $smstring;
    }
    foreach $ism1 (@smarr1)
    {
        push $maps10, {Identified_SM_Relation=> $ism1};
    }
}
else
{
    $negative = "No SnapMirror Relations Identified";	
    push $maps10 , {No_SM_string=> $negative};
}
#SNAPVAULT STATUS MODULE
$maps11 = [];
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
        $svstring = "Source:".$source1.",Destination:".$dest1.",Status:".$status1.",Lag:".$lag1.",State:".$state1;
        push @svarr1, $svstring;
    }
    foreach $isv1 (@svarr1)
    {
        push $maps11, {SnapVault=>$isv1};
    }
}
else
{
    $str = " No SnapVault Relation Identified";
    push $maps11, {SnapVault=>$str};
}


#JSON ENCODE MODULE
$j = JSON::XS->new->utf8->pretty(1);
$output = $j->encode({
    success => "true",
    data => {product=> $maps, usable=> $maps1, Aggregates=> $maps2, Volumes=> $maps3, Network_config=> $maps4, Block_storage=> $maps5, Active_Cifs_shares=> $maps6, Active_nfs_shares=> $maps7, Active_LIcense=> $maps8, Expired_License=> $maps9, SnapMirror=>$maps10, SnapVault=>$maps11} 
});
print "Content-type: application/json\n\n\r";
print $output;
