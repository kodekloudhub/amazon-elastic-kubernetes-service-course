# Deploying the Cluster

**IMPORTANT**: Ensure that all resources are created in the `us-east-1` (N. Virginia) region

If you came here from the [Amazon EKS course](https://learn.kodekloud.com/user/courses/aws-eks), this is lab step 3.

1. Clone the Repository

    Clone the required repository

    ```bash
    git clone https://github.com/kodekloudhub/amazon-elastic-kubernetes-service-course
    ```

1. Navigate to the EKS Directory

    Change into the EKS directory

    ```bash
    cd amazon-elastic-kubernetes-service-course/eks
    ```

1. Initialize Terraform

    Initialize the Terraform configuration

    ```bash
    terraform init
    ```

1. Plan the Terraform Deployment

    Run Terraform plan to review the changes that will be applied

    ```bash
    terraform plan
    ```

1. Apply the Terraform Configuration

    Apply the Terraform configuration to provision the EKS cluster. This step will take up to 10 minutes to complete

    ```bash
    terraform apply
    ```

    When prompted, type `yes` to confirm.

1. Retrieve Outputs

    After Terraform completes, note the output values for `NodeAutoScalingGroup`, `NodeInstanceRole`, and `NodeSecurityGroup`. You will see something similar to this

    ```
    Outputs:

    NodeAutoScalingGroup = "demo-eks-stack-NodeGroup-UUJRINMIFPLO"
    NodeInstanceRole = "arn:aws:iam::387779321901:role/demo-eks-node"
    NodeSecurityGroup = "sg-003010e8d8f9f32bd"
    ```

    Make sure to take note of the Terraform outputs, particularly the `NodeInstanceRole`, as you will need it for the next task.

Should any of the above fail with an error like the following it means the AWS environment did not start with sufficient subnets to deploy a cluster. Please reset the lab and try again. If it persists, then please report it in one of the community forums.

```
│ Error: Invalid index
│
│   on eks.tf line 45, in resource "aws_eks_cluster" "demo_eks":
│   45:       data.aws_subnets.public.ids[2]
│
│       data.aws_subnets.public.ids is list of string with 2 elements
```

Next: [Set up access and join nodes](./nodes.md)

