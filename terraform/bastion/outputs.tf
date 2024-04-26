output "username" {
  value       = "ec2-user"
  description = "The username used to connect to the EC2 instance."
}

output "pem_key_location" {
  value       = "s3://${aws_s3_bucket.bucket.id}/${aws_s3_bucket_object.private_key.key}"
  description = "The location in S3 where the PEM key file is stored."
}

output "public_ip" {
  value       = aws_instance.bastion_host.public_ip
  description = "The public IP address of the bastion host."
}

output "ssh_tunnel_command" {
  value       = "ssh -i ${aws_s3_bucket_object.private_key.key} -L localPort:dbHost:dbPort ec2-user@${aws_instance.bastion_host.public_ip}"
  description = "Command to create an SSH tunnel through the bastion host for connecting to the database. Replace 'localPort', 'dbHost', and 'dbPort' with your specific values."
}