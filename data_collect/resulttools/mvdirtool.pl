#!/usr/bin/perl -w 

# CVS Strings 
# $Id: mvdirtool.pl 1213 2005-03-04 17:10:26Z fimath $ $Author: fimath $ $Date

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use FileHandle;
use CGI qw(:standard :html3);
use Pod::Usage;
use constant DEBUG => 0;

my ($infile, $from, $to, @filelist);

GetOptions(
        "infile=s" => \$infile,
        "from=s" => \$from, 
        "to=s" => \$to
);

@filelist = glob( $infile );
print "filelist ", join ( '  ', @filelist );

my $newname;
for (my $i=0; $i<=$#filelist; $i++)
{
	$newname = $filelist[$i];
	$newname =~ s/$from/$to/;
	print "new name is $newname\n";
	system("mv", "$filelist[$i]", $newname);
}
