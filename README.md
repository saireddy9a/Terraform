# Terraform
**Cloud engineer Exercise:**

A template which deploys a webserver, hosting a single static page and create all resources required using Terraform IAC.

**Usage:**

To run this template, you need to execute:

$ terraform init

$ terraform plan

$ terraform apply

**Requirements:**

Terraform => 0.15.5

AWS => 2.65

**Providers:**

AWS => 2.65

**Resources:**

| Name        | Type         |
| ----------  |:------------:|	
|aws_availability_zones.available	|Data source|
|aws_vpc.Sample-VPC	|Resource|
|aws_subnet.Sample-Public-subnet	|Resource|
|aws_subnet.Sample-Public-subnet1	|Resource|
|aws_subnet.Sample-Public-subnet2	|Resource|
|aws_subnet.Sample-private-subnet	|Resource|
|aws_internet_gateway.Sample-IGW	|Resource|
|aws_route_table.Sample-Public-RT	|Resource|
|aws_route_table_association.Sample-Public-RT-association	|Resource|
|aws_route_table_association.Sample-Public-RT-association-subnet1	|Resource|
|aws_route_table_association.Sample-Public-RT-association-subnet2	|Resource|
|aws_eip.Sample-Nat-Gateway-EIP	|Resource|
|aws_nat_gateway.Sample-NAT_GATEWAY	|Resource|
|aws_route_table.Sample-NAT-Gateway-RT	|Resource|
|aws_route_table_association.Sample-Nat-Gateway-RT-Association	|Resource|
|aws_security_group.Sample-Sg	|Resource|
|aws_instance.Web-Server	|Resource|
|aws_security_group.Sample-LB-Sg1	|Resource|
|aws_lb.Sample-load-balancer	|Resource|
|aws_lb_target_group.Sample-Target-Group	|Resource|
|aws_lb_target_group_attachment.Sample-lb-targetgroup-association	|Resource|
|aws_lb_listener.Sample-LB-Listner	|Resource|
