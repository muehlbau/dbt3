#!/usr/bin/perl -w 

use strict;
use English;
use Getopt::Std;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use CGI qw(:standard :html3);

use constant DEBUG => 0;

# Thanks, bryce!

=head1 NAME 

parsedata.pl

=head1 SYNOPSIS

munges data from various system performance tools. 
Can take input in text or binary form 
Creates a csv file and a gnuplot data file as output

=head1 ARGUMENTS

A Configuration file is used for input 
-f <config file>
-s <section in config file>
-v <Vmstat version (procps) 

=cut

sub get_vmstat_v {
	my $str = `vmstat -V 2>&1 `;
	chomp $str;
	my @outline = split / /,$str;
	return $outline[2];
}

sub get_iostat_v { 
	my $str = `iostat -V 2>&1 | head -1 `;
	chomp $str;
	my @outline = split / /,$str;
	return $outline[2];
}

sub get_sar_v { 
	my $str = `sar -V 2>&1 | head -1 `;
	chomp $str;
	my @outline = split / /,$str;
	return $outline[2];
}

sub get_sar_names {
	my $keyfile = shift;
	my $option = shift;
	my ( $opt, $opts, $line, @options, @keys );
	open ( SKEY, "$keyfile" ) or return 0;
	while ( ( $line = <SKEY> ) =~ /^#/ ) {
		my $junk = $line;
	}
	chomp $line;
	@options = split /:/,$line;
	my $not_found = 1;
	$option =~ s/^-//;

	foreach $opt ( @options ) {
		if ( $option =~ /$opt/ ) { $not_found = 0; 
		
		}
	}
	if ($not_found) { return 0; } 
	$not_found = 1;
	
	while ( $line = <SKEY> )  {
		next if ( $line =~ /^#/ );
		next if ( $line !~ /^$option/ );
		chomp $line;
		$opts = $line;
		$not_found = 0 ;
		# remove the option
	}
	close(SKEY);
	if ($not_found) { return 0; } 
		@keys = split /:/,$opts;
		shift @keys;
		return @keys;
}
	

	

sub get_hr_heads {
	my $keyfile = shift;
	my ($line, @ostr );
	open ( KF, "$keyfile" ) or return 1;
	while ( ( $line = <KF> ) =~ /^#/ ) {
		my $junk = $line;
	}
	chomp $line;
	@ostr = split /:/,$line;
	close(KF);
	return @ostr;
} 

sub get_app_heads {
	my $keyfile = shift;
	my ($line, @ostr );
	open ( KF, "$keyfile" ) or die "no keyfile $!";
	while ( ( $line = <KF> ) =~ /^#/ ) {
		my $junk = $line;
	}
	# walk past the first non-comment line
	while ( ( $line = <KF> ) =~ /^#/ ) {
		my $junk = $line;
	}
	chomp $line;
	@ostr = split /:/,$line;
	close(KF);
	return @ostr;
}

sub vmstat_parse {
    my ( $indir, $infile, $outdir, $outfile, $comment, @headers ) = @_;

    my ( $lncnt, $inline, $datfh, $infh, $csvfh, $datfn, $infn, $csvfn );

    return 1 unless ( -f "$indir/$infile" ) ;
    print "in vmstat_parse\n" if DEBUG;
    $datfn = catdir $outdir, $outfile . ".dat";
    $csvfn = catdir $outdir, $outfile . ".csv";
    $infn  = catdir $indir,  $infile;

    $datfh = new FileHandle;
    $infh  = new FileHandle;
    $csvfh = new FileHandle;

    open( $datfh, ">$datfn" ) or return 2;
    open( $csvfh, ">$csvfn" ) or return 3;
    open( $infh,  "$infn" )   or return 4;

    print $datfh "# $comment \n";
    print $datfh "# ", join ( ' ', @headers ), "\n";
    print $csvfh "$comment\n";
    print $csvfh join ( ',', @headers ), "\n";

    $lncnt = 0;
    for $inline ( <$infh> ) {
        chomp $inline;
        $inline =~ s/^\s*//;
        next if ( $inline !~ /^\d/ );
        my @cols = split /\s+/, $inline;
        print "vline ", join ( ':', @cols ), "\n" if DEBUG;
        print $csvfh join ( ',', @cols ), "\n";
        print $datfh "$lncnt ", join ( '  ', @cols ), "\n";
        $lncnt++;
    }
    close( $csvfh );
    close( $infh );
    close( $datfh );

    return 0;

}

sub iostat_parse {
	my ( $indir, $infile, $outdir, $outfile, $comment, @headers ) = @_;
	# hack 
    my ( $mline, @cfh, @rfh, @wfh,  %iosdisks, @line, $iodisk);
    my $linecnt = 0;

    return 1 unless ( -f "$indir/$infile" );
        open( INDAT, "$indir/$infile" ) or return 4;
	for $mline ( <INDAT> )  {
        next if ( ( $mline =~ /^Linux/ )
             || ( $mline =~ /^$/ )
             || ( $mline =~ /^avg/ )
             || ( $mline =~ /^IO/ )
             || ( $mline =~ /^Device/ )
             || ( $mline =~ /^ / ) );
        
            @line = split /\s+/, $mline; 
	    $iodisk = $line[ 0 ];
	    shift @line;
		print "disk is now $iodisk\n" if DEBUG;
	    $iosdisks{$iodisk} = "true";
        
    }
	close (INDAT);
    foreach $iodisk ( keys %iosdisks ) {
	print "in disk $iodisk\n" if DEBUG;
        open( CSVOUT, ">$outdir/$outfile.$iodisk.csv" )
          or return 2;
        open( DATROUT, ">$outdir/$outfile.$iodisk.read.dat" )
          or return 3;
        open( DATWOUT, ">$outdir/$outfile.$iodisk.write.dat" )
          or return 4;
        print DATROUT "# $iodisk blocks read\n";
        print DATWOUT "# $iodisk blocks written\n";
        print CSVOUT "Disk IO $iodisk (iostat -d - long )\n";
        print CSVOUT join(',',@headers),"\n";
        open( INDAT, "$indir/$infile" ) or return 4;
        $linecnt = 1;
        my $totr = 0;
        my $totw = 0;

        while ( <INDAT> ) {
            if ( /^$iodisk/ ) {
                @line = split ( " " );
                next unless ( $line[ 0 ] =~ /^$iodisk$/ );

                print CSVOUT "$line[1], $line[2],$line[3],$line[4],$line[5]\n";
                print DATROUT "$linecnt   $line[1]\n";
                $totr = $totr + $line[ 1 ];
                print DATWOUT "$linecnt   $line[2]\n";
                $totw = $totw + $line[ 2 ];
                $linecnt++;
            }
        }
        close( INDAT );
        close( CSVOUT );
        close( DATROUT );
        close( DATWOUT );
        unless ( $totr > 0 ) {
            unlink( "$outdir/$outfile.$iodisk.read.dat" );
        }
        unless ( $totw > 0 ) {
            unlink( "$outdir/$outfile.$iodisk.write.dat" );
        }
	unless ( ( $totw > 0 ) && ( $totr > 0 ) ) {
		unlink( "$outdir/$outfile.$iodisk.csv" );
		}
    }

    return 0;
}

sub ips_parse {
    my ( $ipsfile, $outfile ) = @_;
    my $cnt = 0;
    open( IPSF,   "$ipsfile" )  or die "no infile";
    open( IPSOUT, ">$outfile" ) or return 1;
    print IPSOUT "# Bogotransactions\n";
    while ( <IPSF> ) {
        chomp;
        my @line = split ( /,/ );
        print IPSOUT "$cnt    $line[1]\n";
        $cnt++;
    }
    close( IPSF );
    close( IPSOUT );
    return 0;
}

sub sar_parse_s {
	my ( $indir, $infile, $outdir, $outfile, $title, $saropts, $mincol, $maxcol, @titles ) = @_;
	my ( $line, @lines, $cnt, $lncnt );
    	my $datfh = new FileHandle;
    	my $csvfh = new FileHandle;
    	my $txtfh = new FileHandle;
	
	open ( $txtfh, ">$outdir/$outfile.txt" ) or return 4;
	print $txtfh "# $title \n";
	my $spid = open(SARIN, "sar $saropts -f $indir/$infile |" ) or return 1;
	for $line ( <SARIN> ) {
		print $txtfh "$line";
	}
	close( SARIN );
	close( $txtfh );

	open ( $datfh, ">$outdir/$outfile.dat" ) or return 2;
	open ( $csvfh, ">$outdir/$outfile.csv" ) or return 3;
	print $datfh "# $title \n";
	print $csvfh "$title \n";
	print $csvfh join(',', @titles ),"\n";
	print $datfh "# ", join(' ', @titles ),"\n";
	print "sar $saropts -f $indir/$infile\n";
	$spid = open(SARIN, "sar -H $saropts -f $indir/$infile |" ) or return 1;
	print "Sar pid is $spid\n" if DEBUG;
	$lncnt = 0;
	for $line ( <SARIN> ) {
		chomp $line;
		@lines = split /;/, $line;
		print $datfh "$lncnt  ";
		foreach $cnt ( $mincol .. ($maxcol - 1) ) {
			print $csvfh "$lines[$cnt],";
			print $datfh "$lines[$cnt]  ";
		}
		print $csvfh "$lines[$maxcol]\n";
		print $datfh "$lines[$maxcol]\n";
		$lncnt++;
	}
	close($csvfh);
	close($datfh);
	close(SARIN);
	return 0;
}

sub sar_parse_t {
	my ( $indir, $infile, $outdir, $outfile, $title, $saropts, $mincol, $maxcol, $datitle, @titles ) = @_;
	my ( $lintot, $line, @lines, $cnt, $lncnt );
    	my $datfh = new FileHandle;
    	my $csvfh = new FileHandle;
    	my $txtfh = new FileHandle;
	
	open ( $txtfh, ">$outdir/$outfile.txt" ) or return 4;
	print $txtfh "# $title \n";
	my $spid = open(SARIN, "sar $saropts -f $indir/$infile |" ) or return 1;
	for $line ( <SARIN> ) {
		print $txtfh "$line";
	}
	close( $txtfh );
	close( SARIN );

	open ( $datfh, ">$outdir/$outfile.dat" ) or return 2;
	open ( $csvfh, ">$outdir/$outfile.csv" ) or return 3;
	print $datfh "# $title \n";
	print $csvfh "$title \n";
	print $csvfh join(',', @titles ),"\n";
	print $datfh "# $datitle\n";
#	print "sar -H  $saropts -f $indir/$infile\n";
	$spid = open(SARIN, "sar -H $saropts -f $indir/$infile |" ) or return 1;
	print "Sar pid is $spid\n" if DEBUG;
	$lncnt = 0;
	for $line ( <SARIN> ) {
		chomp $line;
		@lines = split /;/, $line;
		$lintot = 0;
		#foreach $cnt ( $mincol .. ($maxcol - 1) ) {
		foreach $cnt ( $mincol .. ($maxcol) ) {
			print $csvfh "$lines[$cnt],";
			$lintot = $lintot + $lines[$cnt];
		}
#		print $csvfh "$lines[$maxcol]\n";
#		$lintot = $lintot + $lines[$maxcol];
		print $datfh "$lncnt  $lintot\n";
		$lncnt++;
	}
	close($csvfh);
	close($datfh);
	close(SARIN);
	return 0;
}

		
	


# START HERE BUBBA

our( $opt_f, $opt_s, $opt_v );
getopts( 'f:s:v:' );
my ( @heads, $pver, $insw, $section, $configfile, $line, %data );

if ( !( $opt_f ) ) {
    print STDERR "Program requires input from config file - use -f option\n";
    exit 1;
}
if ( !( $opt_s ) ) {
    print STDERR "and you must specify a section name - use -s \n";
    exit 1;
}
if ($opt_v) { $pver = $opt_v; }
	elsif ( $opt_s =~ /^vm/ )  { $pver = get_vmstat_v(); }
	elsif ( $opt_s =~ /^io/ )  { $pver = get_iostat_v(); }
	elsif ( ( $opt_s =~ /^sa/ ) || ( $opt_s =~ /^tsa/ ) )  { $pver = get_sar_v(); }

print "vm version is $pver\n" if DEBUG;

$configfile = $opt_f;
$section    = $opt_s;

$insw = 0;
open( CONF, "$configfile" ) or die "Config file not found $!";
for $line ( <CONF> ) {
    chomp $line;
    next if ( $line =~ /^#/ );
    if ( $line =~ /^--$section/ ) {
        if ( $insw ) { $insw = 0; }
        else { $insw = 1; }
    } elsif ( $insw ) {
        my ( $var, $value ) = split /=/, $line;
        $data{ $var } = $value;
    }
}
close( CONF );

print "File is $data{ 'INDIR' } \n" if DEBUG;

if ( $section eq 'vmstat' ) {
    print "parsing vmstat\n" if DEBUG;
    my $vmkey = "vmstat.".$pver.".key";
    @heads = get_hr_heads($vmkey);

    # vmstat_parse { my ( $indir, $infile, $outdir, $outfile, $comment, @headers ) = @_;
    my $res = vmstat_parse(
                            $data{ 'INDIR' },
                            $data{ 'INFILE' },
                            $data{ 'OUTDIR' },
                            $data{ 'OUTFILE' },
                            $data{ 'COMMENT' },
				@heads
    );
    if ( $res > 0 ) { print STDERR "vmstat problems results = $res\n"; }

} elsif ( $section eq 'iostat' ) {
    print "parsing iostat\n" if DEBUG;
    my $ioskey = "iostat.".$pver.".key";
    @heads = get_hr_heads($ioskey);
    my $ires = iostat_parse( 
                            $data{ 'INDIR' },
                            $data{ 'INFILE' },
                            $data{ 'OUTDIR' },
                            $data{ 'OUTFILE' },
                            $data{ 'COMMENT' },
				@heads
    );
	print "iostat ret is $ires\n";		
    
} elsif ( $section =~ /^sar/ ) {
	print "parsing sar\n" if DEBUG;
	my $keyfile = "sar.".$pver.".key";
	my $opt = $data{ 'SAROPT' };
	my @headlist = get_sar_names($keyfile, $opt);
	
	if ( $headlist[0] > 0  ) {
	my $offset = shift @headlist;

	sar_parse_s(
                            $data{ 'INDIR' },
                            $data{ 'INFILE' },
                            $data{ 'OUTDIR' },
                            $data{ 'OUTFILE' },
                            $data{ 'COMMENT' },
                            $data{ 'SAROPT' },
                            ($offset +  $data{ 'MINCOL' }),
                            ($offset + $data{ 'MAXCOL' }),
				@headlist
    );
	} else { print STDERR " bad sar thang\n"; }
	

} elsif ( $section =~ /tsar/ ) { 
	print "parsing tsar\n" if DEBUG;
	my $keyfile = "sar.".$pver.".key";
	my $opt = $data{ 'SAROPT' };
	my @headlist = get_sar_names($keyfile, $opt);
	
	if ( $headlist[0] > 0  ) {
	my $offset = shift @headlist;

	sar_parse_s(
                            $data{ 'INDIR' },
                            $data{ 'INFILE' },
                            $data{ 'OUTDIR' },
                            $data{ 'OUTFILE' },
                            $data{ 'COMMENT' },
                            $data{ 'SAROPT' },
                            ($offset +  $data{ 'MINCOL' }),
                            ($offset + $data{ 'MAXCOL' }),
	#			$data{ 'TITLE' },
				@headlist
    );

	} else { print STDERR "Bad sar option or missing file\n"; }

} elsif ( $section =~ /Usar/ ) { 
	print "parsing Usar\n" if DEBUG;
	my $keyfile = "sar.".$pver.".key";
	my $opt = 'U';
	my @headlist = get_sar_names($keyfile, $opt);
	my $CPUS = `grep -c ^processor /proc/cpuinfo`;
	my $cpucnt = 0;
	my $outfile;
	
	if ( $headlist[0] > 0  ) {
        my $offset = shift @headlist;
	for ( $cpucnt = 0; $cpucnt < $CPUS; $cpucnt++ ) {
		$opt = $data{ 'SAROPT' }." $cpucnt";
		$outfile = $data{ 'OUTFILE' }."$cpucnt";
		sar_parse_t ( 
			$data{ 'INDIR' },
                            $data{ 'INFILE' },
                            $data{ 'OUTDIR' },
			$outfile,
			$data{ 'COMMENT' },
			$opt,
			($offset +  $data{ 'MINCOL' }),
                            ($offset + $data{ 'MAXCOL' }),
                                $data{ 'TITLE' },
                                @headlist
    );

}
}
}
	


