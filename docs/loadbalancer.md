# Deploy loadbalancer support

This guide assumes you are still in the `eks` directory having completed running terraform and joining cluster nodes.

Now we will install the AWS LoadBalancer provider, which can automatically provision an Application Load Balancer in front of `Ingress` or `Gateway` resources or a Network Load Balancer in front of a `Service` of type `LoadBalancer`.

## Prerequisites

* Ensure you already deployed `cert-manager`. See [here](what-next.md#cert-manager) if you did not.
* Ensure you already deployed `Gateway API`. See [here](what-next.md#gateway-api) if you did not.

## Install controller

1. Tag all the subnets with the labels required for the loadbalancer controller to identify them as subnets that a loadbalancer's public endpoints can be bound to. Run the following command:

    ```bash
    ../resources/loadbalancer/tag-subnets.sh
    ```


1. Install an `IngressClass` resource that must be referred in any `Ingress` resource which notifies the load balancer controller to wire up an ALB.

    ```bash
    kubectl apply -f ../resources/loadbalancer/ingress-class.yaml
    ```

1. Install load balancer controller

    ```bash
     kubectl apply -f ../resources/loadbalancer/loadbalancer_v3_4_0_full.yaml
    ```

    Wait for the `aws-loadbalancer-controller` pod in the `kube-system` namespace to be running.

## Install test applications

All the following are installed in separate namespaces, so you can launch them all in the same cluster.

### ALB via Ingress resource

Now we will install the 2048 game, which will be served publicly by an ALB

1. Install the [game manifest (Ingress version)](../resources/loadbalancer/2048-ingress.yaml)

    ```bash
    kubectl apply -f ../resources/loadbalancer/2048-ingress.yaml
    ```

1. Go to the [loadbalancers view](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:) in the console and wait for the `State` of the new loadbalancer to be `Active`, then copy its DNS name. The DNS name looks similar to this
    ```
    k8s-game2048-ingress2-46dbc758ae-123456789012.us-east-1.elb.amazonaws.com
    ```

1. Put `http://` in front of this and then paste into your browser. The game should come up.

Note that this manifest deploys a `NodePort` service, *not* a `LoadBalancer` one and uses an `Ingress` resource to indicate that an ALB is required. The Application Load Balancer *is* the ingress controller, thus there is no separate ingress controller workload (like `ingress-nginx`) as it isn't necessary. The ingress logic is done inside the ALB via listeners and target groups, and the ALB binds directly to the service node port on all the cluster nodes.

### ALB via Gateway API

1. Install the [game manifest (Gateway API version)](../resources/loadbalancer/2048-gateway-api.yaml)

    ```bash
    kubectl apply -f ../resources/loadbalancer/2048-gateway-api.yaml
    ```

1. Go to the [loadbalancers view](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:) in the console and wait for the `State` of the new loadbalancer to be `Active`, then copy its DNS name. The DNS name looks similar to this
    ```
    k8s-game2048-ingress2-46dbc758ae-123456789012.us-east-1.elb.amazonaws.com
    ```

1. Put `http://` in front of this and then paste into your browser. The game should come up.

Note that in this version instead of an `Ingress`, we define a `GatewayClass` for the load balancer creation, a `Gateway` that refers to the `GatewayClass` and a couple of additional resources that are used to set the ALB configuration. Routing to the game's `ClusterIP` service is now via `HTTPRoute`.
