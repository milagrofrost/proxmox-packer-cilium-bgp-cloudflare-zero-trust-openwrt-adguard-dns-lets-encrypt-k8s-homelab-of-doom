# Velero install

I use velero to back up my k8s cluster.  All the resources are stored in a GCP bucket. 

## Installation

- RTFM (For GCP buckets) - https://github.com/vmware-tanzu/velero-plugin-for-gcp

```powershell

choco install velero

gcloud iam service-accounts create "velero" --display-name "Velero service account"

gcloud projects add-iam-policy-binding $projectId `
  --member "serviceAccount:$serviceAccountEmail" `
  --role "projects/$projectId/roles/velero.server"

gsutil mb gs://frostbit-k8s-backup-velero

gsutil iam ch "serviceAccount:$serviceAccountEmail:objectAdmin" "gs://frostbit-k8s-backup-velero"
gsutil iam ch "serviceAccount:$serviceAccountEmail:roles/storage.objectAdmin" "gs://frostbit-k8s-backup-velero"

$SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list `
 --filter="displayName:Velero service account" `
 --format 'value(email)')

gcloud iam service-accounts keys create credentials-velero --iam-account $SERVICE_ACCOUNT_EMAIL

velero install `
    --provider gcp `
    --plugins velero/velero-plugin-for-gcp:v1.10.1 `
    --bucket "frostbit-k8s-backup-velero" `
    --secret-file ./credentials-velero.json

```