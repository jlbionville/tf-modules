resource "aws_dynamodb_table" "esn-table" {
 name           = "esn"
 read_capacity  = 20
 write_capacity = 20
 hash_key       = "esn_name"

 attribute {
   name = "ens_name"
   type = "S"
 }
}