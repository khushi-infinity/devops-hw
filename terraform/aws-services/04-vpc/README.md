# 04. VPC - Networking

## What is a VPC?

Amazon Virtual Private Cloud (VPC) is a logically isolated network in AWS.
It provides control over IP addressing, subnets, routing, and traffic
filtering for AWS resources.

## Main concepts

| Concept | Description |
|---|---|
| CIDR | The IP address range assigned to the VPC or subnet, such as `10.0.0.0/16`. |
| Subnet | A range of VPC IP addresses associated with one Availability Zone. |
| Route table | Rules that decide where network traffic is sent. |
| Internet Gateway | Connects a VPC to the public internet for resources with suitable routes and public addresses. |
| NAT Gateway | Allows private-subnet resources to make outbound internet connections without accepting unsolicited inbound connections. |
| Security group | A stateful, instance-level firewall. |
| Network ACL | A stateless, subnet-level allow/deny filter. |

## Public and private subnets

A public subnet has a route to an Internet Gateway. A resource also needs a
public IPv4 address or other public access configuration to communicate
directly with the internet. A private subnet has no direct route to the
Internet Gateway; it commonly uses a NAT Gateway for outbound access.

Security groups are stateful and allow return traffic automatically. Network
ACLs are stateless, so inbound and outbound rules must be considered
separately. Use both with least privilege.

## Common design

A common application VPC has public subnets for load balancers, private
subnets for application servers, and isolated or private subnets for
databases. Route tables, security groups, and network ACLs are used together
to control the permitted traffic paths.
