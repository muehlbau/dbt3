#!/usr/bin/perl -w 

use strict;
use English;
use Getopt::Long;
use FileHandle;
use Pod::Usage;

=head1 NAME

run_iostat.pl

=cut

=head1 SYNOPSIS

run_iostat.pl -outfile <filename> -interval <int> -count <int> [ -title <title> -keys -version <version> ] ( -disk | -sumdisk ) [ -bytes ]
	

Runs vmstat taking <count> samples at <interval> times.

  Output: ( filename defaults to /tmp/vmstat )
   <filename>.txt - all output 
   <filename>.csv - all output in .csv format
   <filename>.dat - all output in gnuplot input format
   '-disk' = per-disk file
   '-sumdisk' = per-second output in one file, total in second file

=cut

=head1 ARGUMENTS
  -outfile <base filename>
  -interval <integer>
  -count <integer>
  -disk - get all disk stats one file per disk
  -sumdisk - All per second io in one file all totals in second
  -title <data file header>
  -keys - use human readable headers translated from keyfile
  -version - give name of key file
  -bytes - results expressed in Kilobytes


=cut

sub get_iostat_v {
    my $str = `iostat -V 2>&1 | head -n 1 `;
    chomp $str;
    my @outline = split / /, $str;
    return $outline[ 2 ];
}

sub get_iostat_devs {
    my ( %sortme, $disk, @odev, $line, @lines );
    my $ios = new FileHandle;
    unless ( $ios->open( "iostat -d 1 1 |" ) ) { return 1; }
    while ( $line = $ios->getline ) {
        next
          if ( ( $line =~ /^$/ )
               || ( $line =~ /^Linux/ )
               || ( $line =~ /^Device/ ) );
        @lines = split /\s+/, $line;
        $sortme{ $lines[ 0 ] } = "BoB";
    }

    close( $ios );
    foreach $disk ( keys %sortme ) { push @odev, $disk; }

    return @odev;
}

