1. Initialize terraform with "terraform init"
2. Check for any issues with "terraform validate" (valid)
3. Create a plan and store it, with "terraform plan -out tf.tfplan"
4. Execute the plan to apply changes with "terraform apply ./tf.tfplan"

NB: You need to change the subscription in azure CLI to be able to use certain resources (default=Azure For Students Starter, Required=Azure For Students)
command : 'az account set --subscription "subscription-id" '
