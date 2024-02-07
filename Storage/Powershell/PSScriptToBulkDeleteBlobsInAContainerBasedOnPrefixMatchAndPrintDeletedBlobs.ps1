container_name="EnterContainerName"
storage_account="EnterStorageAccountName"
account_key="EnterStorageAccountKeys"
 
# Get the list of blobs before deletion
before_deletion=$(az storage blob list --container-name $container_name --account-name $storage_account --account-key $account_key  --output json)
 
# Delete the blob
az storage blob delete-batch  --account-name $storage_account -s $container_name --pattern "dir1/*" --account-key $account_key
 
# Get the list of blobs after deletion
after_deletion=$(az storage blob list --container-name $container_name --account-name $storage_account --account-key $account_key --output json)
 
# Compare the lists to find the deleted blob
deleted_blob=$(comm -23 <(echo "$before_deletion" | jq -r '.[].name' | sort) <(echo "$after_deletion" | jq -r '.[].name' | sort))
 
echo "Deleted Blob: $deleted_blob"
