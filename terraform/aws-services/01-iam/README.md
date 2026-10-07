# 01. IAM - Governance

## What is IAM?

AWS Identity and Access Management (IAM) controls authentication and
authorization for AWS resources. IAM determines who can access a resource,
which actions they can perform, and under which conditions.

## Core concepts

| Concept | Description |
|---|---|
| User | An identity for a person or application that needs long-term AWS access. |
| Group | A collection of users to which common permissions can be attached. |
| Role | An identity with permissions that can be assumed temporarily by users, AWS services, or external identities. |
| Policy | A JSON document that defines allowed or denied actions, resources, and conditions. |
| Permission | Authorization to perform a particular action on a particular resource. |

## Least privilege

Least privilege means granting only the permissions required for a task, on
only the required resources, for only the required time. Prefer specific
actions and resource ARNs over broad `*` permissions, and remove unused
permissions regularly.

## IAM best practices

- Do not use the root user for everyday work.
- Enable MFA, especially for the root user and privileged users.
- Use roles and temporary credentials instead of long-lived access keys.
- Grant permissions through groups or roles and use managed policies carefully.
- Apply least privilege and review permissions with IAM Access Analyzer.
- Monitor activity with CloudTrail and rotate or remove unused credentials.

## Common use cases

- Giving an EC2 instance permission to read from S3 through an instance role.
- Allowing a CI/CD pipeline to deploy AWS resources.
- Providing separate read-only and administrator access for teams.
- Federating workforce identities through an external identity provider.
