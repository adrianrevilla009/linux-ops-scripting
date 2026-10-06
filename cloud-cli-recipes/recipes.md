# Cloud CLI recipes

Read-only inspection commands. Set the account/profile explicitly and never paste credentials into scripts.

## AWS (aws-cli v2)

```bash
aws sts get-caller-identity --profile dev
aws ec2 describe-instances --profile dev --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,Tags[?Key==`Name`]|[0].Value]' --output table
aws s3 ls s3://orders-exports --profile dev --human-readable --summarize
aws logs tail /aws/lambda/orders-api --since 15m --follow --profile dev
```

## Azure (az)

```bash
az account show --query '{sub:name,id:id}'
az vm list -g orders-rg --show-details --query '[].{name:name,state:powerState}' -o table
az monitor activity-log list --offset 1h --query '[].{op:operationName.value,status:status.value}' -o table
```

## GCP (gcloud)

```bash
gcloud config list --format='value(core.project)'
gcloud compute instances list --format='table(name,zone.basename(),status)'
gcloud logging read 'resource.type="cloud_run_revision" severity>=ERROR' --limit 20 --freshness 1h
```
