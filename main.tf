provider "aws" {
  region = "eu-west-3"
}


resource "aws_instance" "example" {
  ami = "ami-09e513e9eacab10c1"
  instance_type = "t2.micro"
  tags = {
    Name = "pouet.example"
  }
}
