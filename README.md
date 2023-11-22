# Azure AKS Security


> ℹ️ Using Application Gateway for Containers (Preview). Check the documentation for [prerequisites]().

```sh
terraform init
terraform apply -auto-approve
```

```sh
kubectl create namespace helloworld
```


```sh
az aks approuting enable -g rg-petzexpress -n aks-petzexpress
az aks get-credentials -n aks-petzexpress -g rg-petzexpress
kubectl apply -f deploy.yaml -n helloworld
kubectl get ingress
```

# Authentication options

1. Local accounts with Kubernetes RBAC
2. Entra ID authentication with Kubernetes RBAC
3. Entra ID authentication with Azure RBAC

Enable Entra authentication with Azure RBAC to use RBAC [built-in][rbac-built-in-roles] roles.

Kubernetes RBAC details can be found in the [documentation][k8s-rbac].

# RBAC access to secrets

# RBAC: Fleet Manager x Service


[k8s-rbac]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
[rbac-built-in-roles]: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
