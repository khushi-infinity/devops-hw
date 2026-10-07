# 02. EC2 - Compute

## What is EC2?

Amazon Elastic Compute Cloud (EC2) provides resizable virtual servers in the
AWS cloud. An instance can be launched, configured, stopped, started, and
terminated as application capacity changes.

## Main concepts

| Concept | Description |
|---|---|
| AMI | A template containing an operating system and software used to launch an instance. |
| Instance type | Defines compute capacity, memory, networking, and optional accelerators. |
| Key pair | A public/private key used for secure instance login, commonly SSH on Linux. |
| Security group | A stateful virtual firewall that controls inbound and outbound traffic. |
| EBS | Persistent block storage volumes attached to EC2 instances. |
| Public IP | An address reachable from the internet when routing and security rules allow it. |
| Private IP | An address used for communication inside the VPC; it is not directly internet-routable. |

## Instance lifecycle

An instance can be `pending`, `running`, `stopping`, `stopped`, `rebooting`,
or `terminated`. Stopping usually preserves EBS-backed data but releases
compute capacity; terminating permanently removes the instance and may delete
its root volume depending on its settings.

## Common use cases

- Web and application servers.
- Development and test environments.
- Batch processing and scheduled jobs.
- Self-managed databases or specialized software.
- Workloads requiring custom operating systems or instance types.
