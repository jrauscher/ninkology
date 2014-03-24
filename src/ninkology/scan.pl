#!/usr/bin/perl

use Archive::Extract;
use strict;
use warnings;
use Cwd qw(abs_path);

chomp (my $licensepl = `find / -name 'license.pl' 2>/dev/null | sed -n 1p`);

require "$licensepl";


# This program takes a file or archive and scans the file or files in the archive
# for open source software licenses using Ninka and FOSSology.
#
# Output for each file looks like:
#   {fileName: <f_val>, LicenseDeclared: <ld_val>, LicenseComment: <c_val>}
#
#   f_val: The name of the file scanned
#          -- If the file was part of an archive, this will include the path
#
#   ld_val: The license found in the file
#           -- If Ninka and FOSSology find the same license, this contains the license name
#           -- None - Both Ninka and FOSSology found no license in the file
#           -- NOASSERTION - There was a mismatch between the output of Ninka and FOSSology
#
#   c_val: Comment on the licenseDeclated.
#          -- Contains the direct outputs of both Ninka and Fossology
#          -- "#Ninka: <Ninka_output> #FOSSology: <FOSSology_output>"



# Usage: scan.pl <options> <archive file name> 
#
# Types of archive files accepted:
# (these are the types supported by the Archive::Extract perl module)
# .tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz
#
# Options:
# -f        Scan with FOSSology
# -n        Scan with Ninka
# -fn       Scan with both (this is the default behaviour)


our $argv_f = 0;            # Command line argument flag for '-f'
our $argv_n = 0;            # Command line argument flag for '-n'

my $archiveExtractor;       # The instance of the Archive::Extract module
my $tmpPathFull;            # The full path to the extraction folder

my $packageName;            # The name of the file or package given
my @files;                  # Holds the file or files in the package

my $receivedArchive = 0;    # Set to 1 if an archive is given

my $ninkaProgram;           # Holds the path to ninka.pl
my $nomosProgram;           # Holds the path to the FOSSology nomos program

my %ninkaToFossHash;        # Holds the hash that maps Ninka output to FOSSology output


if (!$ARGV[0])
{
    die "\nUsage: $0 [options] file\n\n";
}
else
{
    # Get the file to process
    $packageName = $ARGV[-1];

    # Get command line arguments
    foreach my $arg (@ARGV)
    {
        if ($arg eq '-f')
        {
            $argv_f = 1;
        }          
        if ($arg eq '-n')
        {
            $argv_n = 1;
        }                            
    }
    # Default behavior is '-f -n' if neither -f nor -n are selected
    if (!$argv_f and !$argv_n)
    {
        $argv_f = 1;
        $argv_n = 1;
    }
}


# Mute STDERR for a bit (avoids the "error" output when the file is not an archive)
open (my $OLD_STDERR, '>', *STDERR);
open (*STDERR, '>', "/dev/null");

# Set up to scan the files in the archive
if ($archiveExtractor = Archive::Extract->new(archive=>$packageName))
{  
    # Reopen STDERR
    open(*STDERR, '>', $OLD_STDERR);
    close ($OLD_STDERR);
    # Opening *STDERR seems to create fun files
    `rm *STDERR`;
    `rm GLOB*`;

    # Set flag for rm'ing the extracted files later
    $receivedArchive = 1;  
    
    # Attempt to extract the archive
    $archiveExtractor->extract(to => "tmp");
    
    # The full file path to the extraction directory
    $tmpPathFull = $archiveExtractor->extract_path;

    # Change to the extraction directory
    chdir "tmp"; 
    
    # Get the names of the files that are in the archive
    @files = @{$archiveExtractor->files}; 
}
# Set up to scan the single file
else
{
    # Reopen STDERR
    open(*STDERR, '>', $OLD_STDERR);
    close ($OLD_STDERR);
    # Opening *STDERR seems to create fun files
    `rm *STDERR`;
    `rm GLOB*`;
    
    @files = ($packageName);
}


# Set up for the scan
# Find the ninka.pl program
chomp($ninkaProgram = `find / -name 'ninka.pl' 2>/dev/null | sed -n 1p`);

# Find the FOSSology nomos program
chomp($nomosProgram = `find / -name 'nomos' -type f 2>/dev/null | sed -n 1p`);

# Get the hash that maps Ninka output to FOSSology output 
# (subroutine createLicenseHash is located in license.pl)
%ninkaToFossHash = createLicenseHash();


