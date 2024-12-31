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

1. Run the following command. It will check the lab/cloud environment for a few things that need to be correct for the cluster to deploy properly. If it tells you to restart the lab, then please do so. If it still tells you to restart the lab after 2 or 3 attempts, then please report in the forums.

    * If *and only if* you are running this lab directly from a Windows PowerShell terminal, run the following

        ```text
        .\check-environment.ps1
        ```

    * **Otherwise** for everything else (KodeKloud lab terminal, CloudShell, any Linux or Mac), instead run this:

        ```bash
        source check-environment.sh
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
    NodeInstanceRole = "arn:aws:iam::058264119838:role/eksWorkerNodeRole"
    NodeSecurityGroup = "sg-003010e8d8f9f32bd"
    ```

    Make sure to take note of the Terraform outputs, particularly the `NodeInstanceRole`, as you will need it for the next task.


Now, proceed to [Set up access and join nodes](./nodes.md)

