#!/bin/bash

# Update system
sudo dnf update -y

# Install dependencies
sudo dnf install -y git docker-ce podman openssl

# Start and enable Docker
sudo systemctl enable --now docker

# Install OKD client tools (oc)
OKD_VERSION=${okd_version}
wget https://github.com/okd-project/okd/releases/download/${OKD_VERSION}/openshift-client-linux-${OKD_VERSION}.tar.gz
tar xvf openshift-client-linux-${OKD_VERSION}.tar.gz
sudo mv oc kubectl /usr/local/bin/
rm -f openshift-client-linux-${OKD_VERSION}.tar.gz README.md

# Install OKD cluster (minimal setup for demo)
oc cluster up --base-dir=/opt/okd

# Wait for cluster to be ready
while ! oc get nodes 2>/dev/null | grep -q "Ready"; do
  echo "Waiting for OKD cluster to be ready..."
  sleep 10
done

# Create projects and deploy microservices
oc new-project microservice1
oc new-project microservice2

# Clone and deploy microservice 1
git clone ${microservice1_repo} /tmp/microservice1
oc apply -f /tmp/microservice1/manifests/ -n microservice1

# Clone and deploy microservice 2
git clone ${microservice2_repo} /tmp/microservice2
oc apply -f /tmp/microservice2/manifests/ -n microservice2

# Expose services
oc expose svc/microservice1 -n microservice1
oc expose svc/microservice2 -n microservice2

echo "OKD installation and microservices deployment completed!"
echo "Cluster console: https://localhost:8443"
echo "Microservice1 route: $(oc get route microservice1 -n microservice1 -o jsonpath='{.spec.host}')"
echo "Microservice2 route: $(oc get route microservice2 -n microservice2 -o jsonpath='{.spec.host}')"