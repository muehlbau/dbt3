#!/usr/bin/perl -w

use CGI;
use strict;

my $chart = new CGI;
my ($name, @value, $path);

print $chart->header("text/html");

foreach $name ($chart->param) {
	if ($name eq "pathname") { $path= $chart->param('pathname');} 
	if ($name eq "png")
	{
		@value=$chart->param($name);
		print $chart->start_html;
		for (my $j=0; $j<= $#value; $j=$j+2)
		{
			if ($value[$j+1]) 
			{
				print $chart->table($chart->Tr([
				$chart->td($chart->img({-src=>"$path/$value[$j]"}, $value[$j])),
				$chart->td($chart->img({-src=>"$path/$value[$j+1]"}, $value[$j+1]))]
					));
			}
			else {
				print $chart->table($chart->Tr([
				$chart->td($chart->img({-src=>"$path/$value[$j]"}, $value[$j]))]));
			}
		}
	}
}

exit(0);
