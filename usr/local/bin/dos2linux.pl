#!/usr/bin/perl
$infile = "$ARGV[0]";
$outfile = "y.del";
unless (open(outfile,">$outfile")) {print "cant open $outfile\n";exit;}
unless (open(infile,"$infile")) {print "cant open $infile\n";exit;}
  {
       @line =<infile>;
    for ($i = 0; $i <= $#line; $i++)
     {
       chomp($line);
       print "->$line[$i]\n";
       $outrec = $line[$i];
       for ($l = 1; $l <= length($outrec); $l++)
         {
           $char = substr($outrec,$l-1,1); 
           $chrd = ord($char);
           print "$l = $char = $chrd\n";
           if ($chrd ne 13)
             {
               $outstring = $outstring.$char;
             }
         }
       print "\n";
       print outfile "$outstring";
       $outstring = '';
     }

  }
$rc = system("cp $infile $infile.old");
$rc = system("cp $outfile $infile");
