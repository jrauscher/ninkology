#!/usr/bin/perl

use Archive::Extract;
use Cwd 'abs_path';
use Digest::SHA 'sha1_hex';
use File::Spec;

use strict;
use warnings;

# Ninkology 1.2
# Copyright (C) 2014 Ryan Vanek
# @License: Apache 2.0
#
#
# This program takes a file or archive and scans the file or files in the archive
# for open source software licenses using Ninka and FOSSology.
#
# Output for each file looks like:
#   {"FileName":"<f_val>", "LicenseDeclared":"<ld_val>", "FileLicenseComments":"<c_val>", "FileChecksum":"<sha1_val>", "FileChecksumAlgorithm":"SHA-1"}
#
#   f_val: The name of the file scanned
#          -- If the file was part of an archive, this includes the path
#
#   ld_val: The license found in the file
#           -- This value contains the license name(s) if Ninka and FOSSology find the same license(s), 
#           -- None - Both Ninka and FOSSology found no license in the file
#           -- NOASSERTION - There was a mismatch between the license(s) found by Ninka and FOSSology
#
#   c_val: Comment on the licenseDeclated.
#          -- Contains the direct outputs of both Ninka and Fossology
#          -- "#Ninka: <Ninka_output> #FOSSology: <FOSSology_output>"
#
#   sha1_val: The SHA-1 value of the contents of the file
#          -- Algorithm: perl's sha1_hex()


# Usage: perl ninkology.pl <options> <filename> 
#
# Types of archive files accepted:
# (these are the types supported by the Archive::Extract perl module)
# .tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz
#
# Options:
# -clean    Clear the 'tmp' directory used for scans
# -cp       Cut the file path from file names
# -f        Scan with FOSSology
# -n        Scan with Ninka
# -sha1     Add the SHA-1 of each file to the JSON


my $argv_f = 0;             # Command line argument flag for '-f'
my $argv_n = 0;             # Command line argument flag for '-n'
my $argv_cp = 0;            # Command line argument flag for '-c'
my $argv_sha1 = 0;          # Command line argument flag for '-sha1'

my $archiveExtractor;       # The instance of the Archive::Extract module
my $tmpPackagePath;         # The full path to the extraction folder
my $pwd;                    # The directory where 'ninkology.pl' resides
my $pwdTmp;                 # The tmp directory in $pwd

my $packageName;            # The name of the file or package given
my $actualPackageName;      # The name of the file or package given, sans paths
my @files;                  # Holds the file or files in the package
my $finalOutput;            # The final output JSON printed to STDOUT

my $ninkaProgram;           # Holds the path to ninka.pl
my $nomosProgram;           # Holds the path to the FOSSology nomos program

my $dummy;                  # Dummy variable


# Find where I actually am
$pwd = upOneDirectory(File::Spec->rel2abs($0));
$pwdTmp = "$pwd/tmp";

if (!$ARGV[0])
{
    die "\nUsage: $0 [options] file\n\n";
}
else
{
    # Get the file to process
    $packageName = $ARGV[-1];
    $actualPackageName = cutPaths($packageName);
    
    # Get command line arguments
    foreach my $arg (@ARGV)
    {      
        # Add SHA-1 to the output for each file
        if ($arg eq '-sha1')
        {
            $argv_sha1 = 1;
        }
    
        # Cut file paths from file names
        elsif ($arg eq '-cp')
        {
            $argv_cp = 1;
        }
    
        # Scan with only FOSSology
        elsif ($arg eq '-f')
        {
            $argv_f = 1;
        }
        
        # Scan with only Ninka
        elsif ($arg eq '-n')
        {
            $argv_n = 1;
        }        

        # Remove the stuff created by ninkology.pl
        elsif ($arg eq '-clean')
        {
            print "\n";
            if (-d "$pwdTmp")
            {               
                `rm -r $pwdTmp`;   
                print "Removed 'tmp' directory.\n";
            }
            if (-e "$pwd/config.ninkology")
            {
                `rm $pwd/config.ninkology`;
                print "Removed config.ninkology.\n";
            }
            print "\n";
            exit;
        }
        
        # Print out help
        elsif ($arg eq '-h' || $arg eq '-help' || $arg eq '--help')
        {
            print "\n\n";
            print "Usage: $0 [options] file\n\n";
            print "Options:\n";       

            print "-c\t\tCut the file path from file names\n";
            print "-clean\t\tClear the 'tmp' directory used for scans\n";
            print "-f\t\tScan with only FOSSology\n";
            print "-n\t\tScan with only Ninka\n";                      
            print "-sha1\t\tAdd the SHA-1 of each file to the JSON\n";

            print "\n\n";
            
            exit;
        }
    }
    
    # Default behavior is scan with both if neither -f nor -n is selected
    if (!$argv_f and !$argv_n)
    {
        $argv_f = 1;
        $argv_n = 1;
    }
}






