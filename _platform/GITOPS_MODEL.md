# ZaveStudios — GitOps Model v0.1

This document defines how GitOps reconciliation operates within the ZaveStudios platform.

It clarifies the split between FluxCD and ArgoCD and their respective responsibilities.

---

## GitOps Plane Authority

Per `CONTROL_PLANE_MODEL.md`, the GitOps Plane is the **State Authority** layer.

Git is the operational control plane. All runtime state must be representable in Git.

---

## Dual GitOps Implementation

ZaveStudios uses **two GitOps tools** with distinct responsibilities:

### FluxCD — Platform and Infrastructure Authority

**Scope:**
- Platform resources (`platform/`)
- Big Bang installation (`bigbang/`)
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

This aligns with `CONTROL_PLANE_MODEL.md`: "kubectl is allowed only for emergency mitigation; all changes must be backported to Git immediately."

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

## FluxCD Bootstrap

FluxCD is installed via `gitops/bootstrap/` and pointed at `clusters/sandbox/`.

**Run manually by human:**
```bash
flux bootstrap github \
  --owner=zavestudios \
  --repository=gitops \
  --branch=main \
  --path=clusters/sandbox
```

---

## ArgoCD Access

**Namespace:** `argocd` (managed by Big Bang)

**Access:**
- UI: `https://argocd-sandbox.zavestudios.com` (TBD - requires ingress configuration)
- CLI: `argocd login <server>` (requires credentials)

**Tenant RBAC:** (TBD - requires AppProject and RBAC policy definition)

---

## Strategic Role

The GitOps Model converts deployment from imperative actions into declarative state management.

FluxCD ensures platform stability.
ArgoCD enables tenant autonomy.

The boundary between them must remain clear and enforceable.

---

## Related Documentation

- `CONTROL_PLANE_MODEL.md` — Defines GitOps as State Authority layer
- `LIFECYCLE_MODEL.md` — Describes workload state transitions
- `OPERATING_MODEL.md` — Formation phase expectations
- `REPO_TAXONOMY.md` — Classifies gitops as infrastructure repository
