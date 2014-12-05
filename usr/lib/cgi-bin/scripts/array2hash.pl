#!/usr/bin/perl
use CGI;
use JSON::XS;

@version = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 sysconfig -a/;
$maps = [];

foreach $a(@version) {
    chomp($a);
    if($a =~ m/Release/) {
        push $maps,{release => $a};
    }
    
    if($a =~ m/System Serial/) {
        push $maps,{sysserial => $a};
    }

    if($a =~ m/system id/i) {
      push $maps,{systemid =>$a};
    }

    if($a =~ m/model/i) {
      push $maps,{model =>$a};
    }
}
$j = JSON::XS->new->utf8->pretty(1);
$output = $j->encode({
    success => "true",
    data => {product=> $maps,testarry => $maps}

});
print "Content-type: application/json\n\n\r";
print $output;
