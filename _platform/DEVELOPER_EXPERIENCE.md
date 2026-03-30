# ZaveStudios — Developer Experience Standard v0.1

This document defines the canonical developer experience for working with ZaveStudios platform workloads.

## Chapter Guide

**Purpose**

Define the standard local-development and testing interface for governed
workload repositories.

**Read this when**

- evaluating whether a workload repository offers the required local experience
- deciding whether a DX complaint is a standards gap or an implementation gap
- reviewing how constrained local workflows should feel in practice

**Read next**

- `EXECUTION_ENVIRONMENTS.md` for where platform work should run
- `DEVELOPER_EXPERIENCE_JOURNEYS.md` for end-to-end workflow and gap-analysis
  scenarios
- `FRICTION_FEEDBACK.md` for how DX friction should be captured and prioritized

It exists to eliminate variance in:

- Local development setup
- Testing workflows
- Debugging practices
- Development-to-production parity

Every contract-governed workload repository (`tenant` and `portfolio`) must follow these standards.

---

## Purpose

The platform reduces infrastructure variance through contracts and generators.

Developer experience must follow the same principle:

**The constrained path must always be faster, safer, and easier than deviation.**

If every repository requires different setup steps, the platform creates cognitive debt rather than reducing it.

---

## Local Development Standard

### Mandatory Requirement: docker-compose

All contract-governed workload repositories must provide a **docker-compose-based local development environment**.

This is non-negotiable for workload repositories classified as `tenant` or `portfolio` in REPO_TAXONOMY.md.

---

### Required Files

Every contract-governed workload repository must include:

#### 1. `docker-compose.yml` or `docker-compose.yaml`

**Location:** Repository root

**Purpose:** Define complete local development environment

**Requirements:**
- Includes all required services (application, database, cache, etc.)
- Uses `build: .` to build from repository Dockerfile
- Mirrors production runtime configuration where feasible
- Exposes services on localhost for development access
- Uses named volumes for data persistence
- Defines health checks where applicable

Either filename is acceptable. Repositories should choose one and avoid keeping both.

**Example:**

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://postgres:password@db:5432/workload_dev
      REDIS_URL: redis://redis:6379/0
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    volumes:
      - .:/app
    command: python -m workload

  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: workload_dev
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

#### 2. `.env.example`

**Location:** Repository root

**Purpose:** Document required environment variables

**Requirements:**
- Lists all environment variables needed for local development
- Provides example values (non-sensitive)
- Developers copy to `.env` and customize
- `.env` is gitignored

**Example:**

```bash
# Database
DATABASE_URL=postgresql://postgres:password@db:5432/workload_dev

# Redis
REDIS_URL=redis://redis:6379/0

# API Keys (replace with your own)
ANTHROPIC_API_KEY=sk-ant-xxx

# Application
DEBUG=true
LOG_LEVEL=debug
```

---

#### 3. README Local Development Section

**Location:** `README.md`

**Purpose:** Document development workflow

**Required Content:**

```markdown
## Local Development

### Prerequisites
- Docker and Docker Compose installed
- Git

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/zavestudios/workload-name.git
   cd workload-name
   ```

2. Copy environment template:
   ```bash
   cp .env.example .env
   ```

3. Start services:
   ```bash
   docker-compose up
   ```

4. Access application:
   - App: http://localhost:8000
   - Database: localhost:5432

### Common Tasks

**Run tests:**
```bash
docker-compose exec app pytest
```

**Access database:**
```bash
docker-compose exec db psql -U postgres -d workload_dev
```

**View logs:**
```bash
docker-compose logs -f app
```

**Rebuild after dependency changes:**
```bash
docker-compose up --build
```

