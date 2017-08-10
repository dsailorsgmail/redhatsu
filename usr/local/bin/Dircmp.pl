#!/usr/bin/perl
####################################
##
## 08/01/2014 - dsailors - initial creation
##
####################################
#-----------------------------
$throttlelim = "500";
$dlm = "||";
#$dlm = chr(190);
$debug = 6;
#-----------------------------
$year=`date +%Y`; chop($year);
$month=`date +%m`;chop($month);
$day=`date +%d`;  chop($day);
$hour=`date +%H`; chop($hour);
$min=`date +%M`;  chop($min);
$sec=`date +%S`;  chop($sec);
$tstamp = "$year.$month.$day.$hour.$min.$sec";
#-----------------------------
$PID=$$;
$host=`hostname`;
chop($host);
$sourcepath = "/root/testing/firefox";
$sourcepath2 = "/root/testing/googlechrome-beforebundler";
$workpath = "/tmp";
#$md5file = "$workpath/md5file.$PID.txt";
$md5file = "$workpath/md5file.txt";
#$md5file2 = "$workpath/md5file2.$PID.txt";
$md5file2 = "$workpath/md5file2.txt";
$errfile = "error-file.txt";
$md5sum = "/usr/bin/md5sum";
print "$tstamp - $0 starting on $host\n";
#goto STEP2;
#---- initialize stuff

$rc = system("rm $md5file 2>/dev/nul;touch $md5file;chmod 775 $md5file");
$rc = system("rm $md5file2 2>/dev/nul;touch $md5file2;chmod 775 $md5file2");
$rc = system("rm $errfile 2>/dev/nul;touch $errfile;chmod 775 $errfile");
$rc = system("rm $htmlfile 2>/dev/nul");
#----

#----- do the find and md5sum for all files

print "starting the find\n";
@filepaths = `find $sourcepath -type f -print`;
@filepaths2 = `find $sourcepath2 -type f -print`;
$totfind = $#filepaths;
$totfind2 = $#filepaths2;
$totmd5s = $totfind + $totfind2;



print "starting the md5's \n";


