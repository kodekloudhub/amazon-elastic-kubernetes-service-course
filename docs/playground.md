# Amazon EKS Cluster

In this guide, we will deploy an EKS cluster in the KodeKloud AWS Playground using Terraform. This cluster utilises an *unmanaged* node group, i.e. one we have to deploy and join manually as the playground does not support the creation of managed node groups.

If you want to do this manually from the AWS console, you can follow [this guide](https://github.com/kodekloudhub/certified-kubernetes-administrator-course/blob/master/managed-clusters/eks/console/README.md).

This terraform code will create an EKS cluster called `demo-eks` and will have the same properties as the manually deployed version linked above.

## Start an AWS Playground

[Click here](https://kodekloud.com/playgrounds/playground-aws) to start a playground, and click `START LAB` to request a new AWS Cloud Playground instance. After a few seconds, you will receive your credential to access AWS Cloud console.

Note that you must have KodeKloud Pro subscription to run an AWS playground. If you have your own AWS account, this should still work, however *you* will bear the cost for any resources created until you delete them.

This demo can be run from either your own laptop or from the AWS CloudShell
* From your laptop
    * You must have working versions of [terraform](https://developer.hashicorp.com/terraform/install), [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) and the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions) installed on your laptop. This is not a tutorial on how to install these things.
    * You will need to go to the IAM console in AWS, then create and download access keys for the playground user, then export these as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your terminal's environment.
* From CloudShell
    * No special requirements.
    * CloudShell is a Linux terminal you run inside the AWS console and has most of what we need preconfigured. [Click here](https://us-east-1.console.aws.amazon.com/cloudshell/home?region=us-east-1) to open CloudShell.

From here on, all commands must be run at the terminal (your own or CloudShell) as chosen above.

## Install Terraform

If using CloudShell, this is a required step. If using your laptop, we assume you have already installed terraform.

```bash
terraform_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
curl -O "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
unzip terraform_${terraform_version}_linux_amd64.zip
mkdir -p ~/bin
mv terraform ~/bin/
terraform version
```

## CloudShell Terminal Only - Create a directory to work in

On the AWS CloudShell terminal, the disk partition where the home directory is, is not large enough to install the required terraform providers, therefore we will create a directory to work in on a partition that does have sufficient space

```bash
{
sudo mkdir -p /opt/eks
sudo chown cloudshell-user /opt/eks
cd /opt/eks
}
```

## Deploy!

Proceed to the [deployment instructions](./deploy.md)