**Stop services:**
```bash
docker-compose down
```
```

---

### Single-Command Startup

The local environment must start with a single command:

```bash
docker-compose up
```

**Prohibited:**
- Multi-step manual setup before first run
- Host-level dependency installation (except Docker)
- Platform-specific instructions (Mac-only, Linux-only, etc.)
- Manual database initialization (use entrypoint scripts or migrations)

**Allowed pre-requisites:**
- Copying `.env.example` to `.env`
- Adding sensitive credentials to `.env` (API keys, etc.)

---

### Development Parity

The docker-compose environment must mirror production where feasible:

| Aspect | Production | Local Development |
|--------|-----------|-------------------|
| Runtime | Container (Kubernetes) | Container (docker-compose) |
| Database | PostgreSQL (managed or pg service) | PostgreSQL (official image) |
| Build process | Dockerfile | Same Dockerfile |
| Environment variables | ConfigMap/Secret | .env file |
| Service discovery | Kubernetes DNS | docker-compose networking |

**Differences are acceptable when:**
- Production uses managed services (RDS, ElastiCache)
- Production has multi-replica setup
- Production uses service mesh (Istio)
- Production has different scale/performance requirements

**Core behavior must be identical:**
- Application code execution
- Database schema and migrations
- API contracts
- Business logic

---

## Prohibited Primary Approaches

The following are **not allowed as the primary development method**:

### Host-Level Virtual Environments

```bash
# Prohibited as primary method
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

**Why prohibited:**
- Platform-specific (Python version, OS dependencies)
- Diverges from production container runtime
- Creates "works on my machine" scenarios
- Violates `spec.runtime: container` contract

**Allowed as secondary method:**
- For IDE integration (e.g., PyCharm, VS Code)
- For running linters locally
- Documented as "Alternative: Host Development"

---

### Manual Dependency Installation

```bash
# Prohibited
brew install postgresql
npm install -g typescript
apt-get install redis
```

**Why prohibited:**
- Version drift across developers
- Platform-specific package managers
- Manual state on host machines
- No reproducibility guarantee

---

### Platform-Specific Instructions

```markdown
# Prohibited
## Mac Setup
brew install...

## Linux Setup
apt-get install...

## Windows Setup
Download installer from...
```

**Why prohibited:**
- Cognitive load multiplies across platforms
- Maintenance burden for multiple paths
- Docker eliminates platform differences

---

## Alternative Workflows (Optional)

Repositories may document alternative workflows as long as docker-compose remains the **reference implementation**.

**Acceptable alternatives:**

### Host-Based Development (IDE Integration)

```markdown
## Alternative: Host Development (for IDE integration)

If you prefer running the application directly on your host:

1. Install Python 3.12+
2. Create virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # or venv\Scripts\activate on Windows
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Start supporting services (database, etc.):
   ```bash
   docker-compose up db redis
   ```
5. Run application:
   ```bash
   export DATABASE_URL=postgresql://postgres:password@localhost:5432/workload_dev
   python -m workload
   ```

**Note:** This is for convenience only. docker-compose is the authoritative development environment.
```

---

## Generator Integration

When the Stage 1 generator is implemented (see GENERATOR_MODEL.md), it should generate docker-compose configuration from the workload contract.

**Example derivation:**

```yaml
# zave.yaml
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: example-app
spec:
  runtime: container
  persistence:
    engine: postgres
```

**Generated `docker-compose.yml` or `docker-compose.yaml`:**

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://postgres:password@db:5432/example_app_dev
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - .:/app

  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: example_app_dev
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

Generator derives:
- Service name from `metadata.name`
- Database service from `spec.persistence.engine`
- Volume definitions from persistence requirements

---

## Formation Phase: Manual Compliance

Until the Stage 1 generator exists, developers must manually create docker-compose configuration.