# Test if the file/package exists
my $exists = `test -f $packageName && echo 1 || echo 0`;
# The file or package name given does not exist
if ($exists == 0)
{
    die "\nThe file or package name given ('$packageName') does not exist.\n\n";  
}

# Test if a scan is already running on this package name
if (-d "$pwdTmp/$actualPackageName")
{
    # Potential scan in progress
    print "\nA package with an identical name ('$actualPackageName') might already be in the process of being scanned.\n";
    print "This can also occur if you have killed a running scan of this package before it finished.\n";
    print "Do you want to continue anyway? (y/n)\n";
    
    chomp(my $choice = <STDIN>);
    
    if ($choice eq 'y' || $choice eq 'yes')
    {
        `rm -r $pwdTmp/$actualPackageName`;
    }
    else
    {
        exit;
    }
}






# Check if config file already exists
if (-e "$pwd/config.ninkology")
{
    open(my $autoconf, '<', "$pwd/config.ninkology");
    
    # Get the ninka path and nomos path from the config file
    foreach my $line (<$autoconf>)
    {
        if ($line =~ /ninkaPath\s*=\s*'(.*)'/)
        {
            $ninkaProgram = $1;
        }
        
        if ($line =~ /fossPath\s*=\s*'(.*)'/)
        {
            $nomosProgram = $1;
        }
    }
    
    close ($autoconf);
}
# Find the ninka and nomos programs and create a config file to store their locations
else
{     
    # Set up for the scan
    # Find the ninka.pl program
    chomp($ninkaProgram = `find / -name 'ninka.pl' 2>/dev/null | sed -n 1p`);
    
    # Find the FOSSology nomos program
    chomp($nomosProgram = `find / -name 'nomos' -type f 2>/dev/null | sed -n 1p`);
    
    # Save the paths for future scans
    open (my $autoconf, '>', "$pwd/config.ninkology") or die $!;
    print $autoconf "ninkaPath = '$ninkaProgram'\n"; 
    print $autoconf "fossPath = '$nomosProgram'";
    close ($autoconf);
}









if (-B $packageName)
{
    # Set up to scan the files in the archive
    if ($archiveExtractor = Archive::Extract->new(archive=>$packageName))
    {          
        # The path to the extraction directory
        $tmpPackagePath = "$pwdTmp/$actualPackageName";
        
        # Remove double slashes from the path because they look ugly
        $tmpPackagePath =~ s#//#/#g;
        
        # Attempt to extract the archive
        $archiveExtractor->extract(to => "$tmpPackagePath");

        # Change to the extraction directory
        chdir "$tmpPackagePath"; 
        
        # Get the names of the files that are in the archive
        @files = @{$archiveExtractor->files}; 
    }
}
# Set up to scan the single file
else
{       
    @files = ($packageName);
    
    # Create "tmp" if it doesn't exist
    if (!-e "$pwdTmp")
    {
        mkdir "$pwdTmp";
    }   
    
    # Create a tmp directory and copy file to it    
    mkdir "$pwdTmp/$actualPackageName";
    `cp $packageName $pwdTmp/$actualPackageName`;
    chdir "$pwdTmp/$packageName";   
}












# Counter variables
my $x = 1;
my $z = scalar(@files);

$finalOutput = "{\n";

