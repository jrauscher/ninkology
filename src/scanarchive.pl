#!/usr/bin/perl

use Archive::Extract;
use strict;
use warnings;
use Cwd;

# This program extracts files from an archive to be
# scanned for OSS licenses with Ninka and FOSSology


# Usage: scanarchive.pl <archive file name> <options>
#
# Types of archive files accepted:
# (these are the types supported by the Archive::Extract perl module)
# .tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz
#
# Options:
# -k    Do not delete the extracted directory when the program finishes



#-------------------------------------------------
# Change these three paths to fit your system
# ------------------------------------------------

# The path where the extracted archive will be stored temporarily
my $tempPathLocation = "/tmp/ninkology/archive/";

# The path to the "ninka.pl" program on the system
my $ninka = "/home/unouser/ninka/ninka.pl";

# The path to the FOSSology nomos agent program
my $fossology_nomos = "/usr/share/fossology/nomos/agent/nomos";

# The directory where the output file will be placed
# (the output code will change when we implement a web interface)
my $outputDirectory = "/home/unouser/";



my $argv_keep = 0;

my $archiveExtractor;
my $tempPathFull;
my @findStar;

my $output_ninka;
my $output_foss;

my $startTime = time;

my ($x, $z);



if (!$ARGV[0])
{
    print "\nUsage: $0 <archive file path>\n\n";
    exit;
}

foreach(@ARGV)
{
    if ($_ eq '-k')
    {
        $argv_keep = 1;
    }
}


# Extract the archive to $tempPathLocation
print "\nExtracting from $ARGV[0]...\n";
$archiveExtractor = Archive::Extract->new(archive=>$ARGV[0])
    or die "\nError: '$ARGV[0]' is not recognized as an archive file type\n\n";
$archiveExtractor->extract(to => $tempPathLocation);
$tempPathFull = $archiveExtractor->extract_path;
print "Extracted archive to $tempPathFull.\n\n";


#Open "NINKA_OUTPUT" and "FOSS_OUTPUT" files for output
open($output_ninka, '>', "$outputDirectory/NINKA_OUTPUT.txt");
open($output_foss, '>', "$outputDirectory/FOSS_OUTPUT.txt");


#Get the list of all files in the directory and subdirectories
chdir $tempPathFull;
@findStar = `find *`;


# Process each file
$x = 1;
$z = scalar(@findStar);
print "Running FOSSology/Ninka scan...\n";
foreach (@findStar)
{
    print "\rProcessing file $x/$z...";
    
    # Scan the file with Ninka
    print $output_ninka `perl $ninka $_`;

    # Scan the file with FOSSology
    print $output_foss `$fossology_nomos $_`;
    
    $x++;
}

printf "\n\nScan complete (%s seconds).\n", time - $startTime;




# Clean up
print "\n";
close $output_ninka;
close $output_foss;

if (!$argv_keep)
{
    `rm -r $tempPathFull`;
}
