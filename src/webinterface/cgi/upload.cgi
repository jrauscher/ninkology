#!/usr/bin/perl -w

use CGI qw/:standard/;
use CGI::Carp qw/fatalsToBrowser/;
use File::Basename;
use Email::Valid;
import sys;

################################################################################
# This program gets files that the user uploads to the browser                 #
# Then sends them to a scanner program to be scanned by Ninka and FOSSology    #
#                                                                              #
# Types of archive files accepted:                                             #
# (these are the types supported by the Archive::Extract perl module)          #
# .tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz                      #
#                                                                              #
# Licence: Apache 2.0                                                          #
#                                                                              #
################################################################################
chomp(my $scanProgram = `find / -name 'ninkology.pl' 2>/dev/null | sed -n 1p`);
chomp(my $pipe_scan = `find / -name 'pipe_scan.pl' 2>/dev/null | sed -n 1p`);  #Finds the pipe_scan.pl program
chomp (my $upload = upOneDirectory(upOneDirectory($scanProgram)));              #Gets the location the program is running in
chomp(my $updateJobs = `find / -name 'update_jobs.pl' 2>/dev/null | sed -n 1p`);
chomp(my $scans = `find / -name 'Scans_Completed.txt' 2>/dev/null | sed -n 1p`);
$upload = $upload . "/cgi/uploads";                   #Upload directory location
my $upload_dir = "/tmp";                              #Upload directory location


my $safe_filename_characters = "a-zA-Z0-9_.-";        #Does not allow some special characters in file name
my $query = new CGI;                                  #Creates CGI Object
my $filename = $query->param("package");              #Gets file name from the form
my $error = 0;      					     #Flag to check for errors
my $Jobs;

print $query->header();

#Makes sure file is not of length 0, no maximum size is currently set.
if ( !$filename ) {
	$error = 1;
	&error("Invalid file name.");
	exit;
}


#Splits the entire fillname sent to browser into, name, path and extention.
my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;                                           #Converts white space to underscores in file name.
$filename =~ s/[^$safe_filename_characters]//g;                 #Removes special characters from the file name


#Checks if the file contains invalid characters.
if ( $filename =~ /^([$safe_filename_characters]+)$/ ){
	$filename = $1;
} else {
	$error = 1;
	&error("Invalid file name.");
	exit;
}


#Saves the file that was uploaded
my $upload_filehandle = $query->upload("package");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> ){
	print UPLOADFILE;
}
	`chmod 766 $upload_dir/$filename`;
close UPLOADFILE;

#Makes sure no errors happened before processing
if ($error != 1){ 		
	&results();
	exit;
}

#If an error occurred this function is ran, taking you to an error page.
sub error {	
	my $errorMessage = shift(@_);
	
	my $html = qq{

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"> 

	<html>
		<head>
			<title>Ninka FOSSology</title>
			<link rel="stylesheet" type="text/css" href="http://spdxdev.ist.unomaha.edu/ninkology/my.css" />
		</head>

	<body>
		<div class="span">
			<div class="mid-span">
				<div class="header">
				</div><!--header-->
				
				<div class="menu">
					Ninka FOSSology
				</div><!--menu-->
				
				<div class="transition">
				</div>
				
				<div class="content">
					<p>
					There was a issue with your request.<br/>
					Problem: $errorMessage<br/><br/>
				
					Please try again:
					<a href="../index.html">Back to home page</a>
					</p>
				</div><!--content-->
				
				<div class="footer">
					<p></p>
				</div><!--Footer-->

			</div><!--mid-span-->
		</div><!--span-->
	</body>

	</html>};
	
	print $html;
}

sub results {

	open (SCANS, ">>$scans") or die "Couldn't open: $!";
                print SCANS "$filename:Working...\n";
	close (SCANS);
	
	`perl $updateJobs &`;
	
	my $html = qq{

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"> 

	<html>
		<head>
			<title>Ninka FOSSology</title>
			<link rel="stylesheet" type="text/css" href="http://spdxdev.ist.unomaha.edu/ninkology/my.css" />
		</head>

	<body>
		<div class="span">
			<div class="mid-span">
				<div class="header">
				</div><!--header-->

				<div class="menu">
					Ninka FOSSology
				</div><!--menu-->

				<div class="transition">
				</div>

				<div class="content">
					<p>
					Thank you for submitting your file $filename. <br/><br/>
					
					Your file will be availble at (May take a few minutes):
					<a href="jobs.html">Jobs</a>
					
					<br/>
					Or you can subbmit another file:
					<a href="http://spdxdev.ist.unomaha.edu/ninkology/">Home</a>
					
					</p>
				</div><!--content-->

				<div class="footer">
					<p></p>
				</div><!--Footer-->

			</div><!--mid-span-->
		</div><!--span-->
	</body>

	</html>};

	print "$html";
	
	`perl $pipe_scan /tmp/$filename &`;
}

# Takes a directory path and simulates "cd .." on it.
# Returns the directory path with the lowest directory removed.
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





