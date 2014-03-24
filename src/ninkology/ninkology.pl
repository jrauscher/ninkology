#!/usr/bin/perl

use warnings;
use strict;
use Cwd qw(abs_path);
use Email::Valid;


my $emailAddress;

my $argv_m = 0;     # Mail to an e-mail address (eg. '-m ex@example.com')
my $argv_spdx = 0;  # Generate SPDX output
my $arguments = ""; # Command line arguments to pass to 'scan.pl'

my $fileName;


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
            print "-m <address>\tSend an e-mail to <address> with the scan results\n";
            print "-f\t\tScan with FOSSology only\n";
            print "-n\t\tScan with Ninka only\n";
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
