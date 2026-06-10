# Deploy loadbalancer support

This guide assumes you are still in the `eks` directory having completed running terraform and joining cluster nodes.

Now we will install the AWS LoadBalancer provider, which automatically provisions an Application Load Balancer in front of `Ingress` resources or a Network Load Balancer in front of a `Service` of type `LoadBalancer`.

## Install controller

1. Tag all the subnets with the labels required for the loadbalancer controller to identify them as subnets that a loadbalancer's public endpoints can be bound to. Run the following command:

    ```bash
    ../resources/loadbalancer/tag-subnets.sh
    ```

1. Install `cert-manager`

    [cert-mamager ](https://cert-manager.io/docs/) is required to generate YLS certificates on the fly for the loadbalancer controller's webhooks. Run the following command:

    ```bash
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml
    ```

    Wait for all pods in `cert-manager` namespace to be running.

1. Install an `IngressClass` resource that must be referred in any `Ingress` resource which notifies the load balancer controller to wire up an ALB.

    ```bash
    kubectl apply -f ../resources/loadbalancer/ingress-class.yaml

1. Install load balancer controller

    ```bash
     kubectl apply -f ../resources/loadbalancer/loadbalancer_v2_7_2_full.yaml
    ```

## Install a test application

Now we will install the 2048 game, which will be served publicly by an ALB

1. Install the game manifest

    ```bash
    kubectl apply -f ../resources/loadbalancer/2048-full.yaml
    ```

1. Go to the [loadbalancers view](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:) in the console and wait for the loadbalancer to be ready, then copy its DNS name. Put `http://` in front of this and then paste into your browser. The game should come up.
