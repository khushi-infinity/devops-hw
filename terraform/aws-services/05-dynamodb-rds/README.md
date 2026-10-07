# 05. DynamoDB and RDS - Database Services

## DynamoDB

Amazon DynamoDB is a managed NoSQL database designed for low-latency,
high-scale key-value and document workloads.

| Concept | Description |
|---|---|
| Table | A collection of related DynamoDB items. |
| Item | A record in a table, similar to a row but with flexible attributes. |
| Attribute | A named value stored on an item. |
| Partition key | The required primary-key field used to distribute items across partitions. |
| Sort key | An optional second key used to order and query items sharing a partition key. |

DynamoDB is useful for shopping carts, user profiles, sessions, game state,
device data, and applications requiring predictable low-latency access at
scale. Data modeling starts with access patterns and key design.

## RDS

Amazon Relational Database Service (RDS) is a managed relational database
service that handles common administration tasks such as provisioning,
patching, backups, and monitoring.

### Main concepts

- **Relational database:** Stores structured data in tables and supports SQL,
  joins, constraints, and transactions.
- **Supported engines:** Amazon Aurora, PostgreSQL, MySQL, MariaDB, Oracle,
  and Microsoft SQL Server.
- **DB instance:** The compute and memory capacity that runs the database
  engine, with attached storage and a network placement.
- **Security:** Use private subnets, security groups, encryption, IAM or
  database authentication where supported, and least-privilege credentials.
- **Backups:** Automated backups support point-in-time recovery; snapshots
  support manual backup and restore workflows.
- **Multi-AZ:** Maintains a synchronous standby in another Availability Zone
  for high availability and failover.
- **Read replicas:** Replicate data asynchronously to provide read scaling
  and support reporting workloads.

RDS is useful for transactional applications, e-commerce systems, content
management systems, and existing applications that require a relational
engine. Multi-AZ improves availability, while read replicas primarily improve
read capacity; they serve different purposes.
