Ninkology
#Ninkology
###Version:
1.0

###System Overview:
Ninkology works to enhance the open source software license identification process by combining the license scan results of Ninka and FOSSology, which are two open source software license identification tools.

###Copyright information:
Ninkology is copyrighted by Ryan Vanek, Jordan Rauscher, and Ninh Nguyen (2014).

###License information:
The Ninkology documentation is licensed under CC BY-SA 3.0 US (https://creativecommons.org/licenses/by-sa/3.0/us/)

The code of Ninkology is licensed under Apache 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###Installation information:
Install FOSSology 2.4 (http://www.fossology.org/projects/fossology/wiki/Ubuntu_Install_2_4)

Install Ninka 1.1 (just have it located somewhere on the machine) (http://ninka.turingmachine.org/download/)

Install Perl 5.14.2, PHP 5.3.10-1ubuntu3.9, and Apache 2.4

Place the files located in src/ninkology/ wherever you want to run Ninkology from.

##### Installation of the web interface
Install mailutils, sharutils, ssmtp (or use existing mail server)

Place the files in src/webinterface/ into an apache directory (default: /var/www/)

###Code contribution management:
Source code changes are commited to the GitHub repository at https://github.com/ryanv09/ninkology 

Bugs and issues with the system will be tracked in the Github issue tracker at https://github.com/ryanv09/ninkology/issues 

For further information, please contact Matt Germonprez at germonprez@gmail.com

###Stakeholder communities:
SPDX

FOSSology

Ninka

###Communication:
Github: https://github.com/ryanv09/ninkology

Further inquiries: Ninkology team (ninkology@gmail.com) Matt Germonprez (germonprez@gmail.com)

###Live instance of the Ninkology software available:
http://spdxdev.ist.unomaha.edu/ninkology/

###Technical Specification:
#### Software:
Operating system: Ubuntu 12.04 LTS

Mail server: mailutils, sharutils, ssmtp (for the mail server)

Programing languages: Perl 5.14.2, PHP 5.3.10-1ubuntu3.9

Web server: Apache Web Server 2.4

Third-party software: FOSSology (requires PHP 5.6 and Postgre SQL 9.1) and Ninka


#### Required Perl Modules:
Archive::Zip (http://search.cpan.org/~phred/Archive-Zip-1.37/lib/Archive/Zip.pm)

Mail::Address (http://search.cpan.org/~markov/MailTools-2.13/lib/Mail/Address.pod)

Email::Valid (http://search.cpan.org/~rjbs/Email-Valid-1.192/lib/Email/Valid.pm)


#### Hardware (recommended minimum requirements):
CPU: 2.5GHz processor
RAM: 4GB
HDD: 500 GB


###Usage
The main entry point of Ninkology is ‘ninkology.pl’

####Usage:
ninkology.pl [options] [filename]

options:

-f            Scan the file/package with only FOSSology

-n            Scan the file/package with only Ninka

-m <address>        Send an e-mail to <address> with the results of the scan

The output of ninkology is JSON in the format:

“{fileName: <file>, licenseDeclared: <license>, licenseComment: <comment>}”

<file>         -- The name of the file provided

<license>     -- The license(s) found by Ninka and FOSSology if the results match.

-- “NOASSERTION” if the results of Ninka and FOSSology did not match.

        -- “None” if Ninka and FOSSology both found no license information in the file.

        -- <license> will always be “NOASSERTION” if only one scan is used.

<comment>    The direct output given by Ninka and FOSSology in the form:

        “#Ninka: <ninka_output> #FOSSology: <FOSSology_output>”


