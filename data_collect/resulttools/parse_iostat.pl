#!/usr/bin/perl -w 

# CVS Strings 
# $Id: parse_iostat.pl 802 2003-03-11 00:42:26Z jztpcw $ $Author: jztpcw $ $Date

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use FileHandle;
use CGI qw(:standard :html3);
use Pod::Usage;

use constant DEBUG => 0;

=head1 NAME

parse_iostat.pl

=head1 SYNOPSIS

Takes a text file produced by iostat and extracts all the disk information from same

=cut

sub get_iostat_v {
    my $str = `iostat -V 2>&1 | head -1 `;
    chomp $str;
    my @outline = split / /, $str;
    return $outline[ 2 ];
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

sub iostat_parse_total {
    my ( $infile, $outfile, $title, @heads ) = @_;
    my ( @devs, $dd, $line, @spline, $dsk, %diskdone, $lcnt, %dsks );
    @devs = get_file_disknames( $infile );
    my $drpre = substr $devs[ 0 ], 0, 2;
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
    unless ( $app->open( "$infile" ) ) { die "can't open infile $!"; }
    while ( $line = $app->getline ) {
        next if ( $line !~ /^$drpre/ );
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
    return 0;

}

sub get_file_disknames {
    my ( $infile ) = @_;
    my ( $mline, %iosdisks, $iodisk, @odsks, @line );
    return 1 unless ( -f "$infile" );
    my $ios = new FileHandle;

    unless ( $ios->open( "$infile" ) ) { return 4; }
    while ( $mline = $ios->getline ) {
        next
          if ( ( $mline =~ /^Linux/ )
               || ( $mline =~ /^$/ )
               || ( $mline =~ /^avg/ )
               || ( $mline =~ /^IO/ )
               || ( $mline =~ /^Disk/ )
               || ( $mline =~ /^iostat/ )
               || ( $mline =~ /^Device/ )
               || ( $mline =~ /^ / ) );
        @line = split /\s+/, $mline;
        $iodisk = $line[ 0 ];
        shift @line;
        print "disk is now $iodisk\n" if DEBUG;
        $iosdisks{ $iodisk } = "true";

    }
    $ios->close;

    foreach $iodisk ( keys %iosdisks ) {
        push @odsks, $iodisk;
    }
    return @odsks;

}

sub iostat_parse {
    my ( $infile, $outfile, $comment, @headers ) = @_;

    # hack 
    my ( $mline, @cfh, @rfh, @wfh, @iosdisks, @line, $iodisk );
    my $linecnt = 0;
    @iosdisks = get_file_disknames( $infile );
    foreach $iodisk ( @iosdisks ) {
        print "in disk $iodisk\n" if DEBUG;
        open( CSVOUT, ">$outfile.$iodisk.csv" )
          or return 2;
        open( DATROUT, ">$outfile.$iodisk.read.dat" )
          or return 3;
        open( DATWOUT, ">$outfile.$iodisk.write.dat" )
          or return 4;
        print DATROUT "# $comment\n";
        print DATWOUT "# $comment\n";
        print DATROUT "# $iodisk $headers[0] $headers[2]\n";
        print DATWOUT "# $iodisk $headers[1] $headers[3]\n";
        print CSVOUT "Disk IO $iodisk (iostat -d - long )\n";
        print CSVOUT join ( ',', @headers ), "\n";
        open( INDAT, "$infile" ) or return 4;
        $linecnt = 1;
        my $totr = 0;
        my $totw = 0;

        while ( <INDAT> ) {
            if ( /^$iodisk/ ) {
                @line = split ( " " );
                next unless ( $line[ 0 ] =~ /^$iodisk$/ );

                print CSVOUT "$line[1], $line[2],$line[3],$line[4],$line[5]\n";
                print DATROUT "$linecnt   $line[2] $line[4]\n";
                $totr = $totr + $line[ 2 ];
                print DATWOUT "$linecnt   $line[3] $line[5]\n";
                $totw = $totw + $line[ 3 ];
                $linecnt++;
            }
        }
        close( INDAT );
        close( CSVOUT );
        close( DATROUT );
        close( DATWOUT );
        unless ( $totr > 0 ) {
            unlink( "$outfile.$iodisk.read.dat" );
        }
        unless ( $totw > 0 ) {
            unlink( "$outfile.$iodisk.write.dat" );
        }
        unless ( ( $totw > 0 ) && ( $totr > 0 ) ) {
            unlink( "$outfile.$iodisk.csv" );
        }
    }

    return 0;
}

=head1 ARGUMENTS

 -infile <filename> text file with iostat data
 -outfile <filename> prefix for .csv and .dat files
 -file <filename> use configuration file for all options
 -comment <string> comment for file name
 -write <filename> create configuration file 
 -total - write all disk info to single file ( don't use if you have a lot of disks) 

=cut

my ( $totf, $infile, $outfile, $comment, $configfile, $writeme, $hlp );

my ( %options, @heads, $cline, $line );

my $fcf = new FileHandle;
GetOptions(
            "infile=s"  => \$infile,
            "outfile=s" => \$outfile,
            "comment=s" => \$comment,
            "help"      => \$hlp,
            "total"     => \$totf,
            "write=s"   => \$writeme,
            "file=s"    => \$configfile
);

if ( $hlp ) { pod2usage( 1 ); }

if ( $configfile ) {
    unless ( $fcf->open( "< $configfile" ) ) {
        die "Missing config file $!";
    }
    while ( $cline = $fcf->getline ) {
        next if ( $cline =~ /^#/ );
        chomp $cline;
        my ( $var, $value ) = split /=/, $cline;
        $options{ $var } = $value;
    }
    $fcf->close;
}

if ( $infile ) { $options{ 'infile' } = $infile; }
elsif ( !$options{ 'infile' } ) {
    die "No input file $!";
}

if ( $outfile ) { $options{ 'outfile' } = $outfile; }
elsif ( !$options{ 'outfile' } ) {
    die "No output file $!";
}

if ( $comment ) { $options{ 'comment' } = $comment; }
elsif ( !$options{ 'comment' } ) {
    $options{ 'comment' } = "Iostat data";
}

my $version = get_iostat_v;
my $keyfile = "iostat.$version.key";
if ( -f $keyfile ) { @heads = get_diskheads( $keyfile, "d", "hr" ); }
else { @heads = get_livedisk_heads; }

my $res;
if ( $totf ) {
    $res = iostat_parse_total(
                               $options{ 'infile' },
                               $options{ 'outfile' },
                               $options{ 'comment' },
                               @heads
    );
}

else {
    $res = iostat_parse(
                         $options{ 'infile' },
                         $options{ 'outfile' },
                         $options{ 'comment' },
                         @heads
    );
}
if ( $res > 0 ) { print STDERR "iostat problems results = $res\n"; }

if ( $writeme ) {
    my $ncf = new FileHandle;
    unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
    my $name;
    foreach $name ( keys( %options ) ) {
        print $ncf $name, "=", $options{ $name }, "\n";
    }
    $ncf->close;
}
