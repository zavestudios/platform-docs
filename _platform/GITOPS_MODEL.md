# ZaveStudios — GitOps Model v0.1

How desired state is represented, reconciled, and divided between the platform
and workload GitOps planes, and how that split maps to FluxCD and ArgoCD.

---

## GitOps Plane Authority

Per [`CONTROL_PLANE_MODEL.md`](CONTROL_PLANE_MODEL.md), the GitOps Plane is the **State Authority** layer.

Git is the operational control plane. All runtime state must be representable in Git.

---

## Dual GitOps Implementation

ZaveStudios uses **two GitOps tools** with distinct responsibilities:

### FluxCD — Platform and Infrastructure Authority

**Scope:**
- Platform resources (`platform/`)
- Platform component installation and cluster add-ons
- Cluster-level configuration
- Namespaces, policies, networking
- Infrastructure components

**Rationale:**
- FluxCD is designed for cluster operators
- Manages foundational cluster state
- Runs with cluster-admin privileges
- No user-facing UI required

**Repository:** `gitops` (entire repository is Flux source)

---

### ArgoCD — Tenant Workload Authority

**Scope:**
- Tenant workload deployments (`tenants/`)
- Application-level resources (Deployment, Service, Ingress)
- Tenant-scoped operations

**Rationale:**
- Provides UI for tenants to view their resources
- Enables tenant-controlled operations (sync, rollback, diff)
- Self-service deployment visibility
- Separation of concerns: tenants see their workloads, not platform internals

**Repository:** `gitops/tenants/` (subdirectories registered as ArgoCD Applications)

---

## Authority Boundary

```
FluxCD manages:           ArgoCD manages:
├── Namespaces            ├── Deployments
├── NetworkPolicies       ├── Services
├── ResourceQuotas        ├── Ingresses
├── Kyverno policies      ├── ConfigMaps (tenant)
├── Big Bang              ├── Secrets (tenant, sealed)
└── ArgoCD itself         └── HorizontalPodAutoscalers
```

FluxCD installs and manages ArgoCD as a platform capability.

ArgoCD does not manage itself or platform resources.

---

## ArgoCD Application Pattern

Application resources are centralized in `gitops/platform/argocd/applications/`.

This keeps tenant registrations visible to platform operators and separates lifecycle management from workload manifests.

### Canonical Application Structure

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {workload-name}
  namespace: argocd
  labels:
    zave.io/workload: {workload-name}
    zave.io/tenant: "true"
spec:
  project: default
  source:
    repoURL: https://github.com/zavestudios/gitops
    targetRevision: main
    path: tenants/{workload-name}
  destination:
    server: https://kubernetes.default.svc
    namespace: {workload-name}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Field Definitions

- **`metadata.namespace`**: Always `argocd` (Application resources live in ArgoCD namespace)
- **`spec.project`**: `default` (Formation phase uses default AppProject; per-tenant projects deferred)
- **`spec.source.path`**: Maps to `gitops/tenants/{workload-name}/`
- **`spec.destination.namespace`**: Tenant workload namespace (created automatically if missing)
- **`syncPolicy.automated.prune`**: `true` - Auto-delete resources removed from Git
- **`syncPolicy.automated.selfHeal`**: `true` - Revert manual kubectl changes to match Git
- **`syncOptions.CreateNamespace`**: `true` - ArgoCD creates namespace if missing

### Sync Policy Rationale

**Automated sync with selfHeal enforces Git-first workflow:**

- Git changes auto-deploy to cluster
- Manual kubectl edits are reverted
- Cluster state always matches Git
- Tenants retain UI control (manual sync, rollback, diff)

**Escape hatch for emergencies:**
```bash
argocd app set {workload-name} --self-heal false
# Perform manual kubectl debugging
# Fix issue in Git
argocd app set {workload-name} --self-heal true
```

This aligns with [`CONTROL_PLANE_MODEL.md`](CONTROL_PLANE_MODEL.md): "kubectl is allowed only for emergency mitigation; all changes must be backported to Git immediately."

---

## Tenant Registration Flow

Tenant workload deployment follows this sequence:

1. **Contract validation** - `zave.yaml` passes schema and compatibility validation
2. **CI builds image** - Shared workflows in `platform-pipelines` build, scan, sign, push to GHCR
3. **Manifests created** - Kubernetes resources placed in `gitops/tenants/{workload}/`
4. **Application resource created** - ArgoCD Application placed in `gitops/platform/argocd/applications/`
5. **Git merge** - Changes merged to gitops repository main branch
6. **ArgoCD syncs** - ArgoCD detects Application resource and syncs manifests to cluster
7. **Tenant monitors** - Tenant views deployment status via ArgoCD UI

Secret and dependency prerequisites remain part of the same onboarding flow:

- required Vault paths must exist
- External Secrets Operator must be authorized to read those tenant paths
- shared platform dependencies must already exist when the tenant contract depends on them

GitOps registration alone does not make a tenant deployable.

### Formation Phase (v0.1)

During Formation, steps 3-4 are **manual**:

- Platform operator creates Kubernetes manifests
- Platform operator creates ArgoCD Application resource
- Both are committed via PR to gitops repository

**Manual Application creation:**
```bash
kubectl apply -f gitops/platform/argocd/applications/{workload}.yaml
```

Or committed to Git and synced by FluxCD (if platform layer includes argocd/applications/).

### Target State

Once generators stabilize:

- Step 3 (manifests) generated automatically from contract
- Step 4 (Application) generated automatically or via ApplicationSet
- No manual manifest authoring required

---

## Formation Phase Exceptions

