
# todo :  creation à partir d'une liste 
resource "aws_iam_user" "devops_user" {
  name = "alfaco_devops"
  path = "/alfaco/"
}

# TODO : cration à partir d'une liste
# resource "aws_iam_access_key" "access_key" {
#   user    = aws_iam_user.devops_user.name
#   pgp_key = data.local_file.pgp_key.content_base64
# }