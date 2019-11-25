#!/bin/bash

tabs 4
clear
readonly ADMIN="ilya.shamovsky@gmail.com"
readonly USERS=$(pwd)/users.list
readonly MAILSERVER="lab.nudlerlab.info"
readonly OPENSSL=$(which openssl)
readonly SHELL=/bin/bash
readonly NEWLINE=$'\n'
readonly GROUP="lab"

sudo groupadd $GROUP

while read uline
do
    uname=$(echo $uline | cut -d' ' -f 1)
    email=$(echo $uline | cut -d' ' -f 2)
    passw=$($OPENSSL rand -base64 12)
    echo "USERNAME: ${uname}${NEWLINE}PASSWORD: $passw" > credentials.txt
    PASS=$(mkpasswd $passw)
    sudo useradd -s $SHELL -m $uname -p $PASS
    sudo usermod -aG $GROUP $uname
    sudo chown -R ${uname}:${GROUP} /home/$uname
    scp credentials.txt ${MAILSERVER}:~
    SENDMAIL="ssh $MAILSERVER \"mail -s '[snowflake login]' -c $ADMIN $email < credentials.txt\" < /dev/null"
    eval $SENDMAIL
    sleep 5
    echo "Created user: $uname"
done <$USERS

rm credentials.txt
