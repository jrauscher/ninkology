#Ninkology
###Version:
1.2

###System Overview:
Ninkology works to enhance the open source software license identification process by combining the license scan results of Ninka and FOSSology, which are two open source software license identification tools.<br/>

###Copyright information:
Ninkology is copyrighted by Ryan Vanek, Jordan Rauscher, and Ninh Nguyen (2014).<br/>

###License information:
The Ninkology documentation is licensed under CC BY-SA 3.0 US (https://creativecommons.org/licenses/by-sa/3.0/us/)<br/>
The source code of Ninkology is licensed under Apache 2.0 (http://www.apache.org/licenses/LICENSE-2.0)<br/>

-----------------------------------------------------------------------

###Installation information:
####Pre-installation:
Install FOSSology 2.4 (http://www.fossology.org/projects/fossology/wiki/Ubuntu_Install_2_4)<br/>
Install Ninka 1.1 (just have it located somewhere on the machine) (http://ninka.turingmachine.org/download/)<br/>
Install Perl 5.14.2, PHP 5.3.10-1ubuntu3.9<br/>
Install the required Perl modules (Archive::Zip)(http://search.cpan.org/~phred/Archive-Zip-1.37/lib/Archive/Zip.pm)<br/>


#### Installation of Ninkology
Place the /src/ninkology.pl file wherever you want to run Ninkology from.<br/>

-----------------------------------------------------------------------

###Code contribution management:
Source code changes are committed to the GitHub repository at https://github.com/ryanv09/ninkology <br/>
Users may submit bugs/issues to the Github issue tracker at https://github.com/ryanv09/ninkology/issues<br/>
For further information, please contact Matt Germonprez at germonprez@gmail.com<br/>

###Stakeholder communities:
SPDX<br/>
FOSSology<br/>
Ninka<br/>

###Communication:
Github: https://github.com/ryanv09/ninkology<br/>
Further inquiries: Ninkology team (ninkology@gmail.com) or Matt Germonprez (germonprez@gmail.com)<br/>

-----------------------------------------------------------------------

###Technical Specification:
#### Software:
Operating system: Ubuntu 12.04 LTS<br/>
Programing languages: Perl 5.14.2, PHP 5.3.10-1ubuntu3.9<br/>
Third-party software: FOSSology (requires PHP 5.6 and Postgre SQL 9.1) and Ninka<br/>


#### Required Perl Modules:
Archive::Zip (http://search.cpan.org/~phred/Archive-Zip-1.37/lib/Archive/Zip.pm)<br/>


#### Hardware (recommended minimum requirements):
CPU: 2.5GHz processor<br/>
RAM: 4GB<br/>
HDD: 500 GB<br/>

-----------------------------------------------------------------------

###Usage:
Types of archive files accepted:
(these are the types supported by the Archive::Extract perl module)
.tar, .tgz, .gz, .Z, .zip, .bz2, .tbz, .lzma, .xz, .txz


<pre>
perl ninkology.pl [options] [filename]
or
./ninkology.pl [options] [filename]

options:
-clean        Remove the 'tmp' directory and config file created by ninkology.pl
-cp           Cut file paths from file names in output
-f            Scan the file/package with only FOSSology
-n            Scan the file/package with only Ninka
-sha1         Add the SHA-1 of each file to the output


<b>Output:</b>
The output of ninkology is JSON for each file in the format:

“{"FileName":"[file]", "LicenseDeclared":"[license]", "FileLicenseComments":"[comment]"}
or
“{"FileName":"[file]", "LicenseDeclared":"[license]", "FileLicenseComments":"[comment]", "FileChecksum":"[sha1]", "FileChecksumAlgorithm":"SHA-1"}”

[file]        -- The name of the file provided
              -- Contains paths relative to the archive unless the '-cp' argument is used

[license]     -- The license(s) found by Ninka and FOSSology if the results match.
              -- The license(s) found by Ninka or FOSSology if only one scan is used.
              -- “NOASSERTION” if the results of Ninka and FOSSology did not match.
              -- “None” if Ninka and FOSSology both found no license information in the file.
              
[comment]     -- The direct output given by Ninka and FOSSology in the form:
                 “#Ninka: [ninka_output] #FOSSology: [FOSSology_output]”
                 
[sha1]        -- Contains the SHA-1 of the contents of the file (using perl's sha1_hex())
              -- "FileChecksum" and "FileChecksumAlgorithm" are only present if the '-sha1' command line argument is used.
              
</pre>        