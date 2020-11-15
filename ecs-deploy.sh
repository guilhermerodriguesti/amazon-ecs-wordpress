#!/bin/bash

#variables

export AWS_ACCESS_KEY_ID="AKIA5JC656SHXB7WWSML"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_DEFAULT_REGION="us-east-1"
PROJECT="wordpress"
PROFILE="wordpress"
SIZE="2"
INSTANCE="t2.medium"



echo -e "\e[4;32mINICIANDO...\e[0m"

echo "Step 1: Configure the Amazon ECS CLI and ENVIRONMENTs"

cat <<EOF > docker-compose.yml
version: '3'
services:
  wordpress:
    image: wordpress
    ports:
      - "80:80"
    links:
      - mysql
  mysql:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: password
EOF

cat <<EOF > ecs-params.yml
version: 1
task_definition:
  services:
    wordpress:
      cpu_shares: 100
      mem_limit: 262144000
    mysql:
      cpu_shares: 100
      mem_limit: 262144000
EOF

aws ec2 create-key-pair --key-name ${PROJECT}-key --query 'KeyMaterial' --output text > ${PROJECT}.pem

ecs-cli configure --cluster ${PROJECT} --default-launch-type EC2 --config-name ${PROJECT} --region ${AWS_DEFAULT_REGION}

ecs-cli configure profile --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --profile-name ${PROFILE}

cat ~/.ecs/credentials

cat ~/.ecs/config

echo "Step 2: Create Your Cluster"

ecs-cli up --force --keypair ${PROJECT}-key --capability-iam --size $SIZE --instance-type $INSTANCE --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 4: Create an ECS Service from a Compose File and Deploy the Compose File to a Cluster"

sleep 30

ecs-cli compose service up --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli compose up --create-log-groups --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli compose up --cluster ${PROJECT} --cluster-config ${PROJECT} --force-update --ecs-profile ${PROFILE}

echo "Step 5: View the Running Containers on a Cluster"

ecs-cli ps --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 6: Scale the Tasks on a Cluster"

ecs-cli compose scale $SIZE --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli ps --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 7: Create an ECS Service from a Compose File"

ecs-cli compose down --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli compose service up --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 8: View your Web Application"

ecs-cli ps --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 9: Clean Up"

#ecs-cli compose service rm --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

#ecs-cli down --force --cluster-config ${PROJECT} --ecs-profile ${PROFILE}
