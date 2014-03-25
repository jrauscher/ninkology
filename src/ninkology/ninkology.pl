#!/usr/bin/perl

use warnings;
use strict;
use Cwd qw(abs_path);
use Email::Valid;


# Copyright (C) 2014 Ryan Vanek
# License: Apache 2.0
#
# This program is the intended entry point for Ninkology.
#
# It calls scan.pl with the given arguments and then either prints out the results
# of the scan or e-mails the results depending on the options given
#


# Usage: ninkology.pl <options> <filename> 
#
# Types of archive files accepted:
# (these are the types supported by the Archive::Extract perl module)
# .tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz
#
# Options:
# -f            Scan with only FOSSology
# -n            Scan with only Ninka
# -fn           Scan with both (this is the default behaviour)
#
# -m <address>  E-mail the results to <address> instead of printing to STDOUT

my $argv_m = 0;     # Mail to an e-mail address (eg. '-m ex@example.com')
my $arguments = ""; # Command line arguments to pass to 'scan.pl'

my $fileName;       # The name of the file/archive to process
my $emailAddress;   # The e-mail address to mail to if '-m' is used


if (!$ARGV[0])
{
    die "Usage: $0 [options] file\n\n";
}
else
{
    # Get the file to process
    $fileName = $ARGV[-1]; 

    # Get the command line arguments
    for (my $x = 0; $x < scalar(@ARGV); $x++)
    {
        # Send e-mail with results
        if ($ARGV[$x] eq '-m')
        {
            $argv_m = 1;
            
            # Get the e-mail address
            $x++;
            $emailAddress = $ARGV[$x]; 
            
            # Check is the address is value
            if (Email::Valid -> address($emailAddress) ? 0 : 1)
            {
                die "\nArgument '-m' must be followed by a valid e-mail address\n\n";
            }
        }
        
        # Print out help
        if ($ARGV[$x] eq '-h' || $ARGV[$x] eq '-help' || $ARGV[$x] eq '--help')
        {
            print "\n\n";
            print "Usage: $0 [options] file\n\n";
            print "Options:\n";            
            print "-f\t\tScan with only FOSSology\n";
            print "-n\t\tScan with only Ninka\n";
            print "-m <address>\tE-mail the results to <address> instead of printing to STDOUT\n";
            print "\n\n";
            exit;
        }
        
        # Scan with Ninka
        if ($ARGV[$x] eq '-f')
        {
            $arguments .= "-f ";
        }
        
        # Scan with FOSSology
        if ($ARGV[$x] eq '-n')
        {
            $arguments .= "-n ";
        }
    }
}


# Find the scan.pl script
chomp(my $scanProgram = `find / -name 'scan.pl' 2>/dev/null | sed -n 1p`);

# Find the mail.sh script
chomp(my $mailScript = `find / -name 'email.sh' 2>/dev/null | sed -n 1p`);


# Open a pipe for the scan.pl program
open (my $scanPipe, "perl $scanProgram $arguments $fileName |");

# Add each line output by the scan.pl pipe to $JSON
my $JSON = "";
while (<$scanPipe>)
{   
    $JSON .= $_;        # Add the line to $JSON
    print STDERR ".";   # Print to show progress (to STDERR to avoid clutter in STDOUT)
    $| = 1;             # Flush output because no newline
}
close $scanPipe;
print "\n";


if ($argv_m)
{
    # Send e-mail with result
    print "Mailing to $emailAddress...\n";   

    my $eTitle = "Ninkology scan results";
    `sh $mailScript '$JSON' '$eTitle' '$emailAddress'`;
}
else
{
    # Print result to STDOUT
    print $JSON;
}
