#!/bin/bash
set -euo pipefail
exec > /var/log/startup-script.log 2>&1
set -x

# Update system
sudo dnf update -y

# Install dependencies
sudo dnf install -y git podman openssl tar wget

# Enable and start podman socket
sudo systemctl enable --now podman.socket

# Verify podman installation
podman --version



# Install OKD CLI
echo "Installing OKD version 4.17.0-okd-scos.0"
wget -q https://github.com/okd-project/okd/releases/download/4.17.0-okd-scos.0/openshift-client-linux-4.17.0-okd-scos.0.tar.gz
tar xvf openshift-client-linux-4.17.0-okd-scos.0.tar.gz
sudo mv oc kubectl /usr/local/bin/
rm -f openshift-client-linux-4.17.0-okd-scos.0.tar.gz README.md

oc version

# Start OKD cluster
oc cluster up \
  --base-dir=/opt/okd \
  --skip-registry-check=true \
  --public-hostname=$(curl -s ifconfig.me) \
  --name=${PROJECT_ID}-cluster

# Wait for cluster
while ! oc get nodes 2>/dev/null | grep -q "Ready"; do
  sleep 10
done

# Create namespace
oc new-project ${PROJECT_ID}

# Microservice 1
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: microservice1
spec:
  selector:
    app: microservice1
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: microservice1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: microservice1
  template:
    metadata:
      labels:
        app: microservice1
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 8080
EOF
oc expose svc/microservice1

# Microservice 2
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: microservice2
spec:
  selector:
    app: microservice2
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: microservice2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: microservice2
  template:
    metadata:
      labels:
        app: microservice2
    spec:
      containers:
      - name: mysqld
        image: mysql:5.7
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        ports:
        - containerPort: 3306
EOF
oc expose svc/microservice2

echo "OKD and microservices deployed successfully!"
