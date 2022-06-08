variable "ec2_tag_name" {
  default = "noname"
}

variable "public_instance"{
  default = true
}
variable "instance_type" {
  default="t2.micro"
}
variable "key_pair" {
  default =""
}
variable ami_name {
  default="ami-0d3c032f5934e1b41"
}
variable ec2_role{
  default = ""
}