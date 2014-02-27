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
# -w	Called from the web interface. Changes output to html



#-------------------------------------------------
# Change these file paths to fit your system
# ------------------------------------------------

# The path where the extracted archive will be stored temporarily
my $tempPathLocation = "/tmp/ninkology/archive/";

# The path to the "ninka.pl" program on the system
my $ninka = "/opt/ninka/ninka.pl";

# The path to the FOSSology nomos agent program
my $fossology_nomos = "/usr/share/fossology/nomos/agent/nomos";



my $argv_keep = 0;
my $argv_web = 0;

my $archiveExtractor;
my $tempPathFull;
my @findStar;

my $output_ninka;
my $output_foss;

my $startTime = time;

my ($x, $z);



if (!$ARGV[0])
{
    print "\nUsage: $0 <options> <archive file path>\n\n";
    exit;
}

foreach(@ARGV)
{
    # Keep the /tmp/ninkology/archive directory after the scan
    # This causes bugs with the web interface
    if ($_ eq '-k')
    {
        $argv_keep = 1;
    }

    # Web interface call (probably won't be kept around)
    if ($_ eq '-w')
    {
        $argv_web = 1;
    } 
}


# Extract the archive to $tempPathLocation
print "\nExtracting from $ARGV[-1]...\n";
$archiveExtractor = Archive::Extract->new(archive=>$ARGV[-1])
    or die "\nError: '$ARGV[-1]' is not recognized as an archive file type\n\n";
$archiveExtractor->extract(to => $tempPathLocation);
$tempPathFull = $archiveExtractor->extract_path;
print "Extracted archive to $tempPathFull.\n\n";


#Open "NINKA_OUTPUT" and "FOSS_OUTPUT" files for output
if ($argv_web)
{
    $ARGV[-1] =~ /.*\/(.*)/;
    open($output_ninka, '>', "/var/www/processed/$1/NINKA_OUTPUT.html");
    open($output_foss, '>', "/var/www/processed/$1/FOSS_OUTPUT.html");

    chmod 0755, "/var/www/processed/$1/NINKA_OUTPUT.html";
    chmod 0755, "/var/www/processed/$1/FOSS_OUTPUT.html";
}
else
{
    open($output_ninka, '>', "$ENV{HOME}/Ninka_out.txt") or die $!;
    open($output_foss, '>', "$ENV{HOME}/FOSSology_out.txt") or die $!;
}

#Get the list of all files in the directory and subdirectories
chdir $tempPathFull;
@findStar = `find *`;


# Process each file
$x = 1;
$z = scalar(@findStar);

if ($argv_web)
{
    print $output_ninka "<pre>";
    print $output_foss "<pre>";
}

print "Running FOSSology/Ninka scan...\n";
foreach (@findStar)
{
    printf "\rProcessing file %s/%s...", $x, $z;
    
    # Scan the file with Ninka
    print $output_ninka `perl $ninka $_`;

    # Scan the file with FOSSology
    print $output_foss `$fossology_nomos $_`;
    
    $x++;
}

if ($argv_web)
{
    print $output_ninka "</pre>";
    print $output_foss "</pre>";
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
