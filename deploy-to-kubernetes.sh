#!/bin/sh

# Install curl
apt update && apt install -y curl

## Download the kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Put kubeconfig
# aws eks update-kubeconfig --name tf-1mg-prestag --kubeconfig ${kubeconfig_file}
echo ${KUBECONFIG} | base64 --decode > ${kubeconfig_file}

# Deploy the kubernetes resources
kubectl apply --kubeconfig=${kubeconfig_file} -f deployment/kubernetes/deployment.yml -n ${NAMESPACE}
