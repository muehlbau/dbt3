#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FileHandle;
use File::Basename; 

my $infile;
my $no_refresh;
my $flag_power_test;
my $flag_throughput_test;

GetOptions(
  '2' => \$flag_power_test,
  '3' => \$flag_throughput_test,
  "if=s" => \$infile,
  'z' => \$no_refresh
);

my $raw_data;
my @data;
my $dirname = dirname($infile);

my $avg;

sub average(@)
{
  my @data = shift;
  my $count = scalar(@data);
  my $total = 0;

  for (my $i = 0; $i < $count; $i++) {
    $total += $data[ $i ];
  }

  return $total / $count;
}

my %tcount;
my %tdata; 
my %pcount;
my %pdata; 

open(INFILE,"<$infile");
while (<INFILE>) { 

  my @line; 

  if ($flag_power_test) { 
    if ( s/^\s*PERF\d+.POWER.Q(\d+)/$1/ )  {
    @line = split; 
    }
    unless ($no_refresh) { 
      if (s/^\s*PERF\d+.POWER.RF(\d+)/$1/) { 
        @line = split; 
        $line[0]=$line[0]+22;
      }
    }
    if (@line) { 
      $pcount{$line[0]} || 0; 
      $pdata{$line[0]} || 0;
      $pcount{$line[0]}++;
      $pdata{$line[0]}+=$line[5]; 
    }
  }
  if ($flag_throughput_test) {
    if (s/^\s*PERF\d+.THRUPUT.QS\d+.Q(\d+)/$1/) { 
      @line = split;
    } 
    unless ($no_refresh) { 
      if (s/^\s*PERF\d+.THRUPUT.QS\d+.RF(\d+)/$1/) { 
         @line = split; 
         $line[0]=$line[0]+22;
      }
    }
    if (@line) { 
      $tcount{$line[0]} || 0; 
      $tdata{$line[0]} || 0;
      $tcount{$line[0]}++;
      $tdata{$line[0]}+=$line[5]; 
    }
  }
}

if ($flag_power_test) { 
  open(POUTFILE,">$dirname/q_time_p.data");
  foreach my $key (sort { $a <=> $b } keys(%pcount)) { 
    print POUTFILE $key." ".$pdata{$key}/$pcount{$key}."\n";
  }
  close(POUTFILE);
}

if ($flag_throughput_test) { 
  open(TOUTFILE,">$dirname/q_time_t.data");
  foreach my $key (sort { $a <=> $b } keys(%tcount)) { 
    print TOUTFILE $key.".1 ".$tdata{$key}/$tcount{$key}."\n";
  }
  close(TOUTFILE);
}

print "Graphing query information\n";
my $outfile = new FileHandle;
unless( $outfile->open( "> $dirname/q_time.input" ) ) {
  die "cannot open $dirname/q_time.input $!";
}

my $plots = '';
if ($flag_power_test) {
  $plots .= "\"q_time_p.data\" using 1:2 title \"Power\" with imp ls 1";
}
if ($flag_throughput_test) {
  if ($flag_power_test) {
    $plots .= ", ";
  }
  $plots .= "\"q_time_t.data\" using 1:2 title \"Throughput\" with imp ls 2";
}

print $outfile "set style line 1 lt 1 lw 50\n";
print $outfile "set style line 2 lt 2 lw 50\n";
print $outfile "set term png small\n";
print $outfile "set output \"q_time.png\"\n";
if ($no_refresh) {
print $outfile "set xtics \(\"Q1\" 1, \"Q2\" 2, \"Q3\" 3, \"Q4\" 4, \"Q5\" 5, \"Q6\" 6, \"Q7\" 7, \"Q8\" 8, \"Q9\" 9, \"Q10\" 10, \"Q11\" 11, \"Q12\" 12, \"Q13\" 13, \"Q14\" 14, \"Q15\" 15, \"Q16\" 16, \"Q17\" 17, \"Q18\" 18, \"Q19\" 19, \"Q20\" 20, \"Q21\" 21, \"Q22\" 22\)\n";
} else {
  print $outfile "set xtics \(\"Q1\" 1, \"Q2\" 2, \"Q3\" 3, \"Q4\" 4, \"Q5\" 5, \"Q6\" 6, \"Q7\" 7, \"Q8\" 8, \"Q9\" 9, \"Q10\" 10, \"Q11\" 11, \"Q12\" 12, \"Q13\" 13, \"Q14\" 14, \"Q15\" 15, \"Q16\" 16, \"Q17\" 17, \"Q18\" 18, \"Q19\" 19, \"Q20\" 20, \"Q21\" 21, \"Q22\" 22, \"RF1\" 23, \"RF2\" 24\)\n";
}
print $outfile "set ylabel \"Query Time in Seconds\"\n";
print $outfile "set xrange [0:25]\n";
print $outfile "plot $plots\n";
$outfile->close;

chdir $dirname;
system "gnuplot q_time.input";
