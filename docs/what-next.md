# What next?

You have now successfully deployed an EKS cluster. What can you do with it? The installation as it stands now will serve `NodePort` services directly to the internet, so you can browse those by pointing your browser at the IP address of one of the cluster nodes along with the `nodePort` value for your service.

However, there are a few other things we can add to it.

## Cert Manager

[cert-manager ](https://cert-manager.io/docs/) is a  workload for automatically generating server certificates for in-cluster webhooks. Some of the suggestions below (e.g. loadbalancer controller) have `cert-manager` as a prerequisite, so if you intend to try those, install `cert-manager` first:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml
```

## Gateway API

To practice with [Gateway API](https://gateway-api.sigs.k8s.io/), we need to first install its CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
```

## Loadbalancer Controller

Auto-provision AWS load balancers from the following resources

* `Service` of type `LoadBalancer`
* `Ingress` using `ingressClassName: alb`
* `Gateway` from Gateway API

See [this page](./loadbalancer.md)

