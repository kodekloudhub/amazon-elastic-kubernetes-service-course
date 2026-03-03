# Migration to Managed Node Groups

## Overview

This update migrates the EKS cluster from self-managed nodes to AWS Managed Node Groups.

## Benefits

- **92% less code**: Reduced from 250+ lines to 20 lines
- **Automatic node joining**: AWS handles bootstrap script
- **Better security**: No SSH keys in Terraform state
- **Automatic updates**: AWS manages AMI updates
- **Health monitoring**: Automatic node replacement
- **Easier debugging**: Status visible in EKS Console

## Breaking Changes

1. **SSH Access**: SSH key pairs removed. Use AWS Systems Manager Session Manager instead:
   ```bash
   aws ssm start-session --target <instance-id>
   ```

2. **Node Naming**: Node names changed from `worker-node-*` to `ip-10-0-*`

3. **CloudFormation**: CloudFormation stack removed (pure Terraform now)

## Migration Steps

### For Existing Clusters

If you have an existing cluster deployed with the old code:

1. **Backup your state:**
   ```bash
   terraform state pull > backup-state.json
   ```

2. **Export workloads:**
   ```bash
   kubectl get all --all-namespaces -o yaml > backup-workloads.yaml
   ```

3. **Update code** to new version

4. **Apply changes:**
   ```bash
   terraform init -upgrade
   terraform plan
   terraform apply
   ```

5. **Verify nodes:**
   ```bash
   kubectl get nodes
   ```

### For New Deployments

Simply follow the updated README.md instructions.

## Rollback

If needed, restore from backup:

```bash
terraform state push backup-state.json
git checkout <previous-commit>
terraform apply
```

## Support

For issues, please open a GitHub issue in the repository.
