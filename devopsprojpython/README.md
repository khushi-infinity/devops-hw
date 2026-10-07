# Session 21: Final DevOps Project and Troubleshooting

## Project overview

This project is **TaskBoard**, a full-stack task-management application
implemented with a React frontend, FastAPI backend, and PostgreSQL database.
It demonstrates the complete DevOps delivery path:

```text
Application
    |
    v
Git and GitHub
    |
    v
GitHub Actions CI/CD
    |-- Backend tests
    |-- Frontend build
    |-- Docker image build
    |-- Trivy security scan
    `-- Image push to GHCR
    |
    v
Terraform
    |
    v
AWS VPC and EKS
    |
    v
Helm
    |
    v
Kubernetes
    |-- Frontend
    |-- Backend
    |-- PostgreSQL
    |-- Services
    |-- Ingress
    |-- HPA
    `-- Probes
    |
    v
Prometheus and Grafana
    |
    v
GitOps workflow and troubleshooting
```

The goal is to understand how source code becomes a tested, scanned,
containerized, deployable, observable, and troubleshootable application.

## Architecture diagram

```text
                                  GitHub
                                    |
                                    v
                            GitHub Actions
                    +-----------+-----------+
                    |                       |
                 Test/build              Scan/push
                    |                       |
                    +-----------+-----------+
                                |
                                v
                         GitHub Container Registry
                                |
                                v
Terraform provisions AWS VPC and EKS
                                |
                                v
                         Kubernetes cluster
                                |
             +------------------+------------------+
             |                  |                  |
          Ingress          Frontend            Backend
             |            React/Nginx           FastAPI
             |                  |                  |
             +------------------+------------------+
                                |
                           PostgreSQL
                                |
                    Prometheus and Grafana
```

## Technologies used

| Area | Technology |
|---|---|
| Frontend | React, Vite, Nginx |
| Backend | Python, FastAPI, SQLAlchemy |
| Database | PostgreSQL |
| Database migrations | Alembic |
| Testing | Pytest |
| Containers | Docker and Docker Compose |
| CI/CD | GitHub Actions |
| Registry | GitHub Container Registry |
| Infrastructure | Terraform, AWS VPC, Amazon EKS |
| Orchestration | Kubernetes |
| Packaging | Helm |
| Monitoring | Prometheus and Grafana |
| Security | Trivy container scanning, CI security gates |
| Troubleshooting | Kubernetes events, logs, resource inspection |

## Repository structure

```text
devopsprojpython/
|-- backend/
|   |-- app/
|   |   |-- config.py
|   |   |-- db.py
|   |   |-- main.py
|   |   |-- models.py
|   |   `-- schemas.py
|   |-- alembic/
|   |-- tests/
|   |-- Dockerfile
|   |-- requirements.txt
|   `-- .env.example
|-- frontend/
|   |-- src/
|   |-- Dockerfile
|   |-- nginx.conf
|   `-- package.json
|-- docker-compose.yml
|-- k8s/
|   `-- namespace.yaml
|-- helm/taskboard/
|   |-- Chart.yaml
|   |-- values.yaml
|   |-- values-dev.yaml
|   |-- values-prod.yaml
|   `-- templates/
|-- terraform/
|   |-- main.tf
|   |-- variables.tf
|   |-- outputs.tf
|   `-- versions.tf
|-- monitoring/
|   `-- prometheus-values.yaml
|-- troubleshooting/
|   |-- broken-image.yaml
|   `-- broken-service.yaml
|-- scripts/
|   `-- load-test.sh
|-- .github/workflows/
|   `-- ci-cd.yml
|-- .gitignore
|-- .dockerignore
|-- GRADING.md
`-- README.md
```

## Application

### Frontend

The React/Vite frontend provides a task dashboard with task creation,
listing, status, priority, filtering, and responsive styling. It calls the
backend through `/api/tasks` and `/api/tasks/stats`.

### Backend

FastAPI provides the REST API:

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/` | Service information |
| `GET` | `/health` | Liveness check |
| `GET` | `/ready` | Readiness check including database access |
| `GET` | `/metrics` | Prometheus metrics |
| `GET` | `/api/tasks` | List tasks |
| `GET` | `/api/tasks/{id}` | Read one task |
| `POST` | `/api/tasks` | Create a task |
| `PUT` | `/api/tasks/{id}` | Update a task |
| `DELETE` | `/api/tasks/{id}` | Delete a task |
| `GET` | `/api/tasks/stats` | Task statistics |

Interactive API documentation is available at `/docs`.

### Database and migrations

PostgreSQL stores task records. SQLAlchemy defines the database models and
Alembic manages schema migrations. The backend starts by creating the schema
for local/test safety; production deployments should run controlled
migrations before application rollout.

