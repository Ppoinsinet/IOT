#!/bin/bash

# install docker
apt-get install -y docker
service docker start

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# install argocd CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# create k3d cluster
k3d cluster create my-cluster --api-port 6443 -p 8888:80@loadbalancer -p 30001:30001@agent:0 -p 30002:30002@agent:0 --agents 1

# create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# add argocd manifest
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait pod --all --for=condition=Ready --namespace=argocd --timeout=300s

# change argocd password to 'password'
kubectl -n argocd patch secret argocd-secret \
    -p '{"stringData": {
      "admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa",
      "admin.passwordMtime": "'$(date +%FT%T%Z)'"
    }}'

kubectl patch svc argocd-server -n argocd --patch-file patch.yaml
