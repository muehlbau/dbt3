#!/usr/bin/perl -w

use strict;
use SAP::DBTech::dbm;
use Pod::Usage;
use FileHandle;
use Getopt::Long;
use Env qw(DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE/Sapdbpms";
use DBM::Exe_dbm_cmds;

=head1 NAME

init_db.pl

=head1 SYNOPSIS

read database parameters from files and create database

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
	$session, $hlp, $result);
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

# call drop_db.sh to drop the database, we do not check the result
# since the error might be caused by database not exist
print "drop database\n";
system("./drop_db.sh");

# create database, I do not know how to force it not checking credentials
# so I call dbmcli directly, and check the result in dbm.out file
system("dbmcli -s -R /opt/sapdb/depend74 db_create $dbname dbm,dbm 2>&1 | tee dbm.out") && die "system function failed: $!\n";

my $ftmp = new FileHandle;
unless ( $ftmp->open( "< dbm.out" ) )
	{ die "open file dbm.out failed $!"; }
# read the first line to find out if there is any errors
my $line1 = <$ftmp>;
$_ = $line1;
if ( /ERR/ )
{
	close($ftmp);
	system("rm", "dbm.out");
	die "create database failed\n";
}
else
{
	close($ftmp);
	system("rm", "dbm.out");
	print "create database OK\n";
}

eval {exe_dbm_cmds($user, $password, $dbname, $host, @cmdfiles)};
if ( $@ )
{
	die "error create_db: $@";
} 
