#!/bin/bash

    SG_ID="sg-0d48b1166075f71bf"
    AMI_ID="ami-0220d79f3f480ecf5"
    zone_ID="Z08598391AA5TMYW8RQL3"
    DOMAIN_NAME="daws88straining.online"
    USERID=$(id -u)

for instance in $@

do

INSTANCE_ID=$(aws ec2 run-instances \
                    --image-id $AMI_ID \
                    --instance-type t3.micro \
                    --security-group-ids $SG_ID \
                    --tag-specifications  "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
                    --query 'Instances[0].InstanceId' \
                    --output text)

 echo "Launched Instance ID: $INSTANCE_ID"


 if [ $instance == "frontend" ]; then

IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
echo "The public IP is: $IP"
Record_Name=$DOMAIN_NAME

else

IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text )
   
# Verify the result
echo "The private IP address is: $IP"
Record_Name="$instance.$DOMAIN_NAME"
fi


aws route53 change-resource-record-sets \
--hosted-zone-id $zone_ID \
--change-batch '
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$Record_Name'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
      }
    }
  ]
}
'
done

echo "record uPdated : $instance"

   


