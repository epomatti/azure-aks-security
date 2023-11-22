# Azure AKS Security

AKS security features implemented.

Create the cluster:

```sh
terraform init
terraform apply -auto-approve
```

Configure the Kubernetes cluster:

```sh
az aks approuting enable -g rg-petzexpress -n aks-petzexpress

az aks get-credentials -n aks-petzexpress -g rg-petzexpress

kubectl create namespace helloworld
kubectl apply -f k8s/deployment.yaml -n helloworld
kubectl apply -f k8s/service.yaml -n helloworld
kubectl apply -f k8s/ingress.yaml -n helloworld
kubectl get ingress -n helloworld
```

## Authentication options

1. Local accounts with Kubernetes RBAC
2. Entra ID authentication with Kubernetes RBAC
3. Entra ID authentication with Azure RBAC

Enable Entra authentication with Azure RBAC to use RBAC [built-in][rbac-built-in-roles] roles.

Kubernetes RBAC details can be found in the [documentation][k8s-rbac].

# RBAC access to secrets

# RBAC: Fleet Manager x Service


[k8s-rbac]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
[rbac-built-in-roles]: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
