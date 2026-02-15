#!/bin/bash

    SG_ID="sg-0d48b1166075f71bf"
    AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@

do

# INSTANCE_ID=$( aws ec2 run-instances \
#                 --image-id $AMI_ID \
#                 --instance-type "t3.micro" \
#                 --security-group-ids $SG_ID \
#                 --tag-specifications  "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
#                 # --query 'Instances[0].InstanceId' \
#                 # --output text 
#                 )

     INSTANCE_ID=$(aws ec2 run-instances \
                    --image-id ami-0220d79f3f480ecf5 \
                    --instance-type t3.micro \
                    --security-group-ids sg-0d48b1166075f71bf \
                    --tag-specifications  "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
                    --query 'Instances[0].InstanceId' \
                    --output text)

 echo "Launched Instance ID: $INSTANCE_ID"


 if [ $instance == "frontend" ]; then

 IP=$(aws ec2 describe-instances \
 --instance-ids $INSTANCE_ID
 --query 'Reservations[].Instances[].PublicIpAddress'\
  --output text)
  else

   IP=$(aws ec2 describe-instances \
 --instance-ids $INSTANCE_ID
 --query 'Reservations[].Instances[].PrivateIpAddress'\
  --output text)

 fi           

done


#      INSTANCE_ID=$(aws ec2 run-instances \
#                     --image-id ami-0220d79f3f480ecf5 \
#                     --instance-type t3.micro \
#                     --security-group-ids sg-0d48b1166075f71bf \
#                     --tag-specifications  "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
#                     --query 'Instances[0].InstanceId' \
#                     --output text)

# echo "Launched Instance ID: $INSTANCE_ID"
