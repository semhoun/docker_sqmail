#!/bin/bash
RESUME=$(mktemp /tmp/sqmail.XXXXXX)
> ${RESUME}

#########################
# Gui for params
#########################

#https://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail
whiptail --title "S/QMail AIO" --msgbox "Welcome in the S/QMail first time configuration\MYSQL database must already been created" 8 78

# MYSQL
MYSQL_HOST=$(whiptail --inputbox "MYSQL Host" 8 39 "" --title "MYSQL configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
MYSQL_DB=$(whiptail --inputbox "MYSQL Database" 8 39 "" --title "MYSQL configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
MYSQL_USER=$(whiptail --inputbox "MYSQL Username" 8 39 "" --title "MYSQL configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
MYSQL_PASS=$(whiptail --inputbox "MYSQL Password" 8 39 "" --title "MYSQL configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi

cat >> "${RESUME}" <<EOF
Mysql configration will be:
  - host : ${MYSQL_HOST}
  - database : ${MYSQL_DB}
  - username : ${MYSQL_USER}
  - password : ${MYSQL_PASS}
  
EOF

# QMail params
CONCURRENCY_INCOMING=$(whiptail --inputbox "Concurrency incoming" 8 39 "50" --title "QMail/SMTP configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
CONCURRENCY_REMOTE=$(whiptail --inputbox "Concurrency remote" 8 39 "5" --title "QMail/SMTP configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
DATABYTES=$(whiptail --inputbox "Email max size in bytes (0 unlimited)" 8 39 "26214400" --title "QMail/SMTP configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
QUEUELIFETIME=$(whiptail --inputbox "Queue life time in seconds" 8 39 "604800" --title "QMail/SMTP configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
SPFBEHAVIOR=$(whiptail --title "Menu example" --menu "QMail/SMTP configuration" 25 78 16 \
  "3" "Reject mails when SPF resolves to fail (deny)" \
  "0" "Never do SPF lookups, don't create Received-SPF headers" \
  "1" "Only create Received-SPF headers, never block" \
  "2" "Use temporary errors when you have DNS lookup problems" \
  "4" "Reject mails when SPF resolves to softfail" \
  "5" "Reject mails when SPF resolves to neutral" \
  "6" "Reject mails when SPF does not resolve to pass" \
3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
RELAY_IPS=$(whiptail --inputbox "IP or network to relay (separated by coma)" 8 39 "127.0.0.1,::1,192.168.1." --title "QMail/SMTP configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi

cat >> "${RESUME}" << EOF
QMail/SMTP configuration will be:
  - concurrency incoming : ${CONCURRENCY_INCOMING}
  - concurrency remote : ${CONCURRENCY_REMOTE}
  - database : ${DATABYTES}
  - queue life time : ${QUEUELIFETIME}
  - spf behavior : ${SPFBEHAVIOR}
  - relay allowed : ${RELAY_IPS}
  
EOF

SMTP_SERVER=$(whiptail --inputbox "SMTP server hostname, coud be different of the MX entry (must match the PTR entry or reverse DNS)" 12 50 "smtp.exemple.net" --title "Domain configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
DEFAULT_DOMAIN=$(whiptail --inputbox "Default domain" 8 39 "exemple.net" --title "Domain configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
POSTMASTER_PWD=$(whiptail --inputbox "Postmaster password" 8 39 "" --title "Domain configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
cat >> "${RESUME}" << EOF
Domain configuration will be:
  - smtp server : ${SMTP_SERVER}
  - default domain : ${DEFAULT_DOMAIN}
  - postmaster password : ${POSTMASTER_PWD}
  
EOF

ROUNDCUBE_SUPPORT=$(whiptail --inputbox "Roundcube support url (with https:// or mailto;" 12 50 "mailto:help@${DEFAULT_DOMAIN}" --title "Roundcube Webmail Configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
ROUNDCUBE_NAME=$(whiptail --inputbox "Roundcube name" 8 39 "Roundcube Webmail" --title "RoundCube Webmail Configuration" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then echo "You canceled the script"; exit 0; fi
cat >> "${RESUME}" << EOF
Roundcube Webmail  configuration will be:
  - support url : ${ROUNDCUBE_SUPPORT}
  - roundcube name : ${ROUNDCUBE_NAME}
  
EOF

# Resume
whiptail --textbox "${RESUME}" 30 78
rm "${RESUME}"

if !(whiptail --title "Set configuration" --yesno "Apply the configuration." 8 78); then
  echo "You canceled the script"
  exit 0
fi

#-----------------------------------------------------------------------------#

#########################
# Create config
#########################
export MYSQL_USER=${MYSQL_USER}
export MYSQL_PASS=${MYSQL_PASS}
export MYSQL_DB=${MYSQL_DB}
export MYSQL_HOST=${MYSQL_HOST}

# Default config
echo "MAILER-DAEMON" > /var/qmail/control/bouncefrom
echo postmaster > /var/qmail/control/doublebounceto
echo "|/var/vpopmail/bin/vdelivermail '' delete" > /var/qmail/control/defaultdelivery

# SSL base Config
openssl dhparam -out /ssl/qmail-dhparam 2048
openssl dhparam -out /ssl/dovecot-dhparam 2048	

# Creation configuration
cat > /var/qmail/control/mysql.conf << EOF
MYSQL_USER=${MYSQL_USER}
MYSQL_PASS=${MYSQL_PASS}
MYSQL_DB=${MYSQL_DB}
MYSQL_HOST=${MYSQL_HOST}
EOF
echo "${MYSQL_HOST}|0|${MYSQL_USER}|${MYSQL_PASS}|${MYSQL_DB}" > /var/vpopmail/etc/vpopmail.mysql
cat > /var/qmail/control/spamassassin_sql.cf << EOF
# User prefs
user_scores_dsn DBI:mysql:${MYSQL_DB}:${MYSQL_HOST}
user_scores_sql_username ${MYSQL_USER}
user_scores_sql_password ${MYSQL_PASS}
user_scores_sql_custom_query     SELECT preference, value FROM spam_prefs WHERE username = _USERNAME_ OR username = '\$GLOBAL' OR username = CONCAT('%',_DOMAIN_) ORDER BY username ASC
EOF
echo -n "${CONCURRENCY_INCOMING}" > /var/qmail/control/concurrencyincoming
echo "${CONCURRENCY_REMOTE}" > /var/qmail/control/concurrencyremote
echo "${DATABYTES}" > /var/qmail/control/databytes
echo "${SPFBEHAVIOR}" > /var/qmail/control/spfbehavior
echo "${QUEUELIFETIME}" > /var/qmail/control/queuelifetime

# VPopmail configuration
echo "${DEFAULT_DOMAIN}" > /var/vpopmail/etc/defaultdomain
cp /opt/templates/vlimits.default /var/vpopmail/etc/vlimits.default
cp /opt/templates/vusage* /var/vpopmail/etc/

# Qmail configuration from /package/mail/sqmail/sqmail/src/config-fast.sh
echo "${SMTP_SERVER}" > /var/qmail/control/me
echo "${DEFAULT_DOMAIN}" > /var/qmail/control/defaultdomain
echo "${DEFAULT_DOMAIN}" > /var/qmail/control/plusdomain
echo "${SMTP_SERVER}" >> /var/qmail/control/rcpthosts
echo "*:" >> /var/qmail/control/tlsdestinations

# Alias
cd /var/qmail/alias
echo "postmaster@${DEFAULT_DOMAIN}" > .qmail-postmaster
ln -s .qmail-postmaster .qmail-mailer-daemon
ln -s .qmail-postmaster .qmail-root
chown alias.sqmail .qmail*
chmod 644 .qmail*
 
# Dovecot
cat /opt/templates/dovecot-sql.conf.ext | envsubst \
		'$MYSQL_USER $MYSQL_PASS $MYSQL_HOST $MYSQL_DB' \
		> /var/qmail/control/dovecot-sql.conf.ext
chown root.root /var/qmail/control/dovecot-sql.conf.ext
chmod 600 /var/qmail/control/dovecot-sql.conf.ext

# Creation directory and setting permissions
chown -R qmailq.sqmail /var/qmail/queue
chown -R qmaild.sqmail /var/qmail/control
chmod 644 /var/qmail/control/*
mkdir -p /var/qmail/control/domainkeys
chmod 755 /var/qmail/control/domainkeys
chown qmailr.sqmail /var/qmail/control/domainkeys
mkdir -p /var/spamassassin/auto-whitelist
mkdir -p /var/spamassassin/bayes
mkdir -p /var/spamassassin/razor
echo "razorhome = /etc/mail/spamassassin/.razor/" > /var/spamassassin/razor/razor-agent.conf
chown -R vpopmail.vchkpw /var/spamassassin
chown 644 /var/vpopmail/etc/*
chown -R vpopmail.vchkpw /var/vpopmail/domains

# Add domain in vpopmail
/var/vpopmail/bin/vadddomain ${DEFAULT_DOMAIN} "${POSTMASTER_PWD}"

# SpamAssassin DB
cat /opt/templates/spamassassin.sql | mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p"${MYSQL_PASS}" ${MYSQL_DB}

# Rules cdb
cat > /var/qmail/control/rules.smtpsub << EOF
:allow,RELAYCLIENT=''
EOF
> /var/qmail/control/rules.smtpd
> /var/qmail/control/rules.smtpsd
IPS=$(echo $RELAY_IPS | tr "," "\n")
for ip in ${IPS}; do
	echo "${ip}:allow,RELAYCLIENT=''" >> /var/qmail/control/rules.smtpd
	echo "${ip}:allow,RELAYCLIENT=''" >> /var/qmail/control/rules.smtpsd
done
echo ":allow,QHPSI='clamdscan',QHPSIARG1='--no-summary',MFDNSCHECK='',BADMIMETYPE='',BADLOADERTYPE='M',HELOCHECK='.',TARPITCOUNT='5',TARPITDELAY='20',QMAILQUEUE='bin/qmail-queuescan'" >> /var/qmail/control/rules.smtpd
echo ":allow,QHPSI='clamdscan',QHPSIARG1='--no-summary',MFDNSCHECK='',BADMIMETYPE='',BADLOADERTYPE='M',HELOCHECK='.',TARPITCOUNT='5',TARPITDELAY='20',QMAILQUEUE='bin/qmail-queuescan'" >> /var/qmail/control/rules.smtpsd
/opt/bin/qmailctl cdb

# Generate roundcube config
cat > /var/qmail/control/roundcube.conf << EOF
export MYSQL_USER=${MYSQL_USER}
export MYSQL_PASS=${MYSQL_PASS}
export MYSQL_DB=${MYSQL_DB}
export MYSQL_HOST=${MYSQL_HOST}
export DES_KEY=`apg -MSNCL -m 24 -x 24 -n 1`
export SUPPORT_URL="${ROUNDCUBE_SUPPORT}"
export PRODUCT_NAME="${ROUNDCUBE_NAME}"
EOF

# Roundcube DB
cat /opt/templates/roundcube.sql | mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p"${MYSQL_PASS}" ${MYSQL_DB}

echo "============================"
echo " QMail AllInOne initialized"
echo "============================"
