#!/usr/bib/perl
use strict;
use warnings;

print ""; # This makes the 'require licenselib.pl' happy in scan.pl


# Copyright (C) 2014 Ryan Vanek
# License: Apache 2.0
#
# This program just hides the big ugly hash that 'scan.pl' uses
# for license comparisons between Ninka and FOSSology



# This subroutine creates a hash to map Ninka output (keys) to
# FOSSology output (values) where pairings of the same license exist.
#
# Pairs look like: 'x', 'y' 
# where 'x' is the Ninka equivalent of FOSSOlogy's 'y'
#
# If there was any uncertainty as to whether the licenses reported by
# both programs were the same, they were not included in this hash
# (eg. 'FSFUnlimited' and 'FSF' may not be the same)
#
# The information used to create this hash can be found here:
#   FOSSology 2.4.0 license list (http://www.fossology.org/attachments/3369/license_list_2.4.0.txt)
#   Ninka 1.1 license list (https://github.com/dmgerman/ninka/blob/master/matcher/rules.dict)
#   SPDX 1.19 license list (http://spdx.org/licenses/)
#
sub createLicenseHash
{
    my %hash = 
    (
        'foo', 'bar',
        'AGPLv3+', 'AGPL-3.0+',
        'Apachev1.0', 'Apache-1.0',
        'Apachev1.1', 'Apache-1.1',
        'Apachev2', 'Apache-2.0',
        'ArtisticLicensev1', 'Artistic-1.0',
        #'CDDLic', 'CDDL',   # No SPDX equivalent       
        'CDDLicV1', 'CDDL-1.0',
        'CPLv0.5', 'CPL-0.5',
        'CPLv1', 'CPL-1.0',      
        #'Cecill', 'CeCILL', # No SPDX equivalent
        'EPLv1', 'EPL-1.0',
        'GPLv1', 'GPL-1.0',
        'GPLv1+', 'GPL-1.0+',
        'GPLv2', 'GPL-2.0',
        'GPLv2+', 'GPL-2.0+',
        
        'ClassPathExceptionGPLv2', 'GPL-2.0-with-classpath-exception', 
        
        'GPLv3', 'GPL-3.0',   
        'GPLv3+', 'GPL-3.0+',
        'LGPLv2.1', 'LGPL-2.1',
        'LGPL2.1', 'LGPL-2.1',       
        'LGPLv2', 'LGPL-2.0',
        'LesserGPLv2', 'LGPL-2.0',
        'LGPLv2+', 'LGPL-2.0+',
        'LesserGPLv2+', 'LGPL-2.0+',
        'LGPLv2.1', 'LGPL-2.1',
        'LesserGPLv2.1', 'LGPL-2.1',
        'LGPLv2.1+', 'LGPL-2.1+',
        'LesserGPLv2.1+', 'LGPL-2.1+',
        'LGPLv3', 'LGPL-3.0',
        'LesserGPLv3', 'LGPL-3.0',
        'LGPLv3+', 'LGPL-3.0+',
        'LesserGPLv3+', 'LGPL-3.0+',      
        #'LinkException', 'Link-exception', # No SPDX equivalent
        'MPLv1_0', 'MPL-1.0',
        'MPLv1_1', 'MPL-1.1',
        'MPLv2', 'MPL-2.0',       
        #'MX4J', 'MX4J', # No SPDX equivalent
        #'MX4JLicensev1', 'MX4J-1.0', # No SPDX equivalent
        'NCSA', 'NCSA',
        'NPLv1_0', 'NPL-1.0',
        'NPLv1_1', 'NPL-1.1',
        #'Postfix', 'Postfix', # No SPDX equivalent       
        'SleepyCat', 'Sleepycat',
        'W3CLic', 'W3C',
        'X11', 'X11',
        'ZLIB', 'Zlib',
               
        #'artifex', 'Artifex', # No SPDX equivalent
        #'boost', '(C) Boost', # No SPDX equivalent
        'boostV1', 'BSL-1.0',
        'openSSL', 'OpenSSL',
        'phpLicV3.01', 'PHP-3.01',
        'postgresql', 'PostgreSQL'
        #'publicDomain', 'Public-domain' # No SPDX equivalent
        #'zendv2', 'Zend-2.0' # No SPDX equivalent
    );
      
    return %hash;
}
