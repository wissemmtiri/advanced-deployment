## INFRASTRUCTURE DESCRIPTION

This terraform script creates 3 virtual machines: One **master** node with a public IP address for distant acces, and two **worker** nodes with only private IP addresses.

Manage to use the master node to install requirements on slaves using **Ansible**.

## HOW TO USE

### Setup a **Service Principal**

After getting your subscription ID, we can create our SP with below command:

    az ad sp create-for-rbac --name **service_principal_name** --role Contributor --scopes /subscriptions/**subscription_id**

Set these environment variables:

    set ARM_CLIENT_ID="xxx" <appID>
    set ARM_CLIENT_SECRET="xxx" <Password>
    set ARM_SUBSCRIPTION_ID="xxx" <SubscID>
    set ARM_TENANT_ID="xxx" <TenantID>

### TERRAFORM
1. Initialize terraform with "**_terraform init_**"
2. Format the code with "**_terraform fmt_**"
2. Check for any issues with "**_terraform validate_**" (valid)
3. Create a plan and store it, with "**_terraform plan -out tf.tfplan_**"
4. Execute the plan to apply changes with "**_terraform apply tf.tfplan_**"