## Local application setup

### Prerequisites

- Docker Desktop or Docker Engine with Docker Compose
- Python 3.12 or later for local backend development
- Node.js 22 or later for local frontend development
- Git

### Run the complete stack with Docker Compose

```bash
docker compose up --build
```

Open:

```text
Frontend: http://localhost:3000
Backend docs: http://localhost:8000/docs
Health: http://localhost:8000/health
Readiness: http://localhost:8000/ready
Metrics: http://localhost:8000/metrics
```

Stop the stack:

```bash
docker compose down
```

Remove the PostgreSQL volume as well:

```bash
docker compose down -v
```

### Run backend directly

Start PostgreSQL separately, then:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL='postgresql+psycopg://taskboard:taskboard@localhost:5432/taskboard'
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

Run tests:

```bash
pytest -q
```

## Docker setup

### Backend image

The backend Dockerfile installs Python dependencies, copies the Alembic
migrations and FastAPI application, creates a non-root runtime user, and
starts Uvicorn on port 8000.

```bash
docker build -t taskboard-backend:local ./backend
docker run --rm -p 8000:8000 \
  -e DATABASE_URL='postgresql+psycopg://taskboard:taskboard@host.docker.internal:5432/taskboard' \
  taskboard-backend:local
```

### Frontend image

The frontend uses a multi-stage build:

```text
Node build stage
        |
        v
Static Vite files
        |
        v
Nginx runtime image
```

Build it with:

```bash
docker build -t taskboard-frontend:local ./frontend
```

The final image contains the compiled frontend and Nginx rather than the
Node.js build toolchain.

## Testing

Run backend tests before building or pushing images:

```bash
cd backend
pytest -q
```

The test gate prevents a failing backend from reaching the image build and
deployment stages:

```text
Code change
    |
    v
pytest fails
    |
    v
Pipeline stops
    |
    v
No broken image is promoted
```

## Kubernetes deployment

### Namespace

```bash
kubectl apply -f k8s/namespace.yaml
kubectl get namespace taskboard
```

### Kubernetes resources

The Helm chart generates the application resources required for deployment:

- Frontend Deployment
- Backend Deployment
- Frontend Service
- Backend Service
- PostgreSQL workload and storage
- ConfigMap-style application configuration
- Secret-based database configuration
- Ingress
- Horizontal Pod Autoscaler
- Prometheus ServiceMonitor
- Liveness, readiness, and startup probes

Kubernetes Deployments maintain the desired number of Pods. Services provide
stable names and networking while Pods are recreated. PostgreSQL uses
persistent storage for the local/classroom deployment.

## Helm deployment

Helm packages the Kubernetes resources as the `taskboard` chart:

```bash
helm lint helm/taskboard
helm template taskboard helm/taskboard
helm upgrade --install taskboard ./helm/taskboard \
  --namespace taskboard \
  --create-namespace \
  -f helm/taskboard/values-dev.yaml
```

Inspect the release:

```bash
helm list -n taskboard
kubectl get all -n taskboard
kubectl get ingress -n taskboard
kubectl get hpa -n taskboard
```

Use `values-dev.yaml` for local development and `values-prod.yaml` for
production-oriented overrides. Image repositories and tags can be changed
without editing the templates:

```bash
helm upgrade --install taskboard ./helm/taskboard \
  -n taskboard \
  --set backend.tag=<commit-sha> \
  --set frontend.tag=<commit-sha>
```

## ConfigMap, Secret, Ingress, HPA, probes, and storage

### Configuration and secrets

Non-sensitive settings belong in a ConfigMap. Database credentials belong in
a Kubernetes Secret or an external secret manager. Do not commit real
credentials to Git.

### Ingress

The Ingress routes the application host and API path:

```text
/taskboard.local/      -> frontend Service
/taskboard.local/api   -> backend Service
```

An Ingress resource requires an installed Ingress Controller. The resource
alone does not provide a load balancer.

### HPA

The HPA scales the backend based on CPU:

```text
low traffic  -> minimum replicas
high CPU     -> additional replicas
```

Inspect it with:

```bash
kubectl get hpa -n taskboard
kubectl describe hpa -n taskboard
```

HPA requires resource requests and a metrics provider such as Metrics Server.
Use `scripts/load-test.sh` for controlled load during a demonstration.

### Probes

- Liveness probe: restarts an unhealthy container.
- Readiness probe: removes a Pod from Service traffic until it is ready.
- Startup probe: gives slow-starting containers time to initialize.

The backend endpoints `/health` and `/ready` support these checks.

### Storage

PostgreSQL uses a PersistentVolumeClaim in the classroom Kubernetes
configuration. Production workloads should use a managed database such as
Amazon RDS or a properly managed Kubernetes storage class.

