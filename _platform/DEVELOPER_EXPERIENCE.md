# ZaveStudios — Developer Experience Standard v0.1

This document defines the canonical developer experience for working with ZaveStudios platform workloads.

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

---

## Critical User Journeys

This section maps the end-to-end developer experience for key platform interactions.

Documenting these journeys helps:

- Identify friction points systematically
- Measure Time to First Deploy and other metrics
- Guide Formation phase priorities
- Validate whether "constrained path is fastest" holds true

---

### Journey 1: New Workload Bootstrap

**Goal**: Deploy a new contract-governed workload from zero to running

**Current State (Formation v0.1):**

1. **Create repository** (manual, GitHub UI or CLI)
   - Friction: No automated scaffolding
   - Time: ~2 minutes

2. **Write `zave.yaml` contract**
   - Friction: Must reference CONTRACT_SCHEMA.md for syntax
   - Time: ~5 minutes

3. **Create `Dockerfile`**
   - Friction: Must write from scratch or copy from existing repo
   - Time: ~10 minutes

4. **Add `docker-compose.yml`**
   - Friction: Must follow DEVELOPER_EXPERIENCE.md standard manually
   - Time: ~10 minutes

5. **Create `.env.example`**
   - Friction: Must document all required environment variables
   - Time: ~5 minutes

6. **Configure shared workflows** (`.github/workflows/ci.yml`)
   - Friction: Must reference platform-pipelines repository
   - Time: ~5 minutes

7. **Add README with Local Development section**
   - Friction: Must follow template from DEVELOPER_EXPERIENCE.md
   - Time: ~10 minutes

8. **Open GitOps registration PR**
   - Friction: Must manually add workload to gitops repository
   - Time: ~10 minutes

9. **Wait for GitOps reconciliation**
   - Time: ~5 minutes

**Total Time to First Deploy (Formation v0.1): ~60 minutes**

**Friction Points:**
- Manual file creation (no generator)
- Referencing multiple docs for syntax
- GitOps PR must be manual

---

**Target State (Post-Formation):**

1. **Run bootstrap command:**
   ```bash
   zave init http-service --name payments-api
   ```

2. **Result:**
   - Repository created with all required files
   - Contract generated with sensible defaults
   - Shared workflows bound automatically
   - GitOps registration PR opened automatically
   - First deployment triggered

**Total Time to First Deploy (Target): <5 minutes**

**Friction Points Eliminated:**
- All scaffolding automated
- GitOps registration automated
- Deployment immediate

---

### Journey 2: Local Development Start (New Contributor)

**Goal**: Clone a workload repository and run it locally

**Current State (Formation v0.1):**

1. **Clone repository:**
   ```bash
   git clone https://github.com/zavestudios/payments-api.git
   cd payments-api
   ```
   - Time: ~1 minute

2. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```
   - Time: <1 minute

3. **Add sensitive credentials** (API keys, etc.) to `.env`
   - Friction: Must obtain keys from team or secrets manager
   - Time: ~5 minutes (if keys are readily available)

4. **Start services:**
   ```bash
   docker-compose up
   ```
   - Time: ~2 minutes (first run, image pull)

5. **Access running application:**
   - Open browser to `http://localhost:8000`
   - Time: immediate

**Total Time to First Local Run: ~10 minutes**

**Friction Points:**
- Obtaining sensitive credentials (acceptable, not platform issue)
- Waiting for image pull (acceptable, one-time cost)

**Success Criteria:**
- ✅ Single command to start (`docker-compose up`)
- ✅ No platform-specific setup required
- ✅ No manual dependency installation on host

---

**Improvement Opportunities:**

- **Secret templating**: Platform could provide `.env.template` with placeholder values for common services
- **Docker image caching**: Pre-pull common base images to reduce first-run time
- **Health check feedback**: Show "Services ready" message when all health checks pass

---

### Journey 3: Deploy Code Changes to Production

**Goal**: Push code changes from local to production

**Current State (Formation v0.1):**

1. **Make code changes locally**
   - Developer writes code, tests locally via docker-compose
   - Time: variable (development work)

2. **Commit and push to branch:**
   ```bash
   git checkout -b feature/new-endpoint
   git add .
   git commit -m "Add new payment endpoint"
   git push origin feature/new-endpoint
   ```
   - Time: ~1 minute

3. **CI pipeline runs automatically:**
   - Contract validation
   - Build container image
   - Push to registry
   - Time: ~3-5 minutes

4. **Open pull request** (GitHub UI or `gh pr create`)
   - Code review by team
   - Time: variable (human review)

5. **Merge pull request to main**
   - Time: <1 minute

6. **GitOps reconciliation detects new image**
   - Flux applies updated manifests
   - Rolling deployment to production
   - Time: ~2-5 minutes

7. **Verify deployment** (check logs, health endpoints)
   - Time: ~2 minutes

**Total Commit-to-Production Time: ~10-15 minutes** (excluding code review wait)

**Friction Points:**
- None for happy path
- Rollback requires new commit (acceptable for GitOps model)

---

**Improvement Opportunities:**

- **Deployment notifications**: Slack/Discord notification when deployment completes
- **Automated smoke tests**: Run basic health checks post-deployment
- **Deployment dashboard**: Centralized view of all workload deployments

---

### Journey 4: Add Database to Existing Workload

**Goal**: Add PostgreSQL to a workload that initially had no persistence

**Current State (Formation v0.1):**

