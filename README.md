# Azure AKS Security

AKS security features implemented.

## Setup

Create the cluster:

```sh
terraform init
terraform apply -auto-approve
```

Enable application routing:

```sh
az aks approuting enable -g rg-petzexpress -n aks-petzexpress
```

Configure the cluster:

```sh
az aks get-credentials -g rg-petzexpress -n aks-petzexpress

kubectl create namespace helloworld
kubectl config set-context --current --namespace=helloworld

kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## Authentication options

1. Local accounts with Kubernetes RBAC
2. Entra ID authentication with Kubernetes RBAC
3. Entra ID authentication with Azure RBAC

Enable Entra authentication with Azure RBAC to use RBAC [built-in][rbac-built-in-roles] roles.

Kubernetes RBAC details can be found in the [documentation][k8s-rbac].

# RBAC access to secrets

```sh
kubectl get secrets/aks-helloworld --template='{{.data.password}}'
```

# RBAC: Fleet Manager x Service

Within Azure Kubernetes RBAC [built-in][rbac-built-in-roles] roles.


[k8s-rbac]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
[rbac-built-in-roles]: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