# Do both scans on each file
foreach my $fileName (@files)
{   
    print STDERR "\rProcessing file $x/$z...";
    $x++;
    $| = 1;

 
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
    
    my $sha1 = "";              # The SHA-1 of the file
    
    my @ninkaResults;           # Holds license name(s) from $ninkaResult
    my @fossResults;            # Holds license name(s) from $fossResult
    
    
    
    
    # Add the SHA-1
    if ($argv_sha1)
    {             
        open(my $file, '<', $fileName);
        $sha1 = sha1_hex(<$file>);
        close ($file);
    }
    
    
    
    # Scan the file with Ninka
    if ($argv_n)
    {
        # Run the scan
        $ninkaResult = `perl $ninkaProgram $fileName`;
        
        # Make sure the result came back OK
        if ($ninkaResult =~ /(.*?);(.*?)(?:;|$)/)
        {         
            if ($2 ne 'ERROR')
            {
                $licenseComment .= "#Ninka: $2 ";        
        
                if (!$argv_f)
                {
                    # Declare the license(s) found by Ninka if only scanning with Ninka
                    $licenseDeclared = $2;
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
        # Run the scan
        $fossResult = `$nomosProgram $fileName`;
        
        # Make sure the scan came back OK
        if ($fossResult =~ /File\s(.*)\scontains license\(s\)\s(.*)/) 
        {
            $licenseComment .= "#FOSSology: $2";

            if (!$argv_n)
            {
                # Declare the license(s) if only scanning with FOSSology
                $licenseDeclared = $2;
            }
            else
            {
                # Store the results for later comparison
                @fossResults = split /,/, $2;           
            }
        }
    }    
   
   
    # Cut the path from the file name
    if ($argv_cp)
    {
        $fileName = cutPaths($fileName);
    }
    
   
    # Compare to see if Ninka and FOSSology found the same license(s) on the file    
    # If the file/archive was scanned with both Ninka and FOSSology
    if ($argv_f && $argv_n)
    {
        # Ninka found no licenses
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
        # Ninka and FOSSology did not find the same number of licenses
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
                my $innerMismatchFlag = 1;
                
                # Check if FOSSology found this license
                for (my $y = 0; $y < scalar(@fossResults); $y++)
                {
                    if ($ninkaResults[$x] eq $fossResults[$y])
                    {
                        $innerMismatchFlag = 0
                    }
                }
                
                # FOSSology did not find this license
                if ($innerMismatchFlag)
                {
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
                foreach my $declaredLicense (@fossResults)
                {
                    $licenseDeclared .= "$declaredLicense,";
                }
                # Remove the last comma
                chop ($licenseDeclared);
            }
        } 
    }
    
    # Added the results to the final JSON
    if ($licenseDeclared eq "")
    {}
	else
    {
        # If there is no SHA-1, don't include in output
        if ($sha1 eq '')
        {
            $finalOutput .= "{\"FileName\":\"$fileName\", \"LicenseDeclared\":\"$licenseDeclared\", \"FileLicenseComments\":\"$licenseComment\"},\n";
        }       
        else
        {
            $finalOutput .= "{\"FileName\":\"$fileName\", \"LicenseDeclared\":\"$licenseDeclared\", \"FileLicenseComments\":\"$licenseComment\", \"FileChecksum\":\"$sha1\", \"FileChecksumAlgorithm\":\"SHA-1\"},\n";
        }
    }
}


# Print out the final output
chomp($finalOutput);
chop($finalOutput);
$finalOutput .= "\n}";
print STDERR "\n";
print $finalOutput;
print STDERR "\n";


# Remove the stuff from 'tmp' directory
chdir "$pwdTmp";
$packageName = cutPaths($packageName);    
`rm -r $pwdTmp/$packageName`;















#-----------------------------
# subroutines
#-----------------------------

# Take a path and cut everything but the last part
# 'ex' will return 'ex'
# 'path/ex/' will return 'ex'
# '/path/ex' will return 'ex'
# '/path/ex/' will return 'ex'
sub cutPaths
{
    my $filePath = shift;
        
    # If the path contains one or more '/'
    if ($filePath =~ /(?:.*)\/(.*)/)
    {
        # Path ends in a '/'
        if ($1 eq '')
        {
            $filePath =~ /(?:.*)\/(.*)\//;
            return $1;
        }
        else
        {
            return $1;
        }
        
    }
    # Just return the name
    else
    {
        return $filePath;
    }   
}



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
