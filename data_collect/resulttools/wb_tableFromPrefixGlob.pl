#!/usr/bin/perl -w 

use strict;
use English;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Getopt::Long;
use CGI qw(:standard *table start_ul :html3);
use Pod::Usage;

use constant DEBUG => 0;

=head1 NAME

wb_tableFromGlob.pl

=head1 SYNOPSIS

Takes a regular expression and pulls all the files that match into 
a web page layout. The regular expression ("glob") should 
be at the end of the statement ( ie "cpu*" )

=head1 ARGUMENTS

 -glob <a glob - you don't need the *>
 -outfile <filename - defaults to STDOUT >
 -title <Table title>
 -index <make list of index>
 -file <filename> 
 -write <filename> 

=cut

my ( $glob, $hlp, $outfile, $title, $index, $configfile, $writeme );

GetOptions(
            "outfile=s" => \$outfile,
            "title=s"   => \$title,
            "glob=s"    => \$glob,
            "index"     => \$index,
   	    "help"      => \$hlp,
            "file=s"    => \$configfile,
            "write=s"   => \$writeme
);

my $fcf = new FileHandle;
my ( $cline, %options );
my ( $iline, $fh, @filelist );

if ($hlp) { pod2usage(1); }

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

if ( $glob ) { $options{ 'glob' } = $glob; }
elsif ( !$options{ 'glob' } ) {
    die "No input glob $!";
}

if ( $title ) { $options{ 'title' } = $title; }
else { $options{ 'title' } = "Table of Results"; }

if ( $outfile ) {
    $fh = new FileHandle;
    unless ( $fh->open( "> $outfile" ) ) { die "can't open output file $!"; }
} elsif ( $options{ 'outfile' } ) {
    $fh = new FileHandle;
    unless ( $fh->open( "> $options{'outfile'}" ) ) {
        die "can't open output file $!";
    }
} else {
    $fh = *STDOUT;
}

@filelist = glob( "$options{ 'glob'}*" );

if ( $index ) {
    print $fh start_ul();
    foreach $iline ( @filelist ) {
        my $aa = a( { -href => "#$iline" } );
        print $fh li( a( { -href => "#$iline" }, $iline ) ), "\n";
    }
    print $fh end_ul();
}

# here is where we write the table
print $fh start_table( { -border => undef }, caption( $options{ 'title' } ) ),
  "\n";
print $fh Tr( th( $options{ 'title' } ) ), "\n";

for ( my $i = 0; $i <= $#filelist; $i = $i + 2 ) {
    if ( $filelist[ $i + 1 ] ) {
        print $fh Tr(
                      td( a( { -href => "$filelist[$i]" }, $filelist[ $i ] ) ),
                      td(
                          a(
                              { -href => "$filelist[$i + 1]" }, $filelist[ $i + 1 ]
                          )
                      )
          ),
          "\n";
    } else {
        print $fh Tr (
                   td( a( { -href => "$filelist[$i ]" }, $filelist[ $i ] ) ) ),;
    }

}

print $fh end_table();

if ( $outfile ) { $fh->close; }

if ( $writeme ) {
    my $ncf = new FileHandle;
    unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
    my $name;
    foreach $name ( keys( %options ) ) {
        print $ncf $name, "=", $options{ $name }, "\n";
    }
    $ncf->close;
}

