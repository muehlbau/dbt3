#!/usr/bin/perl -w

package DBM::Exe_dbm_cmds;

use strict;
use vars qw(@ISA @EXPORT);
use Exporter;
use SAP::DBTech::dbm;

@ISA = qw(Exporter);
@EXPORT = qw(exe_dbm_cmds);

# execute dbm commands reading from mulitiple files
# @cmdfiles must be the last parameter since it is an array
sub exe_dbm_cmds
{
	my ($user, $password, $dbname, $host, @cmdfiles) = @_;

	my $session;

	#connect to dbm server
	eval {$session = new DBM($host, $dbname,'',"$user,$password")};
	if ( $@ )
	{
		die "connecting to dbm server failed: $@";
	}
	else
	{
		print "connected to dbmserver\n";
	}
	
	# read command from command files 
	for (my $i=0; $i<=$#cmdfiles; $i++)
	{
		my (@commands, $fcmd, $cmd);
		$fcmd = new FileHandle;
		unless ( $fcmd->open( "< $cmdfiles[$i]" ) )   
			{ die "open file $cmdfiles[$i] failed $!"; }
		@commands=(<$fcmd>);
		chomp(@commands);
		close($fcmd);
	
		print "$#commands commands\n";
		foreach $cmd (@commands) {
			eval {$session->cmd("$cmd") };
			if ($@) 
			{
				die "$cmd -> failed: $@\n";		
			}
			else {print "$cmd -> ok\n"};
		}
	}
#	$session->release();
}	

1;
