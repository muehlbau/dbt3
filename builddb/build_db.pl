#!/usr/bin/perl -w

use strict;
use SAP::DBTech::dbm;
use Pod::Usage;
use FileHandle;
use Getopt::Long;
use Env qw(DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE/Sapdbpms";
use Build_db;

=head1 NAME

create_db.pl

=head1 SYNOPSIS

Read config files for creating, loading and backing up the database
The config files has to be in the right order
Example: build_db.pl -c create_db.conf -c load_db.conf -c backup_db.conf 

=head1 ARGUMENTS

 -cfgfiles <config files>
 -file <config filename to read from> 
 -write <config filename to write to> 

=cut

my (@cfgfiles, @user, @password, @dbname, @host, $configfile, $writeme, 
	$hlp, @cmdfiles);
GetOptions(
	"cfgfiles=s" => \@cfgfiles,
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
		if ( /cfgfiles/ )
		{
			$#cfgfiles++;
		}
	}
	$fcf->close;
}

for ( my $i=0; $i<=$#cfgfiles; $i++ )
{
	if ( $cfgfiles[$i] )
	{
		$options{ "cfgfiles$i" } = $cfgfiles[$i]; 
	}
	elsif ( $options{ "cfgfiles$i" } ) 
	{
		$cfgfiles[$i] =  $options{ "cfgfiles$i" };
	}
	else
	{
		die "No command file $!";
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

#find out the command files for each step
for ( my $i=0; $i<=$#cfgfiles; $i++)
{
	my ($fcfg, $j);
	$fcfg = new FileHandle;
	unless ( $fcfg->open( "< $cfgfiles[$i]" ) )
		{ die "open file $cfgfiles[$i] failed $!"; }
	$j = 0;
        while ( $cline = $fcfg->getline ) {
		next if ( $cline =~ /^#/ );
		chomp $cline;
		my ( $var, $value ) = split /=/, $cline;
		$_ = $var;
		if ( /cmdfiles/ )
		{
			$cmdfiles[$i][$j] = $value;
			$j++;
		}
		if ( /user/ )
		{
			$user[$i] = $value;
		}
		if ( /password/ )
		{
			$password[$i] = $value;
		}
		if ( /dbname/ )
		{
			$dbname[$i] = $value;
		}
		if ( /nodehost/ )
		{
			$host[$i] = $value;
		}
        }
        $fcfg->close;
}

for (my $i=0; $i<=$#cmdfiles; $i++)
{
	print "\t [ @{$cmdfiles[$i]} ],\n";
}
eval {init_db($user[0], $password[0], $dbname[0], $host[0], @{$cmdfiles[0]})};
if ( $@ )
{
	die "init_db failed: $@\n";
}
else
{
	print ("init_db succeed\n");
}

eval {load_db($user[1], $password[1], $dbname[1], $host[1], @{$cmdfiles[1]})};
if ( $@ )
{
	die ("load_db failed: $@\n");
}
else
{
	print ("load_db succeed\n");
}
eval {backup_db($user[2], $password[2], $dbname[2], $host[2], @{$cmdfiles[2]})};
if ( $@ )
{
	die ("backup_db failed: $@\n");
}
else
{
	print ("backup_db succeed\n");
}
