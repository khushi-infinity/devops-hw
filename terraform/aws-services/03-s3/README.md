# 03. S3 - Storage

## What is S3?

Amazon Simple Storage Service (S3) is highly durable object storage. Data is
stored as objects inside buckets and accessed through AWS APIs, the console,
or compatible tools.

## Main concepts

| Concept | Description |
|---|---|
| Bucket | A globally unique container for objects in an AWS Region. |
| Object | A file and its metadata, addressed by a key within a bucket. |
| Storage class | A cost and access pattern choice, such as Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant Retrieval, Glacier Flexible Retrieval, or Glacier Deep Archive. |
| Versioning | Keeps multiple versions of an object and helps recover from accidental deletion or overwrite. |
| Lifecycle policy | Automatically transitions or expires objects according to rules. |
| Encryption | Protects object data at rest using S3-managed keys or AWS KMS keys. |
| Bucket policy | A resource-based JSON policy controlling access to a bucket and its objects. |

## Security and management

Keep buckets private by default, enable Block Public Access, use least
privilege IAM and bucket policies, enable encryption, and consider logging
and versioning. Lifecycle rules can reduce storage cost by moving old data to
lower-cost classes or deleting data after its retention period.

## Common use cases

- Backups and archives.
- Static website assets.
- Data lakes and analytics files.
- Application uploads and downloads.
- Terraform state storage with appropriate locking and access control.