During Formation (v0.1), the following manual steps are acceptable:

- **Manual manifest creation** - Kubernetes resources hand-written and placed in `gitops/tenants/{workload}/`
- **Manual Application creation** - ArgoCD Application resources created by platform operators
- **Manual image tag updates** - Deployment manifest updated with specific image SHA after CI build
- **kubectl for Application bootstrap** - `kubectl apply -f` to create initial Application resource

Once generators stabilize:

- Manifests generated from contract
- Applications generated from contract or via ApplicationSet
- Image tags injected automatically or managed via promotion workflow
- kubectl only for break-glass emergencies

---

## Formation Observability Capability Materialization

During Formation, observability capability declarations are not self-executing.
They become real only when GitOps includes the workload and platform resources
needed for collection.

### Metrics Capability

For a workload declaring:

```yaml
spec:
  capabilities:
    - name: metrics
```

the Formation GitOps standard is:

1. the tenant workload exposes a Kubernetes `Service` port named `metrics`
2. the scrape path is `/metrics` unless the platform explicitly documents an
   exception
3. `gitops/tenants/{workload}/` contains the monitoring object required by the
   active platform stack
4. for the current Prometheus Operator implementation, that object is a
   `ServiceMonitor`

The `ServiceMonitor` must remain platform-shaped:

- it targets the tenant namespace intentionally
- it selects the workload `Service` by stable labels
- it references the named `metrics` port rather than a raw port number

Workload capability declaration without this GitOps materialization is
conformance debt, not successful capability adoption.

### Tracing Capability

For a workload declaring:

```yaml
spec:
  capabilities:
    - name: tracing
```

the Formation GitOps standard is:

1. the workload emits OTLP using platform-provided configuration
2. GitOps publishes the platform-owned in-cluster OTLP receiver path
3. the receiver is owned by the observability stack and forwards traces to
   Tempo
4. tenant manifests do not define direct Tempo ingestion, bespoke collectors,
   or workload-specific tracing backends

The canonical Formation data path is:

```text
workload -> Alloy receiver -> Tempo
```

Required materialization responsibilities:

- platform GitOps defines the receiver service and routing path
- tenant GitOps injects the receiver endpoint and required OTLP environment
  variables into workloads that declare `tracing`
- validation and generators should eventually enforce this automatically

Until the receiver path is published and consumable through GitOps-managed
configuration, `tracing` remains declared intent rather than completed platform
behavior.

### Operational Validation

Capability materialization is not complete until the platform can verify it at
runtime.

Examples:

- `metrics`: Prometheus shows the workload target as discovered and `up`
- `tracing`: the collector receives workload traces and forwards them to Tempo

This follows [`DIAGNOSTIC_MODEL.md`](DIAGNOSTIC_MODEL.md): Git truth, rendered truth, controller
truth, and runtime truth must align before a capability is considered
operational.

---

## Reconciliation Layering

FluxCD reconciliation has three distinct ordering mechanisms. Using the wrong one is a common source of stalls.

### Kustomization `dependsOn`

Controls inter-Kustomization ordering. Flux will not begin reconciling Kustomization B until Kustomization A has **applied** its resources (not necessarily until they are healthy).

Use this for tier ordering — runtime before services, services before tenants.

```yaml
spec:
  dependsOn:
    - name: on-prem-platform-runtime
```

### HelmRelease `dependsOn`

Controls intra-tier ordering. Use when one HelmRelease within a tier must be healthy before another starts — for example, an operator before its CRD-dependent workload.

```yaml
spec:
  dependsOn:
    - name: cert-manager
      namespace: platform
```

### `wait: true` on a Kustomization

Changes what "reconciled" means for a Kustomization from "resources applied" to "resources healthy." Flux will not mark the Kustomization ready until all applied resources report a healthy status.

**This is a stall point.** If any resource in the Kustomization is unhealthy — including a HelmRelease that is cycling through upgrade retries — Flux marks the Kustomization as not ready and stops processing it. Subsequent git commits that fix the underlying issue will not be picked up until the Kustomization unstalls.

**Decision rule:**

- If nothing `dependsOn` this Kustomization, do not set `wait: true`. There is no downstream consumer waiting on the health signal, and the only effect is blocking self-reconciliation.
- If a downstream Kustomization does `dependsOn` this one, evaluate whether health-gating is actually required. `dependsOn` without `wait: true` gives apply-ordering; `wait: true` adds health-gating. Most tier dependencies need ordering, not health-gating.

**Operational rule:**

When a Kustomization stalls and pushing new commits has no effect, check whether `wait: true` is set and a resource in that Kustomization is unhealthy. The fix is either to resolve the unhealthy resource or remove `wait: true` if the health gate is not load-bearing.

Do not iterate on symptoms by pushing more commits before understanding why Flux is not picking them up.

---

## FluxCD Bootstrap

FluxCD is installed via `gitops/bootstrap/` and pointed at `clusters/on-prem/`.

**Requires cluster access:**
```bash
flux bootstrap github \
  --owner=zavestudios \
  --repository=gitops \
  --branch=main \
  --path=clusters/on-prem
```

---

## ArgoCD Access

**Namespace:** `argocd` (managed by Big Bang)

**Access:**
- UI: `https://argocd.zavestudios.com` (configured via BigBang)
- CLI: `argocd login <server>` (requires credentials)

**Tenant RBAC:** (TBD - requires AppProject and RBAC policy definition)

---

## Strategic Role

The GitOps Model converts deployment from imperative actions into declarative state management.

FluxCD ensures platform stability.
ArgoCD enables tenant autonomy.

The boundary between them must remain clear and enforceable.

