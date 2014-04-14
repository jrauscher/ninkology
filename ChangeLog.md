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
- Combined license scanning (with Ninka and FOSSology) of files or packages via command line<br/>
- Support for uploading a file or package via web interface. Results are sent to user e-mail when the scan is complete<br/>


###Performance improvements: 
None

###Documentation: 
- Added README.md, which contains general information about Ninkology 1.0<br/>
- Added LICENSE.txt, which contains the licensing information of Ninkology<br/>
- Added DataFlow.pdf, which contains the general data flow of Ninkology<br/>
