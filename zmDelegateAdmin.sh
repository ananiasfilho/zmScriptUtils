#!/bin/bash
clear
#Check if user is zimbra
LOCAL_USER=`id -u -n`

if [ $LOCAL_USER != "zimbra" ] ; then
	echo "     Need run this script as zimbra user"
	echo "     exit..."
	echo ""
	exit
fi

choose_domain() {
	clear
	if [ ! -z '$1' ] ; then
		if [ "$1" == "fail" ] ; then 
			echo "     !!! Domain $EMAIL_USER not exist !!!"
			echo ""
		fi
	fi
	echo "#########################################################"
	read -p '#     Type domain name: ' DOMAIN

	DOMAIN_CHECK=`zmprov gad |grep -E ^$DOMAIN |wc -l`
}
choose_user() {
	clear
	if [ ! -z '$1' ] ; then
		if [ "$1" == "fail" ] ; then 
			echo "     !!! $USER not exist !!!"
			echo ""
		fi
	fi
	echo "#########################################################"
	read -p '#     Type user email: ' EMAIL_USER

#	echo "zmprov gaa $DOMAIN |grep -E ^$EMAIL_USER "
	USER_CHECK=`zmprov -l gaa $DOMAIN |grep -E ^$EMAIL_USER |wc -l`
}
delegateAdmin() {


		zmprov ma $EMAIL_USER zimbraIsDelegatedAdminAccount TRUE
		zmprov ma $EMAIL_USER zimbraAdminConsoleUIComponents cartBlancheUI \
			zimbraAdminConsoleUIComponents domainListView zimbraAdminConsoleUIComponents \
			accountListView zimbraAdminConsoleUIComponents DLListView
		zmprov ma $EMAIL_USER zimbraDomainAdminMaxMailQuota 0
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +createAccount
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +createAlias
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +createCalendarResource
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +createDistributionList
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +deleteAlias
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +listDomain
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +domainAdminRights
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER +configureQuota
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER set.account.zimbraAccountStatus
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER set.account.sn
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER set.account.displayName
		zmprov grantRight domain $DOMAIN usr $EMAIL_USER set.account.zimbraPasswordMustChange
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +deleteAccount
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +getAccountInfo
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +getAccountMembership
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +getMailboxInfo
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +listAccount
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +removeAccountAlias
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +renameAccount
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +setAccountPassword
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +viewAccountAdminUI
		zmprov grantRight account $EMAIL_USER usr $EMAIL_USER +configureQuota
		echo "Done! test your new admin user"
}
#Start script
choose_domain
choose_user


if [ $DOMAIN_CHECK -ne 1 ] ; then
	choose_domain fail
fi
if [ $USER_CHECK -ne 1 ] ; then
	choose_user fail
fi
clear
echo ""
echo "     Applying admin privileges to $EMAIL_USER into domain $DOMAIN"
read -r -p "     Are you sure? (Y/n) " ACCEPT_OPTION
case $ACCEPT_OPTION in
	[yY]* )
		echo "Start..."
		delegateAdmin
		;;

	*)
		echo "Exit..."
		exit 0
		;;
esac

