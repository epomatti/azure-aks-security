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

## RBAC access to secrets

To test Azure RBAC access, login with the `AKSContributor` user to the Portal and connect with Cloud Shell.

First, it is important to understand login AKS available [permissions][aks-perm]. There are two options:

- `Azure Kubernetes Service Cluster Admin Role`
- `Azure Kubernetes Service Cluster User Role`

Get the credentials and login on the namespace:

```sh
az aks get-credentials -g rg-petzexpress -n aks-petzexpress
```

After that, [Azure RBAC built-in][azure-rbac-builtin-roles] may grant the access (Writer, Admin, Cluster Admin).

Test access to the secret:

```sh
kubectl config set-context --current --namespace=helloworld
kubectl get secrets/aks-helloworld --template='{{.data.password}}'
```

If getting trouble reading the secrets, check the permissions following the [documentation](https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac):

```sh
az role assignment create --role "Azure Kubernetes Service RBAC Reader" --assignee <AAD-ENTITY-ID> --scope $AKS_ID/namespaces/<namespace-name>
```

This thread also has an example for role binding: https://stackoverflow.com/a/69719593/3231778

## RBAC: Fleet Manager x Service

Within Azure Kubernetes RBAC [built-in][rbac-built-in-roles] roles.

## ACR

A Container Registry will be created and attached to the cluster.

To import an image to the registry:

```sh
az acr import  -n <acr-name> --source docker.io/library/nginx:latest --image nginx:v1
```

## Virtual network (VNET) integration

https://learn.microsoft.com/en-us/samples/azure-samples/private-aks-cluster-terraform-devops/private-aks-cluster-terraform-devops/
https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal
https://learn.microsoft.com/en-us/training/modules/deploy-azure-kubernetes-service-cluster/7-secure-network-flow


## Service Types

https://learn.microsoft.com/en-us/training/modules/plan-azure-kubernetes-service-deployment/7-network-access-azure-kubernetes-service

## Network modes

- Kubenet: NAT to pods. (can use VNET, or let it create)
- CNI: POD real IPs, but external to VNET will do NAT to the nodes.

## Entra ID integration

Information summarized from the [documentation][1]:

Methods:

- Integrated with Kubernetes RBAC
- Azure RBAC

Principals:

- Service Principals
- Managed Identities (recommended)

Default identities:

- Cluster identity
- Kubelet identity

Common permissions:

- Network Contributor
- Monitoring Metrics Publisher
- AcrPull


[k8s-rbac]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
[rbac-built-in-roles]: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
[aks-perm]: https://learn.microsoft.com/en-us/azure/aks/control-kubeconfig-access#available-permissions-for-cluster-roles
[azure-rbac-builtin-roles]: https://learn.microsoft.com/en-us/azure/aks/concepts-identity#built-in-roles
[1]: https://learn.microsoft.com/en-us/training/modules/deploy-azure-kubernetes-service-cluster/6-integrate-azure-active-directory-cluster