#-----
# Do the first source path
#-----
###########################
for ($i = 0; $i <= $#filepaths; $i++)
  {
     chop($filepaths[$i]);
     $filepaths[$i] =~ s/\$/\\\$/g;
     #print "filepathin = $filepaths[$i]\n";
     @record = split(/["\/"]+/,$filepaths[$i]);
     $file = $record[$#record];
     #------------------------
     #----- throttle so as not to overload the cpu
     #------------------------
     #if ($throttlect > $throttlelim)
     while ($throttlect > $throttlelim)
       {
         @ps = `ps -ef | grep md5sum | grep -v grep`;
             ######print "waiting for filect $filect\n";
             for ($p = 0; $p <= $#ps; $p++)
                {
                  ###print "-$p-$throttlect-> $ps[$p]\n";
                }

         $throttlect = $#ps;
         ####print "throttlect set to $throttlect\n";
       } 
       ####print "starting another md5sum for tc $throttlect md5ct = $filect total = $totmd5s\n";
       #print "\n\n#>> $md5sum \"$filepaths[$i]\" >>$md5file 2>>$errfile & \n\n";
       $rc = system("$md5sum \"$filepaths[$i]\" >>$md5file 2>>$errfile & ");
       #$rc = system("$md5sum \"$filepaths[$i]\" >>$md5file 2>>$errfile");
       $filect++;
       $throttlect++;
              
     #------- end of inline throttle -----------------
   }
##########################
#-----
# Do the second source path
#-----
for ($ia = 0; $ia <= $#filepaths2; $ia++)
  {
     chop($filepaths2[$ia]);
     $filepaths2[$ia] =~ s/\$/\\\$/g;
     #print "filepath2in = $filepaths2[$ia]\n";
     @record = split(/["\/"]+/,$filepaths2[$ia]);
     $file = $record[$#record];
     #------------------------
     #----- throttle so as not to overload the cpu
     #------------------------
     #if ($throttlect > $throttlelim)
     while ($throttlect > $throttlelim)
       {
         @ps = `ps -ef | grep md5sum | grep -v grep`;
             ####print "waiting for filect $filect\n";
             for ($p = 0; $p <= $#ps; $p++)
                {
                  ###print "-$p-$throttlect-> $ps[$p]\n";
                }

         $throttlect = $#ps;
         #### print "throttlect set to $throttlect\n";
       } 
       ##### print "starting another md5sum for tc $throttlect md5ct = $filect total = $totmd5s\n";

       #print "starting another md5sum for tc $throttlect filect = $filect total = $filepaths2\n";
       #print "\n\n#>> $md5sum \"$filepaths2[$ia]\" >>$md5file2 2>>$errfile & \n\n";

       $rc = system("$md5sum \"$filepaths2[$ia]\" >>$md5file2 2>>$errfile &");
       $filect++;
       $throttlect++;
              
     #------- end of inline throttle -----------------
   }
##########################
#-----
# end of md5 submissions
#-----
##########################

#----- watch the remaining md5 processes until they run out

while ($p > 0)
   {
     @ps = `ps -ef | grep md5sum | grep -v grep`;
         for ($p = 0; $p <= $#ps; $p++)
           {
             ###print "-$p-> $ps[$p]\n";
           }

    ##### print "===== $p still running. sleep 2 ============================\n";
    sleep 2;
   }
#-----

##########################
STEP2:
#----------------------------
$year=`date +%Y`; chop($year);
$month=`date +%m`;chop($month);
$day=`date +%d`;  chop($day);
$hour=`date +%H`; chop($hour);
$min=`date +%M`;  chop($min);
$sec=`date +%S`;  chop($sec);
$tstampmd5 = "$year.$month.$day.$hour.$min.$sec";
#-----------------------------
##########################
print "--- starting md5file ---\n";
#--------------------
unless (open(infile,"$md5file")) {print "cant open $md5file\n";exit;}
  {
       @line =<infile>;
       $totlfiles = $#line;
  }
    for ($i = 0; $i <= $#line; $i++)
     {
       chomp($line[$i]);
       @recordmd = split(/[" "]+/,$line[$i]);
       $md5 = $recordmd[0];
       #print "md5 = $md5\n";
       $fpath = substr($line[$i],length($md5),length($line[$i]));
       #print "$md5 - $fpath\n";

       #- strip off leading blanks from path
       while (substr($fpath,0,1) eq ' ')
         {
           $fpath = substr($fpath,1,length($fpath));
         }

       # duplicate files in multiple paths
       $md5array{$md5} = $md5array{$md5}.$fpath.$dlm;

       # md5 in path
       $pathmd5{$fpath} = $md5;

     }

#####################################################
##########################
print "--- starting md5file2 ---\n";
#--------------------
unless (open(infile2,"$md5file2")) {print "cant open $md5file2\n";exit;}
  {
       @line2 =<infile2>;
       $totlfiles2 = $#line2;
  }
    for ($i2 = 0; $i2 <= $#line2; $i2++)
     {
       chomp($line2[$i2]);
       @recordmd = split(/[" "]+/,$line2[$i2]);
       $md5 = $recordmd[0];
       #print "md5 = $md5\n";
       $fpath = substr($line2[$i2],length($md5),length($line2[$i2]));

       #- strip off leading blanks from path
       while (substr($fpath,0,1) eq ' ')
         {
           $fpath = substr($fpath,1,length($fpath));
         }
       ##### print "\nmd5file2 - $md5 - $fpath\n";
       $fpathcmp = $fpath;
       $fpathrep = $fpath;
       $fpathcmp =~ s/$sourcepath2/$sourcepath/g;
       $fpathrep =~ s/$sourcepath2//g;
       #print "fpathrep = $fpathrep\n";
       if ($pathmd5{$fpathcmp} ne '')
         {
            #print "hit on a file exists in that path - $pathmd5{$fpathcmp}\n";
            if ($md5 eq $pathmd5{$fpathcmp})
              {
                #####print "Same File $fpathrep\n";
                $pathmd5{$fpathcmp} = "4 Same";
                $samect++;
              } else {
                        #####print "Different File $fpathrep\n";
                        $pathmd5{$fpathcmp} = "3 Different";
                        $differentct++;
                     }
         } else { 
                  #####print "No File at $fpathrep\n"; 
                  $pathmd5{$fpathcmp} = "2 $sourcepath2 Only";
                  $sourcepath2ct++;
                }


     }
#----------------------------------
# print the results of the compairson
print "Comparison of $sourcepath to $sourcepath2\n\n";
foreach $md5path (keys %pathmd5)
{
     $status = $pathmd5{$md5path};
     $fileout = $md5path;
     if ($pathmd5{$md5path} eq "2 $sourcepath2 Only")
       {
         $fileout =~ s/$sourcepath/$sourcepath2/g;
       }
     if (($pathmd5{$md5path} ne "4 Same") && ($pathmd5{$md5path} ne "3 Different") && ($pathmd5{$md5path} ne "2 $sourcepath2 Only"))
       {
          $status = "1 $sourcepath Only";
          $sourcepathct++;
       }
     #print ">>> $status \t $md5path \n";
     $rptct++;
     ##xxxx $report[$rptct] = "$status \t $md5path";
     $report[$rptct] = "$status \t $fileout";
}
@reportsorted = sort @report;
for ($r = 1; $r <= $#reportsorted; $r++)
  {
    $outline = substr($reportsorted[$r],2,length($reportsorted[$r]));
    #print "-> $reportsorted[$r]\n";
    print "-> $outline\n";
  }
    
#exit;
#####################################################
#- loop through md5array to find duplicates

print "Duplicates below\n";
foreach $md5rec (keys %md5array)
{
  @recorda = split(/["||"]+/,$md5array{$md5rec});
  if ($#recorda > 1)
    {
      $dupct++;
      $duplicate[$dupct] = $md5rec."||".$md5array{$md5rec};
    }
}

#--
#- print out duplicates

print "\n\n===================== Duplicated files in $sourcepath - (multiple paths with identical files)  =============================\n\n";
$totdups = $#duplicate;
for ($d = 1; $d <= $#duplicate; $d++)
  {
    @recordb = split(/["||"]+/,$duplicate[$d]);
    if ($recordb[0] eq 'd41d8cd98f00b204e9800998ecf8427e')
      {
        $info = " -Empty Files- ";
      } else { $info = ''; }

    print "\n######################################$info#########\n";
    print "md5sum - $recordb[0]\n";
    for ($b = 1; $b <= $#recordb; $b++)
      {
        print "dup - $recordb[$b]\n";
      }
    
  }
#----------------------------
$year=`date +%Y`; chop($year);
$month=`date +%m`;chop($month);
$day=`date +%d`;  chop($day);
$hour=`date +%H`; chop($hour);
$min=`date +%M`;  chop($min);
$sec=`date +%S`;  chop($sec);
$tstampend = "$year.$month.$day.$hour.$min.$sec";
#-----------------------------
print "\n\n\n";
print "=======================\n";
print "$tstamp - $0 started\n";
print "$tstampmd5 the md5's finished\n";
print "$tstampend all done\n";
print "Total Files Processed = $totmd5s\n";
print "Total Files in $sourcepath = $totfind\n";
print "Total Files in $sourcepath2 = $totfind2\n";
print "Total Files Different = $differentct\n";
print "Total Files Same = $samect\n";
print "Total Files in $sourcepath only = $sourcepathct\n";
print "Total Files in $sourcepath2 only = $sourcepath2ct\n";
print "Total Duplicate Files in $sourcepath  = $totdups\n";
print "=======================\n";
print "\n\n\n";
