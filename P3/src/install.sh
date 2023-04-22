#!/bin/bash

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
k3d cluster create my-cluster # --api-port 6443 -p 8080:80@loadbalancer --agents 2

# create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# add argocd manifest
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# change argocd password to 'password'
kubectl -n argocd patch secret argocd-secret \
    -p '{"stringData": {
      "admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa",
      "admin.passwordMtime": "'$(date +%FT%T%Z)'"
    }}'

# add my app to argocd
argocd app create ppoinsin-app --repo https://github.com/Ppoinsinet/ppoinsin-badass-config.git --dest-server https://kubernetes.default.svc --dest-namespace dev --path  deploy
argocd app set ppoinsin-app --sync-policy automated --sync-option ApplyOutOfSyncOnly=true --self-heal