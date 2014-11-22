#!/usr/bin/perl

print "Content-type: text/html\n\r\n";
@license = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 license | grep -v \"not license\" | sed "s\/^\ *\/\/g" /;
@expire = grep(/expired/,@license);
print "Licensed Version\n";
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
print "</ul></br>";
#sub expire() {
#    print "Not Licensed Version \n";
#    foreach $exp (@expire) {
#        @expmain = split(/ /,$exp);
#        $main = $expmain[0];
#        push @expm, $main;
#    }
#    foreach $arr (@expm) {
#        print "$arr\n";
#    }
#}



