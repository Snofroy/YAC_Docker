# YAC_Docker
Yandex Cloud Terraform Ansible Docker

A ready-made manifest for teraforms for deploying virtual machines with the CentOS operating system in the Yandex cloud.

There is also Ansible with the geerlingguy.docker role of Docker installation.

It is necessary to fill in the following fields in the file `variables.tfvars`:

```
my_login = ""
my_email = ""
my_ssh_key = ""
ya_cloud_id = ""
ya_folder_id = ""
ya_zone = ""
ya_account_key = ""
ya_quantity_centos = ["centos1", "centos2"]
ya_platform_id = ""
ya_image_id_centos = ""
```

Before launching, install the role:

```
ansible-galaxy install geerlingguy.docker
```

Then run terraform:

```
terraform init
terraform plan -var-file=variables.tfvars
terraform apply -var-file=variables.tfvars
```
