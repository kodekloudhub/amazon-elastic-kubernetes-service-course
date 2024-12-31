# Set up access and join nodes

1.  Create a KUBECONFIG for `kubectl`

    ```bash
    aws eks update-kubeconfig --region us-east-1 --name demo-eks
    ```

1.  Join the worker nodes

    1. Download the node authentication ConfigMap

        ```
        curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/aws-auth-cm.yaml
        ```

    1.  Edit the ConfigMap YAML to add in the `NodeInstanceRole` obtained from terraform

        ```bash
        vi aws-auth-cm.yaml
        ```

    1. Replace the placeholder text `<ARN of instance role (not instance profile)>` with the value of `NodeInstanceRole` from Terraform, then save and exit the editor. The ConfigMap looks like this before editing:

        ```yaml
        apiVersion: v1
        kind: ConfigMap
        metadata:
        name: aws-auth
        namespace: kube-system
        data:
        mapRoles: |
          - rolearn: <ARN of instance role (not instance profile)> # <- EDIT THIS
            username: system:node:{{EC2PrivateDNSName}}
            groups:
              - system:bootstrappers
              - system:nodes

        ```

1.  Apply the edited ConfigMap

    1. Apply the ConfigMap to join the nodes:

        ```bash
        kubectl apply -f aws-auth-cm.yaml
        ```

    1. Wait around 60 seconds for all nodes to join.

1. Verify the Nodes

    Verify that the nodes have joined the cluster and are in the `Ready` state. You may need to run the following several times until all nodes are ready.

    ```bash
    kubectl get node -o wide
    ```

    You should see 3 worker nodes in ready state. Note that with EKS you do not see control plane nodes, as they are managed by AWS.

    You can also view the completed cluster in the [EKS Console](https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1).

## Personal AWS Account

If you deployed the cluster into your own AWS account, you should delete resources when finished to avoid unwanted charges and also any risk of account compromise! This is *not* a security focused production grade deployment! Run the following:

```
terraform destroy
```