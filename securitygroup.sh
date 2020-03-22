#!/bin/bash

function AddSecurityGroupRule {
  if [ ${InOut} == "Inbound" ]; then
    if [[ ${Source} =~ ^sg-* ]]; then
      aws ec2 authorize-security-group-ingress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},UserIdGroupPairs="[{Description=${Description},GroupId=${Source}}]"
      rc=$?
    elif [[ ${Source} =~ ^pl-* ]]; then
      aws ec2 authorize-security-group-ingress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},PrefixListIds="[{Description=${Description},PrefixListId=${Source}}]"
      rc=$?
    else
      aws ec2 authorize-security-group-ingress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},IpRanges="[{CidrIp=${Source},Description=${Description}}]"
      rc=$?
    fi            
  else
    if [[ ${Source} =~ ^sg-* ]]; then
      aws ec2 authorize-security-group-egress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},UserIdGroupPairs="[{Description=${Description},GroupId=${Source}}]"
      rc=$?
    elif [[ ${Source} =~ ^pl-* ]]; then
      aws ec2 authorize-security-group-egress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},PrefixListIds="[{Description=${Description},PrefixListId=${Source}}]"
      rc=$?
    else
      aws ec2 authorize-security-group-egress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},IpRanges="[{CidrIp=${Source},Description=${Description}}]"
      rc=$?
    fi
  fi
}

function DelSecurityGroupRule {
  if [ ${InOut} == "Inbound" ]; then
    if [[ ${Source} =~ ^sg-* ]]; then
      aws ec2 revoke-security-group-ingress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},UserIdGroupPairs="[{GroupId=${Source}}]"
      rc=$?
    elif [[ ${Source} =~ ^pl-* ]]; then
      aws ec2 revoke-security-group-ingress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},PrefixListIds="[{PrefixListId=${Source}}]"
      rc=$?
    else
      aws ec2 revoke-security-group-ingress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},IpRanges="[{CidrIp=${Source}}]"
      rc=$?
    fi
  else
    if [[ ${Source} =~ ^sg-* ]]; then
      aws ec2 revoke-security-group-egress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},UserIdGroupPairs="[{GroupId=${Source}}]"
      rc=$?
    elif [[ ${Source} =~ ^pl-* ]]; then
      aws ec2 revoke-security-group-egress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},PrefixListIds="[{PrefixListId=${Source}}]"
      rc=$?
    else
      aws ec2 revoke-security-group-egress --region ${RegionId} --group-id ${GroupId} --ip-permissions IpProtocol=${Protocol},FromPort=${FromPort},ToPort=${ToPort},IpRanges="[{CidrIp=${Source}}]"
      rc=$?
    fi
  fi
}

### Main ###
WorkDir=/hogehoge
ConfigFile=${WorkDir}/sg_config.conf
Logfile=${WorkDir}/sg_config.log
FailedFile=${WorkDir}/sg_config_failed.log
echo "Setting SecurityGroup is starting." 2>&1 | tee ${Logfile}

cat ${ConfigFile} | while read line
do
  SkipFlg=0
  Action=`echo ${line} | cut -d , -f 1`
  if [ ${Action} != "ADD" -a ${Action} != "DEL" ]; then
    echo "Invalid Action: ${line}"
    echo "${line}" >> ${FailedFile}
    SkipFlg=1
  fi
  
  RegionName=`echo ${line} | cut -d , -f 2`
  case "${RegionName}" in
    "Tokyo" )
      RegionId="ap-northeast-1"
      ;;
    * )
      echo "Invalid Region: ${line}"
      echo "${line}" >> ${FailedFile}
      SkipFlg=1
  esac
  GroupId=`echo ${line} | cut -d , -f 3`

  InOut=`echo ${line} | cut -d , -f 4`
  if [ ${InOut} != "Inbound" -a ${InOut} != "Outbound" ]; then
    echo "Invalid Direction: ${line}"
    echo "${line}" >> ${FailedFile}
    SkipFlg=1
  fi

  Protocol=`echo ${line} | cut -d , -f 5`
  FromPort=`echo ${line} | cut -d , -f 6`
  ToPort=`echo ${line} | cut -d , -f 7`
  Source=`echo ${line} | cut -d , -f 8`
  Description=`echo ${line} | cut -d , -f 9`

  if [ ${SkipFlg} -ne 1 ]; then
    if [ ${Action} == "ADD" ]; then
      AddSecurityGroupRule
    else
      DelSecurityGroupRule
    fi
    if [ ${rc} -ne 0 ]; then
      echo "SecurityGroup: ${line} is failed. ReturnCode=${rc}"
      echo "${line}" >> ${FailedFile}
    else
      echo "SecurityGroup: ${line} is ok."
    fi
  fi
done 2>&1 | tee ${Logfile}
echo "Setting SecurityGroup is Ended." 2>&1 | tee ${Logfile}