1. **Update `zave.yaml` contract:**
   ```yaml
   spec:
     persistence:
       engine: postgres
   ```
   - Time: <1 minute

2. **Update `docker-compose.yml` for local development:**
   ```yaml
   services:
     db:
       image: postgres:16
       environment:
         POSTGRES_PASSWORD: password
       # ... (full service definition)
   ```
   - Friction: Must manually write db service definition
   - Time: ~5 minutes

3. **Update `.env.example` with DATABASE_URL**
   - Time: ~1 minute

4. **Update application code** to use database
   - Time: variable (development work)

5. **Test locally:**
   ```bash
   docker-compose up
   ```
   - Time: ~2 minutes

6. **Commit and push changes**
   - CI pipeline validates updated contract
   - Time: ~1 minute

7. **GitOps reconciliation provisions database**
   - Platform provisions managed PostgreSQL (or pg platform-service)
   - Injects DATABASE_URL secret into workload
   - Time: ~5-10 minutes (managed service provisioning)

8. **Verify database connection in production**
   - Time: ~2 minutes

**Total Time to Add Database: ~20-30 minutes** (excluding app development)

**Friction Points:**
- Manual docker-compose update for local development
- Must wait for managed database provisioning

---

**Improvement Opportunities (Post-Formation):**

- **Generator updates docker-compose** when contract changes
- **Local database seeding**: Platform provides seed data scripts
- **Database migration automation**: Platform detects and runs migrations

---

### Journey 5: Debug Production Issue

**Goal**: Investigate and resolve production incident

**Current State (Formation v0.1):**

1. **Detect incident** (alerts, user reports)
   - Time: variable (detection lag)

2. **Check logs** (kubectl logs or centralized logging)
   - Friction: Must have kubectl access or access to logging system
   - Time: ~5 minutes

3. **Identify root cause**
   - Time: variable (investigation)

4. **Reproduce locally** if possible:
   ```bash
   docker-compose up
   # Reproduce issue
   ```
   - Time: variable

5. **Apply fix:**
   - Option A: Hotfix commit + push (GitOps flow)
   - Option B: Emergency kubectl patch (break-glass)
   - Time: ~5-10 minutes (hotfix) or <1 minute (kubectl)

6. **Verify fix in production**
   - Time: ~5 minutes

7. **Post-incident review** and backport if kubectl used
   - Time: variable

**Total Time to Recover (MTTR): ~15-30 minutes** (best case)

**Friction Points:**
- No kubectl access for developers (by design, but slows break-glass)
- Log access may require platform team
- Local reproduction may not match production state

---

**Improvement Opportunities:**

- **Centralized logging with developer access**: Developers can view logs without kubectl
- **Observability integration**: Traces, metrics, logs in single dashboard
- **Automated rollback**: If health checks fail, auto-rollback to previous version
- **Break-glass process documentation**: Clear runbook for emergency kubectl access

---

### Journey 6: Request New Platform Capability

**Goal**: Propose and adopt a new reusable platform capability

**Current State (Formation v0.1):**

1. **Developer identifies need** (e.g., "We need distributed tracing")
   - Time: immediate (idea)

2. **Create POC repository** to explore solution
   - Follow POC_GOVERNANCE.md System Design Interview template
   - Implement prototype
   - Document alternatives and trade-offs
   - Time: ~1-2 weeks (exploration)

3. **Submit POC for review** (PR or presentation to platform team + DX PM)
   - Platform team evaluates feasibility
   - DX PM evaluates tenant demand
   - Time: ~1 week (review cycle)

4. **POC approval decision:**
   - **Approved**: POC graduates to platform-service
   - **Deferred**: POC archived with rationale
   - **Iterate**: POC needs changes
   - Time: immediate (decision)

5. **If approved, platform team implements** as platform-service
   - Create platform-service repository
   - Implement capability module
   - Add to capability registry
   - Document usage in capability docs
   - Time: ~2-4 weeks (implementation)

6. **Capability available for tenant adoption:**
   ```yaml
   spec:
     capabilities:
       - name: tracing  # new capability
   ```
   - Tenants add to contract
   - GitOps applies capability module
   - Time: <5 minutes (adoption)

**Total Time from Idea to Available: ~4-6 weeks**

**Friction Points:**
- Relatively long cycle (acceptable for new capabilities)
- Requires platform team implementation (can't be pure self-service)

---

**Success Criteria:**
- Clear POC-to-graduation path exists
- Capability requests don't go into black hole
- DX PM tracks demand to prioritize high-value capabilities

---

## User Journey Measurement

The DX PM should track these journeys using metrics from MEASUREMENT_MODEL.md:

| Journey | Primary Metric | Target |
|---------|----------------|--------|
| New Workload Bootstrap | Time to First Deploy | <5 minutes (post-Formation) |
| Local Development Start | Time to First Local Run | <5 minutes (excluding credential acquisition) |
| Deploy Code Changes | Commit-to-Production Time | <15 minutes |
| Add Database | Time to Add Persistence | <10 minutes (post-Formation, with generator) |
| Debug Production Issue | Mean Time to Recovery (MTTR) | <1 hour |
| Request New Capability | Idea-to-Available Time | <6 weeks |

**Measurement Method:**

- Survey new workload creators: "How long did bootstrap take?"
- Track GitOps timestamps: commit → deployment
- Track POC lifecycle: creation → graduation
- Collect friction point reports: "Where did you get stuck?"

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
