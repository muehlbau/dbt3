#!/usr/bin/perl -w

use strict;
use Pod::Usage;
use FileHandle;
use Getopt::Long;
use Pod::Usage;
use SAP::DBTech::repman;
use REPM::Exe_repm_cmds;

=head1 NAME

load_db.pl

=head1 SYNOPSIS

create and load tables

=head1 ARGUMENTS

 -cmdfiles <command files>
 -user <user name>
 -password <password>
 -dbname <database name>
 -nodehost <host name of the database node>
 -file <config filename to read from> 
 -write <config filename to write to> 

=cut

my (@cmdfiles, $user, $password, $dbname, $host, $configfile, $writeme, 
	$session, $hlp);
GetOptions(
	"cmdfiles=s" => \@cmdfiles,
	"user=s" => \$user,
	"password=s" => \$password,
	"dbname=s" => \$dbname,
	"nodehost=s" => \$host,
	"help"      => \$hlp,
	"file=s"    => \$configfile,
	"write=s"   => \$writeme
);


my $fcf = new FileHandle;
my ( $cline, %options );
my ( $iline, $fh );

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
		$_ = $var;
		if ( /cmdfiles/ )
		{
			$#cmdfiles++;
		}
	}
	$fcf->close;
}

for ( my $i=0; $i<=$#cmdfiles; $i++ )
{
	if ( $cmdfiles[$i] )
	{
		$options{ "cmdfiles$i" } = $cmdfiles[$i]; 
	}
	elsif ( $options{ "cmdfiles$i" } ) 
	{
		$cmdfiles[$i] =  $options{ "cmdfiles$i" };
	}
	else
	{
		die "No command file $!";
	}
}

if ( $user ) {
	$options{ 'user' } = $user;
} 
elsif ( $options{ 'user' } ) {
	$user=$options{ 'user' };
}
else
{
	die "No user $!";
}

if ( $password ) {
	$options{ 'password' } = $password;
} 
elsif ( $options{ 'password' } ) {
	$password=$options{ 'password' };
}
else
{
	die "No password $!";
}

if ( $dbname ) {
	$options{ 'dbname' } = $dbname;
} 
elsif ( $options{ 'dbname' } ) {
	$dbname=$options{ 'dbname' };
}
else
{
	die "No dbname $!";
}

if ( $host ) {
	$options{ 'nodehost' } = $host;
} 
elsif ( $options{ 'nodehost' } ) {
	$host=$options{ 'nodehost' };
}
else
{
	die "No nodehost $!";
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

my $result = exe_repm_cmds($user, $password, $dbname, $host, @cmdfiles);
print "result is $result\n";
