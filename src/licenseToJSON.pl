#!/usr/bin/perl

use JSON;
use strict;
use warnings;
use Data::Dumper;


my ($fileName,    # The name of the file to process
    $FILE,        # The file handle for opening the file
    $JSON_string  # The JSON representing the files and their licenses
    );

my @lines; # The lines of the opened file


# Get the file name argument
$fileName = $ARGV[-1];

# Open the file
if ($fileName)
{
    open ($FILE, '<', $fileName) or die $!;
    @lines = <$FILE>;
}
else 
{
    die "\nNo license file supplied.\n\n";
}

# Begin the JSON
$JSON_string = "{\n\"files\": [\n";


# Ninka license file
if ($ARGV[0] && $ARGV[0] eq '-n')
{
    my @nDir;

    # Convert the file to a simple JSON format
    foreach(@lines)
    {
        if ($_ =~ /(.*?);(.*?);/)
        {
            if ($2 ne 'ERROR')
            {
                # Take of the directory names preceding the file name
                @nDir = split("/", $1);

                $JSON_string .= "{\"fileName\":\"$nDir[-1]\", \"license\":\"$2\"},\n";
            }
        }
    }
    
    # Take off the last comma/newline
    chomp($JSON_string);
    chop($JSON_string);
    
    $JSON_string .= "\n]\n}";    
}


# Fossology license file
elsif($ARGV[0] && $ARGV[0] eq '-f')
{
    # Convert the file to a JSON format
    foreach(@lines)
    {
        if ($_ =~ /File\s(.*)\scontains license\(s\)\s(.*)/)
        {
            $JSON_string .= "{\"fileName\":\"$1\", \"license\":\"$2\"},\n";
        }
    }
    
    # Take off the last comma/newline
    chomp($JSON_string);
    chop($JSON_string);
    
    $JSON_string .= "\n]\n}";
}
else
{
    print "\nUsage: licenseToJSON.pl [-f or -n] file\n\n";
}
