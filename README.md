# Terraform-Google Cloud-Infrastructure as Code
Repository for course CSYE 6225 Network Structures and Cloud Computing offered by Northeastern University and taken in Spring 2024. This repository deals with using Terraform as infrastructure as Code platform and sets up Virtual Private Cloud (VPC) on Google Cloud.

# Linked Repositories
Explore the 2 additional repositories that complement this project, housing code for the REST-based CRUD operations APIs (Webapp) crafted in Java Enterprise Edition (J2EE), and the Serverless Lambda function implemented in Python.
[Webapp](https://github.com/Abhinav-Choudhary/Webapp)
<br>
[Serverless Lambda](https://github.com/Abhinav-Choudhary/Serverless)

# Enabled Api's
Following Google Cloud Api's have been enabled for this project:
- Compute Engine API
- Service Networking API
- Cloud DNS API
- Cloud Build API
- Cloud Functions API
- Cloud Logging API
- Cloud Pub/Sub API
- Eventarc API
- Cloud Pub/Sub API
- Cloud Run Admin API

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
