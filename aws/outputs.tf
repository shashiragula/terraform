#---------root/outputs.tf---------
output "Bucket_Name" {
    value = "${module.storage.bucketname}"
}