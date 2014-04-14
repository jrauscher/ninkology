#!/usr/bin/perl;

use strict;
use warnings;

################################################################################
# This program runs ninkology.pl and stores the output in a file, in the       #
# results directory                                                            #
#   											  #
# Licence: Apache 2.0                                                          #
#                                                                              #
################################################################################

my @scans;
my $progress = "";
my $givenFile = $ARGV[0];
$givenFile =~ /.*\/(.*)|(.*)/;
my $compareFile = $1;
my $outputFile = $compareFile . ".lic";
my $fileName = "";

chomp(my $scanFiles = `find / -name 'Scans_Completed.txt' 2>/dev/null | sed -n 1p`);
chomp(my $scanProgram = `find / -name 'ninkology.pl' 2>/dev/null | sed -n 1p`);
chomp(my $updateJobs = `find / -name 'update_jobs.pl' 2>/dev/null | sed -n 1p`);
chomp(my $dirResultsFile = `find / -name 'UNQFILE.txt' 2>/dev/null | sed -n 1p`);
chomp(my $dirResults = upOneDirectory($dirResultsFile));  

print "perl $scanProgram $givenFile > $dirResults/$outputFile\n";
`perl $scanProgram $givenFile > $dirResults/$outputFile`;
`chmod 766 $dirResults/$outputFile`;

open(my $fileHandleScans, "<", "$scanFiles") or die "Failed to open file: $!\n";
while(<$fileHandleScans>) { 
    chomp; 
    push @scans, $_;
} 
close $fileHandleScans;

open(SCANS,">$scanFiles") or die "Couldn't open: $!";
	for (my$i=0;$i<scalar(@scans);$i++){
		($fileName,$progress) = $scans[$i] =~ /(.*):(.*)/;
		
		if ($fileName eq $compareFile){
			$progress = "Completed";
			print SCANS "$fileName:$progress\n";
		}
		else {
			print SCANS "$fileName:$progress\n";
		}
	}
close (SCANS);

`perl $updateJobs &`;

# Takes a directory path and simulates "cd .." on it.
# Returns the directory path with the lowest directory removed
sub upOneDirectory{
    my $currentDirectory = shift;
    my $oneUpDirectory = "";
    
    # Given path ends in a slash
    if ($currentDirectory =~ /.*\/$/)
    {
        $currentDirectory =~ /(.*)\/.*\//;
        $oneUpDirectory = $1;
    }
    # Given path does not end in a slash
    else
    {
        $currentDirectory =~ /(.*)\/.*/;
        $oneUpDirectory = $1;
    }
    
    return $oneUpDirectory;
}

