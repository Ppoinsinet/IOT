argocd login localhost:30002
argocd app create ppoinsin-app --repo https://github.com/Ppoinsinet/ppoinsin-IOT-config.git --dest-server https://kubernetes.default.svc --dest-namespace dev --path  deploy
argocd app set ppoinsin-app --sync-policy automated --sync-option ApplyOutOfSyncOnly=true --self-heal

kubectl apply -f ingress.yml -n dev