# Do both scans on each file
foreach my $fileName (@files)
{       
    chomp($fileName);
    
    # Check if file is a directory (ie. ends with a "/")
    if ($fileName =~ /.*\/$/)
    {
        # Skip directory entries
        next;
    }   

    
    my $licenseDeclared = "";
    my $licenseComment = ""; 
    my $ninkaResult = "";       # Holds the direct output of Ninka
    my $fossResult = "";        # Holds the direct output of FOSSology
    my @ninkaResults;           # Holds license names from $ninkaResult
    my @fossResults;            # Holds license names from $fossResult
    
    # Scan the file with Ninka
    if ($argv_n)
    {
        $ninkaResult = `perl $ninkaProgram $fileName`;
        if ($ninkaResult =~ /(.*?);(.*?)(?:;|$)/)
        {         
            if ($2 ne 'ERROR')
            {
                $licenseComment .= "#Ninka: $2 ";        

              
                if (!$argv_f)
                {
                    $licenseDeclared = "NOASSERTION";
                }
                else
                {
                    # Store the results for later comparison
                    @ninkaResults = split /,/, $2;
                }
            }
        }
    }   
    # Scan the file with FOSSology
    if ($argv_f)
    {
        $fossResult = `$nomosProgram $fileName`;
        if ($fossResult =~ /File\s(.*)\scontains license\(s\)\s(.*)/) 
        {
            $licenseComment .= "#FOSSology: $2";

            if (!$argv_n)
            {
                $licenseDeclared = "NOASSERTION";
            }
            else
            {
                # Store the results for later comparison
                @fossResults = split /,/, $2;           
            }
        }
    }    
   
    # Compare to see if Ninka and FOSSology found the same license(s) on the file    
    # Ninka found no licenses
    if ($argv_f && $argv_n)
    {
        if ($ninkaResults[0] eq 'NONE')
        {
            # FOSSology also found no licenses
            if ($fossResults[0] eq 'No_license_found')
            {
                $licenseDeclared = "None";
            }
            # FOSSology found some license(s)
            else
            {
                $licenseDeclared = "NOASSERTION";          
            }
        }
        # Ninka gave up
        elsif ($ninkaResults[0] eq 'UNKNOWN')
        {
            $licenseDeclared = "NOASSERTION"
        }
        # Ninka and FOSSology didn't not have the same number of licenses
        elsif (scalar(@ninkaResults) != scalar(@fossResults))
        {
            $licenseDeclared = "NOASSERTION";
        }
        # Ninka and FOSSology found the same number of licenses
        else
        {        
            my $outerMismatchFlag = 0;
            
            # Compare to see if Ninka and FOSSology found the same license(s) on the file
            for (my $x = 0; $x < scalar(@ninkaResults); $x++)
            {      
                # If there is a mapping for this license to FOSSology's licenses
                if ($ninkaToFossHash{$ninkaResults[$x]})
                {
                    # Swap the Ninka result with the FOSSology equivalent
                    $ninkaResults[$x] = $ninkaToFossHash{$ninkaResults[$x]};
                    
                    # Now see if FOSSology also found this license
                    my $innerMismatchFlag = 1;
                    foreach my $y (@fossResults)
                    {
                        if ($ninkaResults[$x] eq $y)
                        {
                            $innerMismatchFlag = 0;
                        }
                    }
                    
                    # One of the licenses found by Ninka was not found by FOSSology
                    if ($innerMismatchFlag)
                    {              
                        $outerMismatchFlag = 1;
                        last;
                    }
                }
                else
                {
                    # One of the licenses found by Ninka is not in the ninkaToFossHash
                    $outerMismatchFlag = 1;
                    last;
                }
            }
            
            # Something didn't match somewhere
            if ($outerMismatchFlag)
            {
                $licenseDeclared = "NOASSERTION";
            }
            # All licenses found by both Ninka and FOSSology match
            else
            {
                # Declare the license(s)
                foreach my $declaredLicense (@ninkaResults)
                {
                    $licenseDeclared .= "$declaredLicense,";
                }
                chop ($licenseDeclared);
            }
        } 
    }
    
    print "{\"fileName\": \"$fileName\", \"licenseDeclared\": \"$licenseDeclared\", \"licenseComment\": \"$licenseComment\"}\n";
}

# Remove the unpacked files if it was an archive
if ($receivedArchive)
{
    `rm -r $tmpPathFull`;
}