sub get_diskheads {
    my ( $keyfile, $opt, $type ) = @_;
    my ( $line, @ostr, @tstr, $nf );
    $nf = 1;
    my $fkey = new FileHandle;
    unless ( $fkey->open( "< $keyfile" ) ) { return 1; }
    while ( ( $line = $fkey->getline ) && ( $nf == 1 ) ) {
        next if ( $line =~ /^#/ );
        chomp $line;
        @tstr = split /;/, $line;
        if ( ( $tstr[ 0 ] eq $opt ) && ( $tstr[ 1 ] eq $type ) ) {
            $nf = 0;
            shift @tstr;    # Remove option
            shift @tstr;    # Remove type
            shift @tstr;    # Remove device name
            @ostr = @tstr;
        }
    }
    $fkey->close;
    if ( $nf == 1 ) { return 1; }
    return @ostr;
}

sub get_livedisk_heads {
    my $byte = shift;
    my ( $line, @ostr );
    my $ios = new FileHandle;
    if ( $byte ) {
        unless ( $ios->open( "iostat -d -k 1 1 |" ) ) { return 1; }
    } else {
        unless ( $ios->open( "iostat -d 1 1 |" ) ) { return 1; }
    }
    while ( $line = $ios->getline ) {
        if ( $line =~ /^Device/ ) {
            chomp $line;
            @ostr = split /\s+/, $line;
            shift @ostr;
        }
    }
    $ios->close;
    return @ostr;
}

sub run_disks_tot {
    my ( $outfile, $interval, $count, $title, $doheads, $keyfile, $byte ) = @_;
    my (
         $line, @spline, $lcnt, $dsk,  @heads,
         $dd,   $as,     @devs, %dsks, %diskdone
    );
    if ( ( $doheads eq "yes" ) && ( $keyfile ne "no" ) ) {
        if ( $byte ) {
            @heads = get_diskheads( $keyfile, "k", "hr" );
        } else {
            @heads = get_diskheads( $keyfile, "d", "hr" );
        }

    } else {
        @heads = get_livedisk_heads( $byte );
    }
    @devs = get_iostat_devs;
    my $app = new FileHandle;
    my ( $cssf, $txsf, $dasf, $cstf, $txtf, $datf );
    $cssf = new FileHandle;
    $txsf = new FileHandle;
    $dasf = new FileHandle;
    $cstf = new FileHandle;
    $txtf = new FileHandle;
    $datf = new FileHandle;
    unless ( $cssf->open( "> $outfile.PerSec.csv" ) ) { die "open $!"; }
    print $cssf "$title\n";

    unless ( $cstf->open( "> $outfile.tot.csv" ) ) { die "open $!"; }
    print $cstf "$title\n";

    unless ( $txsf->open( "> $outfile.PerSec.txt" ) ) { die "open $!"; }
    print $txsf "$title\n";

    unless ( $txtf->open( "> $outfile.tot.txt" ) ) { die "open $!"; }
    print $txtf "$title\n";

    unless ( $dasf->open( "> $outfile.PerSec.dat" ) ) { die "open $!"; }
    print $dasf "# $title\n#";

    unless ( $datf->open( "> $outfile.tot.dat" ) ) { die "open $!"; }
    print $datf "# $title\n#";

    for $dd ( 0 .. $#devs ) {
        if ( $dd < $#devs ) {
            print $cssf "$devs[$dd],,";
            print $cstf "$devs[$dd],,";
            print $txtf "$devs[$dd]        ";
            print $txsf "$devs[$dd]        ";
            print $dasf "$devs[$dd]        ";
            print $datf "$devs[$dd]        ";
        } else {
            print $cssf "$devs[$dd],,\n";
            print $cstf "$devs[$dd],,\n";
            print $txtf "$devs[$dd]        \n";
            print $txsf "$devs[$dd]        \n";
            print $dasf "$devs[$dd]        \n#";
            print $datf "$devs[$dd]        \n#";
        }
    }
    for $dd ( 0 .. $#devs ) {
        if ( $dd < $#devs ) {
            print $cssf "$heads[0],$heads[1],$heads[2],";
            print $cstf "$heads[0],$heads[3],$heads[4],";
            print $txsf "$heads[0] $heads[1] $heads[2] ";
            print $txtf "$heads[0] $heads[3] $heads[4] ";
            print $dasf "$heads[0] $heads[1] $heads[2] ";
            print $datf "$heads[0] $heads[3] $heads[4] ";
        } else {
            print $cssf "$heads[0],$heads[1],$heads[2]\n";
            print $cstf "$heads[0],$heads[3],$heads[4]\n";
            print $txsf "$heads[0] $heads[1] $heads[2]\n";
            print $txtf "$heads[0] $heads[3] $heads[4]\n";
            print $dasf "$heads[0] $heads[1] $heads[2]\n";
            print $datf "$heads[0] $heads[3] $heads[4]\n";
        }
    }

    $lcnt = 1;
    unless ( $app->open( "iostat -d $interval $count |" ) ) {
        die "can't start iostat";
    }
    while ( $line = $app->getline ) {
        next
          if ( ( $line =~ /^Linux/ )
               || ( $line =~ /^$/ )
               || ( $line =~ /^Device/ ) );
        chomp $line;
        @spline = split /\s+/, $line;
        $dsk = shift @spline;
        if ( !$diskdone{ $dsk } ) {
            $dsks{ $dsk }     = [ @spline ];
            $diskdone{ $dsk } = "yes";
        } elsif ( $diskdone{ $dsk } eq "yes" ) {
            print $datf "$lcnt ";
            print $dasf "$lcnt ";
            for $dd ( 0 .. $#devs ) {
                if ( $dd < $#devs ) {
                    print $cssf
"$dsks{$devs[$dd]}[0],$dsks{$devs[$dd]}[1],$dsks{$devs[$dd]}[2],";
                    print $cstf
"$dsks{$devs[$dd]}[0],$dsks{$devs[$dd]}[3],$dsks{$devs[$dd]}[4],";
                    print $txsf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[1] $dsks{$devs[$dd]}[2] ";
                    print $txtf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[3] $dsks{$devs[$dd]}[4] ";
                    print $dasf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[1] $dsks{$devs[$dd]}[2] ";
                    print $datf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[3] $dsks{$devs[$dd]}[4] ";
                } else {
                    print $cssf
"$dsks{$devs[$dd]}[0],$dsks{$devs[$dd]}[1],$dsks{$devs[$dd]}[2]\n";
                    print $cstf
"$dsks{$devs[$dd]}[0],$dsks{$devs[$dd]}[3],$dsks{$devs[$dd]}[4]\n";
                    print $txsf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[1] $dsks{$devs[$dd]}[2]\n";
                    print $txtf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[3] $dsks{$devs[$dd]}[4]\n";
                    print $dasf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[1] $dsks{$devs[$dd]}[2]\n";
                    print $datf
"$dsks{$devs[$dd]}[0] $dsks{$devs[$dd]}[3] $dsks{$devs[$dd]}[4]\n";
                }
            }
            $lcnt++;

        } elsif ( $diskdone{ $dsk } eq "no" ) {
            $dsks{ $dsk }     = [ @spline ];
            $diskdone{ $dsk } = "yes";
        }

    }
    $app->close;
    $cssf->close;
    $cstf->close;
    $txsf->close;
    $txtf->close;
    $dasf->close;
    $datf->close;
}

sub run_disks {
    my ( $outfile, $interval, $count, $title, $doheads, $keyfile ) = @_;

    my (
         $line, @spline, $lcnt, $dsk,  @heads, $dd,
         $ass,  @devs,   %lcnt, %csvd, %txtd,  %datd
    );
    if ( ( $doheads eq "yes" ) && ( $keyfile ne "no" ) ) {
        @heads = get_diskheads( $keyfile, "d", "hr" );
    } else {
        @heads = get_livedisk_heads;
    }
    @devs = get_iostat_devs;
    my $app = new FileHandle;
    foreach $dd ( 0 .. $#devs ) {
        $csvd{ $devs[ $dd ] } = new FileHandle;
        $txtd{ $devs[ $dd ] } = new FileHandle;
        $datd{ $devs[ $dd ] } = new FileHandle;
        unless ( $csvd{ $devs[ $dd ] }->open( "> $outfile.$devs[$dd].csv" ) ) {
            die "can't open outfile $!";
        }
        unless ( $txtd{ $devs[ $dd ] }->open( "> $outfile.$devs[$dd].txt" ) ) {
            die "can't open outfile $!";
        }
        unless ( $datd{ $devs[ $dd ] }->open( "> $outfile.$devs[$dd].dat" ) ) {
            die "can't open outfile $!";
        }
        $ass = $csvd{ $devs[ $dd ] };
        print $ass "$title\n";
        print $ass join ( ',', @heads ), "\n";

        $ass = $txtd{ $devs[ $dd ] };
        print $ass "$title\n";
        print $ass join ( ' ', @heads ), "\n";

        $ass = $datd{ $devs[ $dd ] };
        print $ass "# $title\n";
        print $ass "# ", join ( ' ', @heads ), "\n";

        $lcnt{ $devs[ $dd ] } = 1;
    }

    unless ( $app->open( "iostat -d $interval $count |" ) ) {
        die "can't start iostat";
    }
    while ( $line = $app->getline ) {
        next
          if ( ( $line =~ /^Linux/ )
               || ( $line =~ /^$/ )
               || ( $line =~ /^Device/ ) );
        chomp $line;
        @spline = split /\s+/, $line;
        $dsk = shift @spline;
        $ass = $csvd{ $dsk };
        print $ass join ( ',', @spline ), "\n";

        $ass = $txtd{ $dsk };
        print $ass join ( ' ', @spline ), "\n";

        $ass = $datd{ $dsk };
        print $ass "$lcnt{$dsk} ", join ( ' ', @spline ), "\n";
        $lcnt{ $dsk }++;

    }
    $app->close;
    foreach $dd ( 0 .. $#devs ) {
        $csvd{ $devs[ $dd ] }->close;
        $txtd{ $devs[ $dd ] }->close;
        $datd{ $devs[ $dd ] }->close;
    }

}
my (
     $doheads,  $keyfile, $hlp,   $hrhead, $version, $outfile,
     $interval, $count,   $title, $dodisk, $sumd,    $bytes
);

GetOptions(
            "outfile=s"  => \$outfile,
            "interval=i" => \$interval,
            "help"       => \$hlp,
            "disk"       => \$dodisk,
            "title=s"    => \$title,
            "keys"       => \$hrhead,
            "bytes"      => \$bytes,
            "version=s"  => \$version,
            "sumdisks"   => \$sumd,
            "count=i"    => \$count
);

if     ( $hlp )     { pod2usage( 1 ); }
unless ( $outfile ) {
    $outfile = "/tmp/iostat";
    print STDERR "Output defaulting to /tmp/iostat.*\n";
}
unless ( $interval ) { die "No interval $!"; }
unless ( $count )    { die "No count $!"; }
unless ( $title )    {
    $title = "Iostat data - Sampled at $interval second intervals";
}
if ( $hrhead ) {
    $doheads = "yes";
    if ( $version ) {
        $keyfile = "iostat.$version.key";
    } else {
        $version = get_iostat_v;
        $keyfile = "iostat.$version.key";
    }
    unless ( -f "iostat.$version.key" ) { $keyfile = "no"; }

} else {
    print STDERR
      "Reading headers from application, ignoring -version if any \n";
    $doheads = "no";
    $keyfile = "no";
}

if ( $dodisk ) {
    run_disks(
               $outfile, $interval, $count, $title,
               $doheads, $keyfile,  $bytes
    );
} elsif ( $sumd ) {
    run_disks_tot(
                   $outfile, $interval, $count, $title,
                   $doheads, $keyfile,  $bytes
    );
} elsif ( $bytes ) {
    print STDERR "Must specify -disk or -sumdisk\n";
    die "$!";
}

