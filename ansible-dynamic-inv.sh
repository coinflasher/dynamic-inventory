#!/usr/bin/env bash

GROUP=DYNAMIC-GROUP  # < -- Add your group name here
SERVERLISTDIR="/var/ansible/inventory"  # < -- Set to base directory that houses the server list
SERVERLIST="${SERVERLISTDIR}/${GROUP}/Serverlist"  # < -- Set to text file name of list of servers
LIST=unset
usage()
{
  echo "Usage: alphabet [ -l | --list ]"
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n alphabet -o l --long list -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -l | --list)   LIST=1      ; shift   ;;
    --) shift; break ;;
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

if [ "$LIST" = "unset" ]
then
  echo '{"_meta": {"hostvars": {}}}'
else
    SRVCNT=$(cat ${SERVERLIST} | wc -l | awk {'print $1'})
    CNTDWN=${SRVCNT}
    echo -n "{"
    echo -n "\"${GROUP}\": {"
    echo -n "\"hosts\": ["
    for HOST in $(cat ${SERVERLIST})
    do
      CNTDWN=$(($CNTDWN - 1))
      echo -n "\"${HOST}\""
      if [ "${CNTDWN}" -gt 0 ]
      then
        echo -n ", "
      fi
    done
    echo -n "],"
    echo -n " \"vars\": {\"ansible_ssh_user\": \"ans_service_acct\"}}, "
    echo -n "\"_meta\": {\"hostvars\": {"
    CNTDWN=${SRVCNT}
    for HOST in $(cat ${SERVERLIST} | tac)
    do
      CNTDWN=$(($CNTDWN - 1))
      echo -n "\"${HOST}\": {\"host_specific_var\": \"\"}"
      if [ "${CNTDWN}" -gt 0 ]
      then
        echo -n ", "
      fi
    done
    echo "}}}"
fi
