#!/bin/sh

######################################################################
#                                                                    #
# This program sends out emails using the mail command.              #
# Mail is part the packages: Mailutils, Sharutils, and ssmtp.        #
#                                                                    #  
# The mail is sent from the maill account in: etc/ssmtp/ssmtp.conf   #
#                                                                    #
# Usage: ./email.sh Message Subject RecipEmail Attachment(optional)  #
#                                                                    #  
######################################################################


MES=$1    #Message Body Text
SUB=$2    #Message Subject
REC=$3    #Recipiants Email
ATT=$4    #Attachment (If Any)

if [ $# != 3 ] && [ $# != 4 ]; then
	echo "\nError: Invalid Parameters";
	echo "Usage: ./email.sh Message Subject RecipEmail Attachment(optional)\n";
	exit 0;
fi

if [ $# = 4 ]; then
	uuencode $ATT $ATT | mail -s "$SUB" $REC;
else
	echo "$MES" | mail -s "$SUB" $REC;
fi












