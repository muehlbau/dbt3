#!/usr/bin/perl -w

package REPM::Exe_repm_cmds;

use strict;
use vars qw(@ISA @EXPORT);
use Exporter;
use SAP::DBTech::repman;

@ISA = qw(Exporter);
@EXPORT = qw(exe_repm_cmds);

# execute repm commands reading from mulitiple files
# @cmdfiles must be the last parameter since it is an array
sub exe_repm_cmds
{
	my ($user, $password, $dbname, $host, @cmdfiles) = @_;
	my $session;

	#connect to repm server
	eval{$session = new RepMan($host, $dbname)};
	if ( $@ )
	{
		die "connecting to RepMan failed: $@";
	}
	else
	{
		print "connected to RepMan server\n";
	}

	eval {$session->cmd ("use user $user $password")};
	if ( $@ )
	{
		die "connecting to RepMan using user $user password $password failed: $@";
	}
	else
	{
		print "connected to RepMan as user $user password $password\n";
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
			if ( $@ ) 
			{
				die " $cmd -> failed: $@";		
			}
			else {print "$cmd -> ok\n"};
		}
	}
#	$session->release();
}	

1;