## Terraform infrastructure

Terraform provisions the AWS foundation:

```text
VPC
|-- Public subnets
|-- Private subnets
|-- NAT Gateway
`-- EKS cluster
    `-- Managed node group
```

Run from `terraform/`:

```bash
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Configure `kubectl` with the EKS cluster after provisioning. Inspect outputs:

```bash
terraform output
terraform show
terraform state list
```

Destroy the infrastructure when the project is finished:

```bash
terraform plan -destroy
terraform destroy
```

Terraform state contains infrastructure identifiers and must not be committed
if it contains sensitive values. Use remote state and locking for a shared
team deployment.

## CI/CD pipeline

The workflow in `.github/workflows/ci-cd.yml` has three stages:

```text
TEST
  |
  v
BUILD + SCAN + PUSH
  |
  v
DEPLOY
```

### Test stage

- Checks out the repository.
- Installs Python dependencies.
- Runs `pytest -q`.
- Installs Node.js dependencies.
- Builds the frontend.

### Build, security, and registry stage

- Builds backend and frontend Docker images.
- Tags images with the Git commit SHA.
- Runs Trivy against both images.
- Fails on HIGH and CRITICAL unfixed vulnerabilities.
- Pushes passing images to GHCR.

### Deploy stage

On pushes to `main`, the workflow:

- Installs Helm.
- Configures `kubectl` from the `KUBE_CONFIG_DATA` secret.
- Runs `helm upgrade --install`.
- Deploys the exact images built from the commit SHA.

Required repository configuration includes a GitHub token with package write
permission and a protected Kubernetes configuration secret. Never print
secrets in workflow logs.

## DevSecOps implementation

Security is applied as multiple controls rather than one scan:

| Control | Purpose | Project implementation |
|---|---|---|
| SAST | Finds insecure patterns in source code | Add or enable CodeQL/Semgrep in GitHub Actions. |
| SCA | Finds vulnerable dependencies | Review Python and npm dependency reports and enable dependency review. |
| Secret scanning | Detects committed credentials | Enable GitHub secret scanning and push protection. |
| Container scanning | Finds image vulnerabilities | Implemented with Trivy in the build pipeline. |
| Security gates | Stops unsafe promotion | Trivy exits with failure for HIGH/CRITICAL findings; tests must pass first. |
| Runtime security | Limits deployed risk | Use non-root images, least-privilege service accounts, network policy, and restricted Secrets. |

The current workflow directly implements testing and Trivy container scanning.
SAST, SCA, and GitHub secret scanning should be enabled in repository
settings or added as dedicated workflow jobs before production use.

## Monitoring and logs

The backend exposes `/metrics` for Prometheus. The Helm chart includes a
ServiceMonitor template for Prometheus Operator installations. Grafana can
visualize request count, error rate, latency, CPU, memory, Pod health, and
HPA behavior.

Useful commands:

```bash
kubectl logs deployment/taskboard-backend -n taskboard
kubectl get pods -n taskboard
kubectl describe pod <pod-name> -n taskboard
kubectl get events -n taskboard --sort-by=.lastTimestamp
kubectl top pods -n taskboard
kubectl top nodes
```

The monitoring questions are:

- Is the application reachable?
- Are requests failing?
- Which endpoint is slow?
- Are Pods restarting?
- Is CPU or memory approaching a limit?
- Is the HPA reacting to load?

## GitOps workflow

GitOps treats Git as the source of truth for Kubernetes desired state:

```text
Developer edits Helm values or manifests
                    |
                    v
              Git commit and push
                    |
                    v
              GitOps controller
                    |
             Compare and reconcile
                    |
                    v
                Kubernetes
```

The normal workflow is:

1. Change the versioned deployment configuration.
2. Review the diff in a pull request.
3. Merge the approved change.
4. A GitOps controller detects the new revision.
5. The controller applies the desired state.
6. Verify synchronization, rollout health, and application metrics.

For a production implementation, store the Helm values or rendered
environment manifests in a GitOps repository and use Argo CD or Flux to
reconcile them. Avoid making routine production changes directly with
`kubectl`.

## Final troubleshooting challenge

The `troubleshooting/` directory contains intentionally broken manifests.
The objective is to identify the symptom, investigate evidence, find the
root cause, fix it, verify the solution, and document the result.

### Challenge 1: Broken image

Apply the broken workload:

```bash
kubectl apply -f troubleshooting/broken-image.yaml
kubectl get pods -n taskboard
```

Investigate:

```bash
kubectl describe pod <pod-name> -n taskboard
kubectl get events -n taskboard --sort-by=.lastTimestamp
```

Expected root cause:

```text
ImagePullBackOff or ErrImagePull
        |
        v
