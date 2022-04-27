#Copyright 2021 Hewlett Packard Enterprise Development LP
# Percona XtraDB cluster
Percona XtraDB Cluster (PXC) is a high availability, open-source, MySQL clustering solution that helps enterprises minimize unexpected downtime and data loss, reduce costs, and improve the performance and scalability of your database environments

This readme is intended to capture the steps to spin up a database in VMaaS on-demand.
## Percona XtraDB cluster in VMaaS
The following steps bring up 3 node PerconaDB XtraDB cluster in HPE GreenLake for private cloud.
- Prerequisites
    ```sh
    1. CentOS 7.x virtual image in GLPC
    2. A service client to authenticate with HPE GreenLake
    ```
- Install Terraform
    ```sh
    https://learn.hashicorp.com/tutorials/terraform/install-cli (>=v0.13)
    ```
- Download Ansible
    ```sh
    https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
    ```
- Install HPE GreenLake Terraform provider
    ```sh
    bash <(curl -sL https://raw.githubusercontent.com/HewlettPackard/terraform-provider-hpegl/main/tools/install-hpegl-provider.sh)
    ```
- Clone the repository
    ```sh
    git clone https://github.com/hpe-hcss/customerzero.git
    cd  terraform/perconadb
    ```
- Update the variables.tf
- Export the environment variables
    ```sh
    #### API-vended Service Client
    export HPEGL_TENANT_ID=< tenant-id >
    export HPEGL_USER_ID=< service client id >
    export HPEGL_USER_SECRET=< service client secret >
    export HPEGL_IAM_SERVICE_URL=< the "issuer" URL for the service client  >
 
    #### HPE Service Client
    export HPEGL_TENANT_ID=< tenant-id >
    export HPEGL_USER_ID=< service client id >
    export HPEGL_USER_SECRET=< service client secret >
    export HPEGL_IAM_SERVICE_URL=< GL iam service url, defaults to https://client.greenlake.hpe.com/api/iam >
    export HPEGL_API_VENDED_SERVICE_CLIENT=false
    
    #### TF VARS
    export TF_VAR_vm_password=<Remote host password>
    export TF_VAR_vm_username=<Reomte host username>
    export TF_VAR_percona_root_password=<PerconaDB root password>
    export TF_VAR_sst_password=<PerconaDB sst password>
    export TF_VAR_sst_user=<PerconaDB sst username>
    
    export TF_CLI_ARGS_plan="-parallelism=1"
    export TF_CLI_ARGS_apply="-parallelism=1"
    export TF_CLI_ARGS_destroy="-parallelism=1"
    ```
- Run Terraform plan and apply
    ```sh
    terraform plan
    terraform apply
    ```
## Verifying Replication
Use the following procedure to verify replication by creating a new database on the second node, creating a table for that database on the third node, and adding some records to the table on the first node.
- Create a new database on the second node
    ```sh
    mysql@pxc2> CREATE DATABASE percona;
    Query OK, 1 row affected (0.01 sec)
    ```
- Create a table on the third node
    ```sh
    mysql@pxc3> USE percona;
    Database changed
    
    mysql@pxc3> CREATE TABLE example (node_id INT PRIMARY KEY, node_name VARCHAR(30));
    Query OK, 0 rows affected (0.05 sec)
    ```
- Insert records on the first node
    ```sh
    mysql@pxc1> INSERT INTO percona.example VALUES (1, 'percona1');
    Query OK, 1 row affected (0.02 sec)
    ```
- Retrieve rows from the table on the second node
    ```sh
    mysql@pxc2> SELECT * FROM percona.example;
    +---------+-----------+
    | node_id | node_name |
    +---------+-----------+
    |       1 | percona1  |
    +---------+-----------+
    1 row in set (0.00 sec)
    ```

