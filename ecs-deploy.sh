#!/bin/bash

#variables

AWS_ACCESS_KEY_ID="AKIA5XTUVANQDNIVDKFL"
AWS_SECRET_ACCESS_KEY="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"
AWS_DEFAULT_REGION="us-east-1"
PROJECT="wordpress"
PROFILE="wordpress"

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

cat <<EOF > wordpress.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAm9+lnY9buP0YTz5nxIxrQ4rfQrC5C8YKA6Frhq6WO6uVZWIb
kqGcIPPs6Z62qd5+skCaxnY1sme2yuJlZnpzWb0ynGvmRJ7PaQfrNIorptZtHWRG
v4mNel9W1GUqEtqHcwf57Xuct4F+t0xiJGBroafYxS8F1BQX+U3Wk5MGhLVwuHQ0
p/N9XOMIzBIK8sdQWNJt39OYfKKqSTuGYrAiw2IvonicAtVyHAPsDRBpKl0Yj9QR
fKD0xjtEZz3t3siAj1Ejj4c0zZ462liuitztk4X27wOYKkWwvB6wjS2b55zbsDbg
AaLNtWvCldiT9SSjFf5ezV6Sl4I/h/P91rbmIQIDAQABAoIBABPLpFnNMgXdRrAR
qdYBS0IJqe7rSKThIrZxUpmJJJUxZki42+2UTqK0t7q3qFUMZ6S1pbJcotckasd7
Vwtbs7iK2ZmZ7mV6kbayBcHnZkHK65KXAJEko+4Nm5ZfvqckT51hPvFVCIMZlAEt
Vy1tfV3LVjE8lo3ne1/y7bRSMLq7qSaLV+LugcwGUBtr+8yqRpjlsBKhdNg3kpUf
0HDMZmmKHbzvU96sveOzkdGxyJOsSS+VsDD3U0IlEEjITcmE2fZYDQHQvhCcXMKQ
4S3uvll9ytawxxDhZHHlhT6Z1iyF7jU+S3EIpKzAa8JT3ayavencWQXYlZIsFT+Y
VgiwhwECgYEA30Yjx6QpMG/lx7TD2lOxiiszatIQQ4HNBEITZzx9qm2oCj13B2jF
4JEkmKZG+2zic1tx4A5NtfInPp7MtmsaIDX/qlkkvBMM7H6XFI0YCchHrclCOSC+
/lkDOl1UPAxexXNmEU9PG2Lm2nPj1lkywhIzG6A6xgusIeo0V8P+rPECgYEAsrh1
UoYJ8oq+kKumLqIJF/1SdLH+xddrSwYhJyiCR+xlHz3Jm06XoAvzPbV6dtSdCYqp
/U55gGvMV8n2SiClMhUoZovehdoFIT0KOrVWB1+1XwBtQVXakHO3vUvGZ1HP26NR
K7rYJmwThDzpZA7IbouVSRNwKJzjFSrpF2KkjDECgYBC2jaGZXHrzeVoSYjHC35C
V7MajfFOtUPUvZAfvi4GZLUG8+Z68nUlS3BAwLDKQY0Aa2YKZ13/V5VGm7fB+wmk
kWaO9AgaxD1/ZlwITELhUvWbZIKOpm5pq+9af21kWXPa/TWXgz61fYSP7llO6gBX
ualR4UUX3ZDZys2HZekQkQKBgDfyjqe61jpbPLTFR0yp5PbhkoJ9higg+7GMxawg
fkhNtIpHKWm4/LZZh1f2C9RPUqm+AuENQ/PzyxBgZP1nos8+2FrhxlNYoOp61Uzz
n27Hg1uuIoWlfrphv08+/Wkyr0MuqSZrY2cDxkhLWTS9e/k/MQijUSUll+D0geuU
MbbBAoGAGTHK1ZGeN/fB6AFzK/hG0WqBAGXH8a442cyMS7NtPtBGBHLxGlziOFJG
y7FRQPh1RqQyl21ve6M3Q5+zZnDAxPFWy04ldi4rCjOQo4Epj5wikHlZa0lBmYYu
ckD7dYHs2T0tByXdQ0NkyMe+qOXVrhbh6MFGYRuXVQ9lbVB2jzs=
-----END RSA PRIVATE KEY-----
EOF

ecs-cli configure --cluster ${PROJECT} --default-launch-type EC2 --config-name ${PROJECT} --region ${AWS_DEFAULT_REGION}

ecs-cli configure profile --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --profile-name ${PROFILE}

cat ~/.ecs/credentials

cat ~/.ecs/config

echo "Step 2: Create Your Cluster"

ecs-cli up --force --keypair ${PROJECT} --capability-iam --size 2 --instance-type t2.medium --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 4: Create an ECS Service from a Compose File and Deploy the Compose File to a Cluster"

sleep 30

ecs-cli compose service up --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli compose up --create-log-groups --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli compose up --cluster ${PROJECT} --cluster-config ${PROJECT} --force-update --ecs-profile ${PROFILE}

echo "Step 5: View the Running Containers on a Cluster"

ecs-cli ps --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 6: Scale the Tasks on a Cluster"

ecs-cli compose scale 2 --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli ps --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 7: Create an ECS Service from a Compose File"

ecs-cli compose down --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

ecs-cli compose service up --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 8: View your Web Application"

ecs-cli ps --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

echo "Step 9: Clean Up"

#ecs-cli compose service rm --cluster-config ${PROJECT} --ecs-profile ${PROFILE}

#ecs-cli down --force --cluster-config ${PROJECT} --ecs-profile ${PROFILE}