Invalid image repository or tag
```

Fix the image reference, apply the corrected manifest, and verify:

```bash
kubectl get pods -n taskboard
kubectl rollout status deployment/<deployment-name> -n taskboard
```

### Challenge 2: Broken Service

Apply the broken Service:

```bash
kubectl apply -f troubleshooting/broken-service.yaml
kubectl get svc -n taskboard
kubectl get endpoints -n taskboard
```

Compare Service selectors with Pod labels:

```bash
kubectl get pods -n taskboard --show-labels
kubectl describe service <service-name> -n taskboard
```

Expected root cause:

```text
Selector does not match Pod labels
        |
        v
No endpoints
        |
        v
Service cannot route traffic
```

Correct the selector and verify that endpoints appear and traffic reaches the
application.

### Troubleshooting record

For each issue, document:

| Item | Record |
|---|---|
| Symptom | What failed or appeared unhealthy? |
| Evidence | Which logs, events, or resource descriptions were inspected? |
| Root cause | Why did the failure happen? |
| Fix | What configuration or resource was changed? |
| Verification | Which command proves the issue is resolved? |

## End-to-end demonstration checklist

- [ ] Start the application and create a TaskBoard task.
- [ ] Exercise the REST API through FastAPI Swagger.
- [ ] Run backend tests.
- [ ] Build frontend and backend Docker images.
- [ ] Push a commit to GitHub.
- [ ] Show GitHub Actions test and build stages.
- [ ] Show Trivy image scanning and the security gate.
- [ ] Show images in GHCR.
- [ ] Provision or inspect AWS infrastructure with Terraform.
- [ ] Deploy the Helm release to Kubernetes.
- [ ] Verify Deployments, Services, ConfigMap, Secret, Ingress, HPA, probes, and storage.
- [ ] Show application logs and Prometheus/Grafana monitoring.
- [ ] Demonstrate a GitOps configuration change.
- [ ] Introduce and troubleshoot the broken image.
- [ ] Introduce and troubleshoot the broken Service.
- [ ] Destroy temporary cloud resources after the demonstration.

## Lessons learned

- Automated tests prevent known application regressions from being promoted.
- Immutable image tags connect a deployment to an exact Git commit.
- Terraform manages cloud infrastructure; Kubernetes manages workloads.
- Helm makes Kubernetes configuration reusable across environments.
- ConfigMaps hold configuration, while Secrets protect sensitive values.
- Probes determine whether containers should receive traffic or be restarted.
- HPA requires metrics and resource requests to make scaling decisions.
- Metrics show trends, logs explain events, and traces explain request paths.
- GitOps makes the desired state reviewable and continuously reconciled.
- Troubleshooting should use evidence from status, events, logs, and selectors
  rather than guesswork.

## Local validation screenshots

The following terminal-output screenshots document the local validation
performed for this project:

### Application tests and Docker builds

The backend test suite passed, Docker Compose configuration was valid, and
both backend and frontend images were built successfully.

![Backend tests and Docker image builds](assets/local-tests-and-docker.svg)

### Kubernetes and Helm tooling

The local Kubernetes, kind, and Helm client versions used for the project are
shown below. The Helm chart also passed `helm lint`.

![Kubernetes and Helm validation](assets/kubernetes-helm-tools.svg)

### Terraform validation

Terraform formatting, provider initialization without a backend, and
configuration validation completed successfully. AWS resources were not
applied during this local validation run.

![Terraform formatting, initialization, and validation](assets/terraform-validation.svg)

### Application setup

![Application setup](assets/application-setup.svg)

The local Docker Compose stack was opened in a browser after the backend and
frontend started successfully. The screenshot below is the actual TaskBoard
frontend served by this project at `http://localhost:3000`.

![Running TaskBoard frontend](assets/taskboard-frontend-real.png)

### Kubernetes deployment

![Kubernetes deployment](assets/kubernetes-deployment.svg)

### Helm deployment

![Helm deployment](assets/helm-deployment.svg)

### CI/CD pipeline

![GitHub Actions CI/CD pipeline](assets/ci-cd-pipeline.svg)

### DevSecOps scanning

![DevSecOps security scan](assets/devsecops-scanning.svg)

### Terraform infrastructure

![Terraform infrastructure](assets/terraform-infrastructure.svg)

### Monitoring dashboard

![Monitoring configuration and workflow](assets/monitoring-dashboard.svg)

### GitOps workflow

![GitOps workflow](assets/gitops-workflow.svg)

### Troubleshooting

![Troubleshooting broken image deployment](assets/troubleshooting.svg)

## Cleanup

```bash
helm uninstall taskboard -n taskboard
kubectl delete namespace taskboard
cd terraform
terraform destroy
```

Use cleanup commands only after confirming that the resources belong to this
exercise. Do not delete shared production resources.
