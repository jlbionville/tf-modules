output "instanceId" {
  description = "instance Id of the ec2 created"
  value       = aws_instance.wordpress.id
}
output "InstanceIP" {
  description = "instance Id of the ec2 created"
  value       = aws_instance.wordpress.public_ip
}