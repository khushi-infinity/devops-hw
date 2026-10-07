# Session 18: Terraform and Infrastructure as Code

This project creates an AWS S3 bucket with Terraform and documents the
complete Terraform workflow.

## Project Structure

```text
terraform-s3-demo/
|
|-- README.md
|-- providers.tf
|-- variables.tf
|-- terraform.tfvars (optional; defaults are defined in variables.tf)
|-- main.tf
|-- outputs.tf
|-- .gitignore
```

## Architecture

```text
providers.tf
     |
     v
Provider Configuration
     |
     v
variables.tf
     |
     v
terraform.tfvars (optional)
     |
     v
main.tf
     |
     v
aws_s3_bucket.yatri12348
     |
     v
AWS S3 Bucket
     |
     v
outputs.tf
```

## Prerequisites

Install Terraform, the AWS CLI, and an AWS account with permission to create
and delete S3 buckets.

Configure AWS:

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

The bucket name must be globally unique. Set a unique name in
`terraform.tfvars` if the default name is already in use:

```hcl
aws_region  = "ap-south-1"
bucket_name = "your-unique-bucket-name"
```

## Terraform Workflow

### 1. Initialize

```bash
terraform init
```

Expected:

```text
Initializing the provider plugins...
Terraform has been successfully initialized!
```

### 2. Format

```bash
terraform fmt
```

`terraform fmt` formats all Terraform files in the project.

### 3. Validate

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

### 4. Plan

```bash
terraform plan
```

Expected:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

### 5. Apply

```bash
terraform apply
```

Terraform asks:

```text
Do you want to perform these actions?
  Only 'yes' will be accepted to approve.
Enter a value:
```

Enter:

```text
yes
```

Expected:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
Outputs:
bucket_arn = "arn:aws:s3:::your-unique-bucket-name"
bucket_name = "your-unique-bucket-name"
bucket_region = "ap-south-1"
```

### 6. Check State

```bash
terraform state list
```

Expected:

```text
aws_s3_bucket.yatri12348
```

Inspect the resource:

```bash
terraform state show aws_s3_bucket.yatri12348
```

### 7. Check Output

```bash
terraform output
```

Or:

```bash
terraform output bucket_name
```

Expected:

```text
"your-unique-bucket-name"
```

### 8. Verify Using AWS CLI

```bash
aws s3 ls
```

Or:

```bash
aws s3api head-bucket --bucket <bucket-name>
```

### 9. Destroy

After completing the demo:

```bash
terraform plan -destroy
```

Then:

```bash
terraform destroy
```

Enter:

```text
yes
```

Expected:

```text
Destroy complete! Resources: 1 destroyed.
```

## Screenshot evidence

The screenshots below are the captured outputs from the completed Terraform
S3 workflow. They are stored in the project's `../assets/` directory.

### 1. Terraform initialization, formatting, and validation

Commands shown:

```bash
terraform init
terraform fmt
terraform validate
```

![Terraform initialization, formatting, and validation output](../assets/terraformdemo.png)

### 2. Terraform plan and apply

Commands shown:

```bash
terraform plan
terraform apply
```

![Terraform plan and apply output](../assets/terraformdemo2.png)

### 3. Terraform output values

Command shown:

```bash
terraform output
```

![Terraform output values](../assets/terraformdemo3.png)

### 4. Terraform state and resource details

Commands shown:

```bash
terraform show
terraform state list
terraform state show aws_s3_bucket.yatri12348
```

![Terraform state and resource details](../assets/terraformdemo4.png)

### 5. Terraform destroy

Command shown:

```bash
terraform destroy
```

![Terraform destroy output](../assets/terraformdemo5.png)

## Complete Demo

Run:

```bash
aws sts get-caller-identity
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform state show aws_s3_bucket.yatri12348
terraform plan -destroy
terraform destroy
```

## Terraform Lifecycle

```text
              .tf files
                  |
                  v
          terraform init
                  |
                  v
          terraform validate
                  |
                  v
            terraform plan
                  |
                  v
           terraform apply
                  |
                  v
             AWS S3
                  |
                  v
          terraform state
                  |
                  v
          terraform destroy
```