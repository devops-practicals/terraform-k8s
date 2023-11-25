# Basic provisioning of EKS with Terraform

You can provision a basic EKS cluster with Terraform with the following commands:

```bash
terraform init
terraform plan
terraform apply
```

It might take a while for the cluster to be created (up to 15-20 minutes).

- Once EKS Cluster is ready, execute below command to generate the kubeconfig file to connect to EKS cluster using kubectl.
```
aws eks update-kubeconfig --region ap-south-1 --name devops-practicals-development
```


As soon as the cluster is ready, you should find a `kubeconfig_learnk8s` kubeconfig file in the current directory.
