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

variable "aws_profile" {
  default = "admincs"
}

variable "project"{
    type = object(
        {
        project_name=string
        project_version=string
        minimum_instance=number
        }
    )
    default= {
        project_name=" nom du project"
        project_version="0.0.1"
        minimum_instance=2
    }
}

variable "projects" {
    type=list
    default=["alfaco","cloudshopping"]
}