#!/bin/bash

tabs 4
clear
readonly USERS=$(pwd)/users.list
readonly MAILSERVER="lab.nudlerlab.info"
readonly OPENSSL=$(which openssl)
readonly SHELL=/bin/bash
readonly NEWLINE=$'\n'
readonly GROUP="lab"

groupadd $GROUP

while read uline
do
    uname=$(echo $uline | cut -d' ' -f 1)
    email=$(echo $uline | cut -d' ' -f 2)
    passw=$($OPENSSL rand -base64 12)
    echo "USERNAME: ${uname}${NEWLINE}PASSWORD: $passw" > credentials.txt
    PASS=$(mkpasswd $passw)
    useradd -s $SHELL -m $uname -p $PASS
    usermod -aG $GROUP $uname
    sudo chown -R ${uname}:${GROUP} /home/$uname
    scp credentials.txt ${MAILSERVER}:~
    SENDMAIL="\"mail -s '[snowflake login]' $email < credentials.txt\""
    ssh $MAILSERVER "${SENDMAIL}"
done <$USERS

rm credentials.txt
