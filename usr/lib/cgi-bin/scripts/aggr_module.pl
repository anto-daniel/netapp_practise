#!/usr/bin/perl
@aggr_m = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 df -Ah |grep -v .snap |sed -e '1d' |awk '{print \$1}'/;
foreach $ag1 (@aggr_m){
    @aggr_m1 = qx/sshpass -p admin123 ssh -o StrictHostKeyChecking=no root\@192.168.1.7 aggr status -r $ag1/;
    chomp($ag1);
    print "$ag1\n";
    agr_status();
    agr_dtypes();

}
sub agr_status{
    @aggr_m2 = grep(/Aggregate/,@aggr_m1);
    foreach $ag2 (@aggr_m2){
        if($ag2 =~ /online/){
            if($ag2 =~ /raid_dp/){
                $status = "Online,Raid_dp";
            }
            elsif($ag2 =~ /raid4/){
                $status = "Online,Raid4";   
            }   
        }
        elsif($ag2 =~ /offline/){
            if($ag2 =~ /raid_dp/){
                $status = "Offline,Raid_dp";
            }
            elsif($ag2 =~ /raid4/){
                $status = "Offline,Raid4";
            }
        }
        else{
            $status = "Unknown";
        }
    }
    print $status,"\n";
}
sub agr_dtypes{
    @aggr_m3 = grep(/parity|dparity|data/,@aggr_m1);
    foreach $ag3 (@aggr_m3){
        @agdisk = split(/\s+/,$ag3);
        $dtype = $agdisk[8];
        $drpm = $agdisk[9];
        $dstring = $dtype."@".$drpm;
        push @disks, $dstring;
    }
    @disks1 = sort(@disks);            
    ($temp,$count) = ("@disks1",0);
    ($count = $temp =~ s/($_)//g) and push @fdisks1,printf"%2d:%s\n",$count,$_ for @disks1;
}
