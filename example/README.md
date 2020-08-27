# GKE How To

### GKE Authenticate
1) Execute the following to auth to Google via GCloud SDK.

```
gcloud auth login
gcloud auth application-default login
```

2) Export the Project ID you wish to use to deploy your cluster.
```
export GOOGLE_PROJECT='your-project-id-123'
```

If you have multiple Projects available you can use the GCloud CLI to see them:
```
gcloud projects list
```

### GKE Deploy the cluster
1) Take the `./main.tf` and copy it locally.

2) Make changes to the variables as you see fit.

3) Initialize Terraform.
```
terraform init
```

4) Run apply.
```
terraform plan -out plan.out
terraform apply plan.out
```

### Using with Kubectl
A `kubeconfig.conf` will be created locally that be used to authenticate against the cluster.

```
export KUBECONFIG=kubeconfig.conf

kubectl get cluster-info

```
### GKE Destroy
1) Run destroy.
```
terraform destroy
```