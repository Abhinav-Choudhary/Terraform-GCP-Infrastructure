# Terraform-Google Cloud-Infrastructure as Code
Repository for course CSYE 6225 Network Structures and Cloud Computing offered by Northeastern University and taken in Spring 2024. This repository deals with using Terraform as infrastructure as Code platform and sets up Virtual Private Cloud (VPC) on Google Cloud.

# Enabled Api's
Following Google Cloud Api's have been enabled for this project:
- Compute Engine API

# How to run the application
- Install Gcloud cli and Terraform
- Run below command to set up google cloud credentials on local device
  - gcloud auth application-default login
- If you wish to create multiple vpc's at once or provide custom names for network, subnets, routes, etc. modify "main.tf" file.
- Navigate to project repository on command line and run below Terraform commands
  - Initialize the repository: terraform init
  - Perform validation checks: terraform validate
  - Create execution plan: terraform plan
  - Apply changes mentioned in execution plan: terraform apply
  - Destroy existing vpc: terraform destroy
