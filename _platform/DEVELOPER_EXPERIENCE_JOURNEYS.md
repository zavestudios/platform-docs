# ZaveStudios — Developer Experience Journeys v0.1

This document captures the end-to-end user journeys that make the developer
experience standard measurable.

## Chapter Guide

**Purpose**

Provide journey-based scenarios for evaluating whether the platform's developer
experience is actually improving.

**Read this when**

- running a DX gap analysis
- mapping friction to specific workflow stages
- selecting journey-based targets and measurements

**Read next**

- `DEVELOPER_EXPERIENCE.md` for the normative standard
- `FRICTION_FEEDBACK.md` for how journey pain should be captured
- `MEASUREMENT_MODEL.md` for metric framing

---

## Role In The Handbook

`DEVELOPER_EXPERIENCE.md` defines the standard.

This companion document answers a different question:

- what does the standard feel like across real developer journeys?

That separation keeps the standard concise while preserving a reusable gap
analysis surface.

---

## Critical User Journeys

This section maps the end-to-end developer experience for key platform
interactions.

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

- **Secret templating**: Platform could provide `.env.template` with placeholder
  values for common services
- **Docker image caching**: Pre-pull common base images to reduce first-run time
- **Health check feedback**: Show "Services ready" message when all health
  checks pass

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

**Total Commit-to-Production Time: ~10-15 minutes** (excluding code review
wait)

**Friction Points:**
- None for happy path
- Rollback requires new commit (acceptable for GitOps model)

---

**Improvement Opportunities:**

- **Deployment notifications**: Slack/Discord notification when deployment
  completes
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

- **Centralized logging with developer access**: Developers can view logs
  without kubectl
- **Observability integration**: Traces, metrics, logs in single dashboard
- **Automated rollback**: If health checks fail, auto-rollback to previous
  version
- **Break-glass process documentation**: Clear runbook for emergency kubectl
  access

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

## See Also

- `DEVELOPER_EXPERIENCE.md`
- `FRICTION_FEEDBACK.md`
- `MEASUREMENT_MODEL.md`
- `POC_GOVERNANCE.md`
