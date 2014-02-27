#!/usr/bin/perl -w

use CGI qw/:standard/;
use CGI::Carp qw/fatalsToBrowser/;
use File::Basename;
use Template;
import sys;

# This program gets files that the user uploads to the browser
# Then sends them to a scanner program to be scanned by Ninka and FOSSology

# Types of archive files accepted:
# (these are the types supported by the Archive::Extract perl module)
# .tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz
#

my $formtt = "results.tt";
my $safe_filename_characters = "a-zA-Z0-9_.-";        #Does not allow some special characters in filename
my $upload_dir = "uploads";                           #Directory where the files are saved
my $query = new CGI;                                  #Creates CGI Object
my $email = $query->param("email");
my $filename = $query->param("package");              #Gets file name from the form.

$eTitle = "Ninkology Results";
$eBody = "Your results would be here once we finish!";

system("/bin/bash /var/www/email.sh '$eBody' '$eTitle' $email");

#Variables that will be sent to the results.tt page.
my $vars = { 
	packageName => $filename, 
};

print $query->header();

#Makes sure file is not of length 0, no maximum size is curretnly set.
if ( !$filename )
{
	print "There was a problem uploading your package.";
	exit;
}
#-------------------------------------------------------------------------------


#Splits the entire fillname sent to browser into, name, path and extention.
my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;                                           #Converts whitespace to underscores in filename.
$filename =~ s/[^$safe_filename_characters]//g;                 #Removes special charcters from the filename
#-------------------------------------------------------------------------------


#If file contains invalid characters, print an error.
if ( $filename =~ /^([$safe_filename_characters]+)$/ ){
	$filename = $1;
} else {
	die "Filename contains invalid characters";
}
#-------------------------------------------------------------------------------

#Saves the file
my $upload_filehandle = $query->upload("package");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;


while ( <$upload_filehandle> ){
	print UPLOADFILE;
}
close UPLOADFILE;
#-------------------------------------------------------------------------------




#Ryan code
# Change the permissions on the package so it can be opened
#chmod 0755,"/var/www/cgi/uploads/$filename";
#mkdir "/var/www/processed/$filename";
#chmod 0777, "/var/www/processed/$filename";
# Do the scan on the package
#`/opt/scanarchive.pl -w /var/www/cgi/uploads/$filename`;;




my $template = Template->new();
$template->process ( $formtt, $vars ) || die "Template process failed: ", $template->error(), "\n";
