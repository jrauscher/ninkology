#!/usr/bin/perl;

use strict;
use warnings;

################################################################################
# This program generates a new job.html file with the updated scan data        #
#   											  #
# Licence: Apache 2.0                                                          #
#                                                                              #
################################################################################

my @scans;
chomp(my $scanFiles = `find / -name 'Scans_Completed.txt' 2>/dev/null | sed -n 1p`);
chomp(my $jobshtml = `find / -name 'jobs.html' 2>/dev/null | sed -n 1p`);
chomp(my $dirResultsFile = `find / -name 'UNQFILE.txt' 2>/dev/null | sed -n 1p`);
chomp(my $dirResults = upOneDirectory($dirResultsFile));  

open(my $fileHandleScans, "<", "$scanFiles")
    or die "Failed to open file: $!\n";
while(<$fileHandleScans>) { 
    chomp; 
    push @scans, $_;
} 
close $fileHandleScans;

my $table = qq{<table class="gridtable"><tr><th>File Name</th><th>Progress</th></tr>};
my $fileName = "";
my $progress = "";

for (my$i=0;$i<scalar(@scans);$i++){
	($fileName,$progress) = $scans[$i] =~ /(.*):(.*)/;
	$table .= "<tr><td><a href='../results/$fileName.lic'>$fileName</a></td><td>$progress</td></tr>"; 
	print "$scans[$i]\n";
}

$table .= "</table>";

	my $html = qq{

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"> 

	<html>
		<head>
			<title>Ninka FOSSology</title>
			<link rel="stylesheet" type="text/css" href="http://spdxdev.ist.unomaha.edu/ninkology/my.css" />
			
			<style type="text/css">
				table.gridtable {
					font-family: verdana,arial,sans-serif;
					margin-left: auto;
					margin-right: auto;
					font-size:11px;
					color:#333333;
					border-width: 1px;
					border-color: #666666;
					border-collapse: collapse;
				}
				table.gridtable th {
					border-width: 1px;
					padding: 8px;
					border-style: solid;
					border-color: #666666;
					background-color: #dedede;
				}
				table.gridtable td {
					border-width: 1px;
					padding: 8px;
					border-style: solid;
					border-color: #666666;
					background-color: #ffffff;
				}
			</style>
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
					<br/><br/><br/>
					<a href="../index.html">Home</a> :
					<a href="jobs.html">Jobs</a>
				</div>
				
				<div class="content">
					<div class = "content" style="height:450px;width:400px;border:1px solid #ccc;font:16px/26px Georgia, Garamond, Serif;overflow:auto; margin-left: auto; margin-right: auto;">						
						$table
					</div>
				</div><!--content-->
				
				<div class="footer">
					<p></p>
				</div><!--Footer-->

			</div><!--mid-span-->
		</div><!--span-->
	</body>

	</html>};

open(JOBS,">$jobshtml") or die "Couldn't open: $!";
	print JOBS "$html";
close (JOBS);

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

#print "$html";
