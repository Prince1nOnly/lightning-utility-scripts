#!/bin/bash

# Target directory for the kernels
TARGET_DIR="/home/zeus/miniconda3/envs/cloudspace/share/jupyter/kernels"

# Get the list of all installed kernels
kernels=$(jupyter kernelspec list --json | jq -r '.kernelspecs | to_entries[] | .value.resource_dir')

# Iterate through each kernel directory
for kernel_dir in $kernels; do
    # Check if the kernel directory is not in the target directory
    if [[ $kernel_dir != $TARGET_DIR/* ]]; then
        # Extract the kernel directory name
        kernel_name=$(basename "$kernel_dir")
        target_path="$TARGET_DIR/$kernel_name"
        
        # Move the kernel if it does not already exist in the target directory
        if [[ -d "$target_path" ]]; then
            echo "Kernel $kernel_name already exists in the target directory. Skipping move."
        else
            echo "Moving kernel $kernel_name from $kernel_dir to $TARGET_DIR"
            mv "$kernel_dir" "$TARGET_DIR"
            if [[ $? -ne 0 ]]; then
                echo "Failed to move kernel $kernel_name. Please check permissions and try again."
            else
                echo "Kernel $kernel_name moved successfully."
            fi
        fi
    fi
done
