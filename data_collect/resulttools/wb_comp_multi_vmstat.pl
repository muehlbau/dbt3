#!/usr/bin/perl -w

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Pod::Usage;
use CGI qw(:standard *table start_ul :html3);
use Env qw(DBT3_INSTALL_PATH DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE";
use Data_report;
use Gr_multi_dir;

=head1 NAME

wb_comp_multi_runs.pl

=head1 SYNOPSIS

generate gnuplot based on the file in multiple run directories
and put them on one page

=head1 ARGUMENTS

 -infile <input data file name>
 -outfile <prefix for .png and .input files >
 -runname <name of the runs to compare>
 -file <config file> 
 -write <create new config file >
All options require parameters
Options on command line over-rule config file

=cut 

my (
	 $infile, $hlp,	$outfile, $configfile, $writeme, @runs);

GetOptions(
			"infile=s"   => \$infile,
			"outfile=s"  => \$outfile,
			"runs=s"  => \@runs,
			"help"	   => \$hlp,
			"write=s"	=> \$writeme,
			"file=s"	 => \$configfile
);

my $fcf  = new FileHandle;
my $fin  = new FileHandle;
#my $fout = new FileHandle;
#unless ( $fout->open( "> $outfile.html" ) ) { die "cannot open output $!"; }

my ( $cline, %options );

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
		$_ = $var;
		if ( /runs/ )
		{
			$#runs++;
		}
	}
	$fcf->close;
}

if ( $infile ) { $options{ 'infile' } = $infile; }
elsif ( $options{ 'infile' } ) {
	$infile =  $options{ 'infile' };
}
else 
{
	die "No input file $!";
}

if ( $outfile ) { $options{ 'outfile' } = $outfile; }
elsif ( $options{ 'outfile' } ) {
	$outfile =  $options{ 'outfile' };
}
else 
{
	die "No outfile file $!";
}

for ( my $i=0; $i<=$#runs; $i++ )
{
	if ( $runs[$i] )
	{
		$options{ "runs$i" } = $runs[$i];
	}
	elsif ( $options{ "runs$i" } )
	{
		$runs[$i] =  $options{ "runs$i" };
	}
	else
	{
		die "No run name $!";
	}
}


if ( $writeme ) {
	my $ncf = new FileHandle;
	unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
	my $name;
	foreach $name ( keys( %options ) ) {
		print $ncf $name, "=", $options{ $name }, "\n";
	}
	$ncf->close;
}


if ( $infile =~ /vmstat/ )
{
	gen_vmstat_page("$outfile", @runs);
}
else
{
	die "the input file must be a vmstat file";
}

sub gen_vmstat_page
{
	my ($outfile, @runs) = @_;
	my $fout = new FileHandle;
	unless ( $fout->open( "> $outfile.html" ) ) { die "cannot open output $!"; }

	#print the vmstat table
	my ($version, $keyfile, @heads_plot, @filelist_html, $max_row, 
		$max_value, @filelist, @dirlist, $dir_index, @heads_ap);
	$version = get_vmstat_version();
	$keyfile = "vmstat.$version.key";
	if ( -f $keyfile )
	{
		@heads_plot = eval{ get_header( $keyfile, "", "plot" ) };
		@heads_ap = eval{ get_header( $keyfile, "", "ap" ) };
		if ($@)
		{
		        die "error get_diskheads_plot: $@";
		}
		my $head_str;
		$head_str = join(' ', @heads_plot);
	}
	else
	{
		die "file $keyfile is required\n";
	}

#	print $fout start_table( { -FRAME => "BOX", -CELLSPACING => 0, 
#		-cols =>2, -rules => "GROUPS", -BORDER => 1});
	print $fout start_table( { -FRAME => "BOX", -CELLSPACING => 0, 
		-cols =>2, -BORDER => 1});
	print $fout Tr({-valign=>"TOP", -HEIGHT=>50, -BGCOLOR=>"#c0c0c0",
		-aligh=>"LEFT"},
	[
		th(["vmstat header", "link to plot"]),
	]);

	$dir_index = 0;
	for (my $i=0; $i<=$#runs; $i++)
	{
		my @tmp_dirlist = glob($runs[$i]);
		for (my $j=0; $j<=$#tmp_dirlist; $j++)
		{
			$dirlist[$dir_index] = $tmp_dirlist[$j];
			$dir_index++;
		}
	}

	for ( my $i=0; $i<=$#dirlist; $i++)
	{
		$filelist[$i] = "$dirlist[$i]/$infile";
	}

	print "filelist ", join ( '  ', @filelist );

	$max_row = get_max_row_number(@filelist);
	# generate the files
	for (my $i=0; $i<=$#heads_plot; $i++)
	{
		$filelist_html[$i] = "$outfile.vmstat_col$i";
		my @filelist_png;
		my $max_col = get_max_col_value($i, @filelist);
		for (my $j=0; $j<=$#runs; $j++)
		{
			$filelist_png[$j] = "$outfile.vmstat_col$i.run_$j";
			print "run vale is $runs[$j]\n";
			my @names = split /\*/, $runs[$j];
			print "names are $names[0] $names[1]\n";
			eval {gr_multi_dir($infile, 
				$filelist_png[$j], $runs[$j], 
				$heads_plot[$i], $max_row, $max_col, 
				"", "", "$names[0]","$names[1]", 
				$i)};
			if ( $@ )
			{
				die "error generating graphs";
			}
			$filelist_png[$j] = $filelist_png[$j].".png";
		}

		gen_html_table("$filelist_html[$i].html", @filelist_png);
		$filelist_html[$i] = $filelist_html[$i].".html";
	}

	for (my $i=0; $i<=$#heads_plot; $i++)
	{
		print $fout Tr({-valign=>"TOP", -HEIGHT=>50, -aligh=>"LEFT"},
		[
			td(["$heads_plot[$i]", (a( {-href=>"$filelist_html[$i]"}, "$heads_ap[$i]"))]),
		]);
	}
	print $fout end_table; 

	close($fout);
}

