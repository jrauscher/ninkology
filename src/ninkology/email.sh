#!/bin/sh

######################################################################
#                                                                    #
# This program sends out emails using the mail command.              #
# Mail is part the packages: Mailutils, Sharutils, and ssmtp.        #
#                                                                    #  
# The mail is sent from the mail account in: etc/ssmtp/ssmtp.conf    #
#                                                                    #
# Usage: ./email.sh Message Subject RecipEmail Attachment(optional)  #
#                                                                    #  
# Licence: Apache 2.0                                                #  
#                                                                    #  
######################################################################


MES=$1    #Message Body Text
SUB=$2    #Message Subject
REC=$3    #Recipients Email
ATT=$4    #Attachment (If Any)


#Makes sure arguments are valid
if [ $# != 3 ] && [ $# != 4 ]; then
	echo "\nError: Invalid Parameters";
	echo "Usage: ./email.sh Message Subject RecipEmail Attachment(optional)\n";
	exit 0;
fi

if [ $# = 4 ]; then 		#If email has attachment
	uuencode $ATT $ATT | mail -s "$SUB" $REC;
else 						#If email has no attachment
	echo "$MES" | mail -s "$SUB" $REC;
fi












