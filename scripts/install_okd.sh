#!/bin/bash
set -euo pipefail

# Log all commands
set -x

# Update system
sudo dnf update -y

# Install dependencies
sudo dnf install -y git docker-ce podman openssl tar wget

# Configure Docker to use overlay2
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "storage-driver": "overlay2"
}
EOF

# Start and enable Docker
sudo systemctl enable --now docker

# Verify Docker is working
sudo docker run hello-world

# Install OKD client tools (oc)
echo "Installing OKD version ${OKD_VERSION}"
wget -q https://github.com/okd-project/okd/releases/download/${OKD_VERSION}/openshift-client-linux-${OKD_VERSION}.tar.gz
tar xvf openshift-client-linux-${OKD_VERSION}.tar.gz
sudo mv oc kubectl /usr/local/bin/
rm -f openshift-client-linux-${OKD_VERSION}.tar.gz README.md

# Verify oc installation
oc version

# Install OKD cluster (CRC-like setup)
echo "Starting OKD cluster"
oc cluster up \
  --base-dir=/opt/okd \
  --skip-registry-check=true \
  --public-hostname=$(curl -s ifconfig.me) \
  --name=${PROJECT_ID}-cluster  # Added cluster naming

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
while ! oc get nodes 2>/dev/null | grep -q "Ready"; do
  sleep 10
done

# Create projects and deploy microservices
for project in microservice1 microservice2; do
  oc new-project ${PROJECT_ID}
done

# Deploy microservice 1
if [ -n "${MICROSERVICE1_REPO}" ]; then
  echo "Deploying microservice 1 from ${MICROSERVICE1_REPO}"
  git clone ${MICROSERVICE1_REPO} /tmp/microservice1
  oc apply -f /tmp/microservice1/manifests/ -n microservice1
  oc expose svc/microservice1 -n microservice1
fi

# Deploy microservice 2
if [ -n "${MICROSERVICE2_REPO}" ]; then
  echo "Deploying microservice 2 from ${MICROSERVICE2_REPO}"
  git clone ${MICROSERVICE2_REPO} /tmp/microservice2
  oc apply -f /tmp/microservice2/manifests/ -n microservice2
  oc expose svc/microservice2 -n microservice2
fi

# Get cluster information
echo "OKD cluster deployed successfully!"
echo "Cluster console: https://$(oc get routes console -n openshift-console -o jsonpath='{.spec.host}')"
echo "Microservice1 route: https://$(oc get route microservice1 -n microservice1 -o jsonpath='{.spec.host}' 2>/dev/null || echo 'Not deployed')"
echo "Microservice2 route: https://$(oc get route microservice2 -n microservice2 -o jsonpath='{.spec.host}' 2>/dev/null || echo 'Not deployed')"
echo "Login with: oc login -u kubeadmin -p $(cat /opt/okd/auth/kubeadmin-password)"