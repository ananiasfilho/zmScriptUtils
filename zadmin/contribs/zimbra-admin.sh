#!/bin/bash
# Zool - Zoltan Vigh - 2013.05.25

USER='user@domain.com'
DOMAINS=$(cat /tmp/domains)

zmprov ma ${USER} zimbraIsDelegatedAdminAccount TRUE
zmprov ma ${USER} +zimbraAdminConsoleUIComponents accountListView
zmprov ma ${USER} +zimbraAdminConsoleUIComponents aliasListView
zmprov ma ${USER} +zimbraAdminConsoleUIComponents DLListView

for DOMAIN in ${DOMAINS}; do
    echo ${DOMAIN}
    # alias ACL
    zmprov grr domain ${DOMAIN} usr ${USER} +deleteAlias
    zmprov grr domain ${DOMAIN} usr ${USER} +listAlias
    zmprov grr domain ${DOMAIN} usr ${USER} createAlias
    zmprov grr domain ${DOMAIN} usr ${USER} listAlias

    # account ACL
    zmprov grr domain ${DOMAIN} usr ${USER} +deleteAccount
    zmprov grr domain ${DOMAIN} usr ${USER} +listAccount
    zmprov grr domain ${DOMAIN} usr ${USER} +renameAccount
    zmprov grr domain ${DOMAIN} usr ${USER} +setAccountPassword
    zmprov grr domain ${DOMAIN} usr ${USER} createAccount
    zmprov grr domain ${DOMAIN} usr ${USER} listDomain

    # distribution list ACL
    zmprov grr domain ${DOMAIN} usr ${USER} createDistributionList
    zmprov grr domain ${DOMAIN} usr ${USER} addDistributionListMember
    zmprov grr domain ${DOMAIN} usr ${USER} removeDistributionListMember
    zmprov grr domain ${DOMAIN} usr ${USER} getDistributionList
    zmprov grr domain ${DOMAIN} usr ${USER} modifyDistributionList
    zmprov grr domain ${DOMAIN} usr ${USER} deleteDistributionList
    zmprov grr domain ${DOMAIN} usr ${USER} renameDistributionList
    zmprov grr domain ${DOMAIN} usr ${USER} listDistributionList

    zmprov grr domain ${DOMAIN} usr ${USER} set.account.zimbraAccountStatus
    zmprov grr domain ${DOMAIN} usr ${USER} set.account.sn
    zmprov grr domain ${DOMAIN} usr ${USER} set.account.displayName
    zmprov grr domain ${DOMAIN} usr ${USER} set.account.zimbraPasswordMustChange
done
