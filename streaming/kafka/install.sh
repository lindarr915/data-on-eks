#!/bin/bash

read -p "Enter the region: " region
export AWS_DEFAULT_REGION=$region

# List of Terraform modules to apply in sequence
targets=(
  "module.vpc"
  "module.eks"
  "module.ebs_csi_driver_irsa"
  "module.eks_blueprints_addons"
  "module.eks_data_addons"
)

# Initialize Terraform
terraform init --upgrade

# Apply modules in sequence
for target in "${targets[@]}"
do
  echo "Applying module $target..."
  apply_output=$(terraform apply -target="$target" -var="region=$region" -auto-approve 2>&1 | tee /dev/tty)
  if [[ ${PIPESTATUS[0]} -eq 0 && $apply_output == *"Apply complete"* ]]; then
    echo "SUCCESS: Terraform apply of $target completed successfully"
  else
    echo "FAILED: Terraform apply of $target failed"
    exit 1
  fi
done

# Final apply to catch any remaining resources
echo "Applying remaining resources..."
apply_output=""
max_retry=3
counter=1
until apply_output=$(terraform apply -var="region=$region" -auto-approve 2>&1 | tee /dev/tty)
do
    [[ counter -eq $max_retry ]] && exit 1
    echo "FAILED: Terraform apply failed, will wait 30 seconds and retry. Try #$counter"
    sleep 30
    ((counter++))
done

if [[ ${PIPESTATUS[0]} -eq 0 && $apply_output == *"Apply complete"* ]]; then
  echo "SUCCESS: Terraform apply of all modules completed successfully"
else
  echo "FAILED: Terraform apply of all modules failed"
  exit 1
fi
