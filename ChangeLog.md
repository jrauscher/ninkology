#Ninkology 1.2 (5-2-2014)
========
###Bug Fixes:
- Calling ninkology.pl from relative paths (or packages with relative paths) should work better than before.<br/>

###Features:
- Removed the web interface. No one liked it. Just use the command line.<br/>
- Changed format of output to better match expected input for 'do_spdx'<br/>
- Added '-sha1' option to include the SHA-1 of each file scanned<br/>
- Added '-clean' option, which removes the 'tmp' directory and config file created by ninkology.pl<br/>

###Performance improvements:
None<br/>

###Documentation:
- Added '-clean' to Usage section<br/>
- Added '-sha1' to Usage section<br/>

-----------------------------------------------------------------------


#Ninkology 1.1.1 (4-25-2014)
========
###Bug Fixes: 
- Cleaned up ninka output on individual file scans.<br/>
- Ninkology now checks if a package is already being scanned before attempting to scan it.<br/>

###Features: 
#### Command Line
- Added '-c' option for removing file paths from file names in output.<br/>

###Performance improvements: 
- Ninkology now saves the paths for ninka and nomos to a file after 'find'ing them. 'find' is no longer run for every scan (saves a whole .2 seconds per scan!).<br/>

###Documentation: 
- Added '-c' to Usage section.<br/>
- Added './' to Usage section.<br/>

-----------------------------------------------------------------------


#Ninkology 1.1 (4-14-2014)
========
###Bug Fixes: 
- Archives are no longer "scanned" by the system (empty archives now give no results).<br/>
- Now checks if file exists before attempting to scan it.<br/>

###Features: 
- If only Ninka or FOSSology is used, the licence(s) found by the single scan are "declared".<br/>

#### Command Line
- Removed '-fn' flag. Dual scan is the default behavior.<br/>
- If both '-f' and '-n' are used, the results will be identical to not using either.<br/>
- File information is now printed to STDOUT while the program is running to let the user know that progress is being made.<br/>

#### Web Interface
- Web Interface no longer sends e-mail to end user. Now provides the user with a link to download the scan results.<br/>

###Performance improvements: 
None

###Documentation: 
- Updated the use cases to more accurately reflect the current working version of Ninkology.<br/>


-----------------------------------------------------------------------


#Ninkology 1.0 (03-21-2014)
========
###Bug Fixes: 
None

###Features: 
- Combined license scanning (with Ninka and FOSSology) of files or packages via command line.<br/>
- Support for uploading a file or package via web interface. Results are sent to user e-mail when the scan is complete.<br/>


###Performance improvements: 
None

###Documentation: 
- Added README.md, which contains general information about Ninkology 1.0.<br/>
- Added LICENSE.txt, which contains the licensing information of Ninkology.<br/>
- Added DataFlow.pdf, which contains the general data flow of Ninkology.<br/>
