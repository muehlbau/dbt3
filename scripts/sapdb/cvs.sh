#!/bin/bash
cvs diff -u 2>/dev/null | perl -ne 'print "CVS: $_" unless /^\?/' >> $1
exec vi $1
