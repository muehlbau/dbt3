#!/usr/bin/perl -w

package Build_db;

use strict;
use vars qw(@ISA @EXPORT);
use FileHandle;
use Exporter;
use SAP::DBTech::repman;
use DBM::Exe_dbm_cmds;
use REPM::Exe_repm_cmds;

=head1 NAME

Build_db.pm

=head1 SYNOPSIS

modules for building sapdb database
init_db: read database parameters from files and create database
load_db: create and load tables
backup_db: define backup medium and backup database

=head1 ARGUMENTS

 -user <user name>
 -password <password>
 -dbname <database name>
 -nodehost <host name of the database node>
 -cmdfiles <command files>

=cut

@ISA = qw(Exporter);
@EXPORT = qw(init_db load_db backup_db);

sub init_db
{
	my ($user, $password, $dbname, $host, @cmdfiles) = @_; 
	my $ftmp;

	print "user $user password $password, dbname $dbname, host $host\n";
	print "cmdfiles ", join(' ',@cmdfiles), "\n";

	# call drop_db.sh to drop the database, we do not check the result
	# since the error might be caused by database not exist
	system("./drop_db.sh");

	# create database, I do not know how to force it not checking 
	# credentials
	# so I call dbmcli directly, and check the result in dbm.out file
	system("dbmcli -s -R /opt/sapdb/depend74 db_create $dbname dbm,dbm 2>&1 | tee dbm.out") && die "system function failed: $!\n";

	$ftmp = new FileHandle;
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
		die "error init_db: $@";
	} 
}

sub load_db
{
	my ($user, $password, $dbname, $host, @cmdfiles) = @_; 
#	print "user $user password $password, dbname $dbname, host $host\n";
#	print "cmdfiles ", join(' ',@cmdfiles), "\n";
	
	# create database user
	my $session;
	# connec to repm
	eval{$session = new RepMan($host, $dbname)};
	if ( $@ )
	{
		die "connecting to RepMan failed: $@";
	}
	else
	{
		print "connected to RepMan server\n";
	}

	eval {$session->cmd ("use user dba dba")};
	if ( $@ )
	{
		die "connecting to RepMan as dba failed: $@";
	}
	else
	{
		print "connected to RepMan server as dba\n";
	}

	print "create user $user password $user dba not exclusive";
	eval {$session->cmd("create user $user password $password dba not exclusive") };
	if ($@) {
		print "-> failed: $@\n";
		$_ = $@;
		if ( !/.*duplicate.*/i )
		{
			die "create user $user password $password failed: $@";
		}
		else
		{
			print "continue...\n";
		}
	}
#	$session->release();

	# execute other commands
	eval{exe_repm_cmds($user, $password, $dbname, $host, @cmdfiles)};
	if ( $@ )
	{
		die "error load_db: $@";
	} 
}

sub backup_db
{
	my ($user, $password, $dbname, $host, @cmdfiles) = @_; 
#	print "user $user password $password, dbname $dbname, host $host\n";
#	print "cmdfiles ", join(' ',@cmdfiles), "\n";

	eval {exe_dbm_cmds($user, $password, $dbname, $host, @cmdfiles)};
	if ( $@ )
	{
		die "error backup_db: $@";
	} 
}

1;