**Minimum Workload Scaffold requirement** (see Issue #1):

Every new contract-governed workload repository must include:
- `docker-compose.yml` or `docker-compose.yaml`
- `.env.example`
- README "Local Development" section

These must be created manually and follow the standards in this document.

---

## Testing Standard

All contract-governed workload repositories should support running tests via docker-compose.

**Recommended pattern:**

```yaml
# docker-compose.yml
services:
  app:
    # ... app service definition

  test:
    build: .
    environment:
      DATABASE_URL: postgresql://postgres:password@db:5432/workload_test
    depends_on:
      db:
        condition: service_healthy
    command: pytest
    profiles:
      - test

  db:
    # ... database definition
```

**Usage:**

```bash
# Run tests
docker-compose --profile test run --rm test

# Run with coverage
docker-compose --profile test run --rm test pytest --cov
```

**Alternative: exec into running container**

```bash
docker-compose up -d
docker-compose exec app pytest
```

---

## Debugging Support

docker-compose should support debugging workflows.

**Example: Python debugger**

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
      - "5678:5678"  # debugpy port
    environment:
      DEBUGGER_ENABLED: "true"
    volumes:
      - .:/app
```

Application code can conditionally enable debugger:

```python
import os
if os.getenv("DEBUGGER_ENABLED"):
    import debugpy
    debugpy.listen(("0.0.0.0", 5678))
```

Developers attach from IDE to `localhost:5678`.

---

## Observability in Development

docker-compose may optionally include observability services.

**Example:**

```yaml
services:
  app:
    # ... app definition

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    profiles:
      - observability

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    profiles:
      - observability
```

**Usage:**

```bash
# Start with observability
docker-compose --profile observability up
```

This is optional but encouraged for platform-services and complex workload repositories.

---

## Governance Enforcement

**Manual Conformance (Formation Phase):**

During Formation, compliance is verified through:
- Pull request reviews
- Checklist: "Does this workload repository have docker-compose?"
- Reference to this document in review comments

**Automated Validation (Target State):**

When contract validation is automated (see CONTRACT_VALIDATION.md), checks should include:

- `docker-compose.yml` or `docker-compose.yaml` exists in repository root
- `.env.example` exists
- README contains "Local Development" section
- docker-compose defines service matching `metadata.name`
- docker-compose includes database service if `spec.persistence` defined

---

## Success Criteria

Developer experience standard succeeds when:

- **Zero-step local setup:** New contributors run `git clone && docker-compose up`
- **Identical across repos:** Every contract-governed workload repo has same onboarding process
- **Production parity:** Local containers match production runtime
- **No platform-specific docs:** Works on Mac/Linux/Windows identically
- **Debuggable:** Developers can attach debuggers, view logs, inspect state

---

## Related Documentation

- OPERATING_MODEL.md — "Constrained path must always be faster"
- ARCHITECTURAL_DOCTRINE_TIER0.md — Variance reduction principle
- CONTRACT_SCHEMA.md — runtime profiles are contract-declared; local development remains containerized via docker-compose
- GENERATOR_MODEL.md — Stage 1 should generate docker-compose
- REPO_TAXONOMY.md — Defines which repos must follow this standard
- DEVELOPER_EXPERIENCE_JOURNEYS.md — Journey-based DX analysis and measurement
- FRICTION_FEEDBACK.md — Mechanism for capturing and prioritizing DX pain

---

## Companion Appendix

The journey-based companion for this standard lives in
`DEVELOPER_EXPERIENCE_JOURNEYS.md`.

Use that document for:

- end-to-end developer workflow mapping
- DX gap analysis
- journey-based measurement targets
- identifying where friction should be fed into `FRICTION_FEEDBACK.md`

---

## Strategic Role

This standard converts developer experience from:

**Architecture Variance**
(every repo has unique setup)

to

**Product Interface**
(predictable, bounded, fast)

Just as the platform contract eliminates infrastructure variance, this standard eliminates onboarding variance.

When every repository follows the same pattern, cognitive load collapses and productivity increases.

**User Journey Mapping Enables:**

- Systematic friction point identification
- Evidence-based priority decisions
- Measurable improvement over time
- Clear communication of platform value

---

## See Also

- `EXECUTION_ENVIRONMENTS.md`
- `DEVELOPER_EXPERIENCE_JOURNEYS.md`
- `FRICTION_FEEDBACK.md`
- `MEASUREMENT_MODEL.md`
