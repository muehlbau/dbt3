#!/usr/bin/perl 

use CGI;
use strict;

my $cgi = new CGI;

print $cgi->header("text/html");

print "<HTML><BODY><P>Hello world!</P></BODY></HTML>\n\n\n";


exit(0);

