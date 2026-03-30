# GitOps-Managed Service Missing From Cluster

## Purpose

This runbook covers the failure class where a GitOps-managed platform service or
workload appears to be absent from the cluster.

Examples:

- no namespace
- no HelmRelease
- no Deployment or StatefulSet
- no pods
- no controller-owned child resources

Use this when the first symptom is "it is not there at all" rather than "it is
there but unhealthy."

---

## Symptom

An operator expects a GitOps-managed service to exist, but one or more of the
expected Kubernetes objects are missing from the cluster.

Typical examples:

- `kubectl get pods -n <service-namespace>` returns no resources
- `kubectl get helmreleases -A` does not show the expected release
- `kubectl get kustomizations -n flux-system` shows the owning Kustomization as
  missing, stale, or not ready

---

## Required Inputs

Before starting, identify:

- `<gitops-repo>`: owning GitOps repository
- `<gitops-path>`: path in Git that should declare the resource
- `<cluster-entrypoint-path>`: cluster or environment entrypoint that should
  include the owning Kustomization or generated resource path
- `<service-namespace>`: namespace where the service should exist
- `<owning-kustomization>`: Flux Kustomization expected to apply the path
- `<service-helmrelease>`: HelmRelease name if Helm/Big Bang is involved

If these are not obvious, stop and determine ownership first using
`REPO_TAXONOMY.md`, `OPERATING_MODEL.md`, and `GITOPS_MODEL.md`.

Run each check from whatever execution environment has the required access and
tools. The runbook does not require a single environment for all steps.

---

## Boundary Ladder

### 1. Declared Truth

Question:

- does Git still declare that this service should exist?

Checks:

```bash
git -C /path/to/<gitops-repo> status --short
git -C /path/to/<gitops-repo> log --oneline -n 20 -- <gitops-path>
sed -n '1,220p' /path/to/<gitops-repo>/<gitops-path>
```

Interpretation:

- if the service was removed or disabled in Git, this is not a controller
  incident
- if the service is still declared, continue

---

### 2. Rendered Truth

Question:

- does the current Git state render the expected objects?

Checks:

```bash
kubectl kustomize /path/to/<gitops-repo>/<gitops-path>
kubectl kustomize /path/to/<gitops-repo>/<cluster-entrypoint-path>
```

If Helm or generated values are involved, inspect whether:

- the relevant `Kustomization` is present in the cluster entrypoint
- generated ConfigMaps or Secrets are referenced correctly
- rendered output still contains the expected namespace, Kustomization,
  HelmRelease, or prerequisites

Interpretation:

- if render output is wrong, the durable fix belongs in Git
- if render output is correct, continue

---

### 3. Controller Truth

Question:

- did Flux and Helm observe and accept the declared state?

Checks:

```bash
flux get sources git -n flux-system
flux get kustomizations -n flux-system

kubectl describe kustomization -n flux-system <owning-kustomization>
kubectl get helmreleases -A
kubectl describe helmrelease -n <controller-namespace> <service-helmrelease>
```

Focus on:

- `Ready` condition
- last applied revision
- dependency failures
- missing source revisions
- Helm template or upgrade failures
- stuck reconciliation timestamps

Interpretation:

- if Flux has not observed the latest revision, reconcile source and
  Kustomization
- if Flux is ready but the child HelmRelease is missing, inspect rendered parent
  chart behavior
- if HelmRelease exists but is not ready, follow the Helm failure rather than
  runtime debugging

---

### 4. Live Runtime Truth

Question:

- what actually exists in the cluster right now?

Checks:

```bash
kubectl get ns <service-namespace>
kubectl get all -n <service-namespace>
kubectl get secret -n <service-namespace>
kubectl get externalsecret -n <service-namespace>
kubectl get events -n <service-namespace> --sort-by=.lastTimestamp
```

Interpretation:

- if namespace and prerequisites do not exist, the failure is usually above the
  workload layer
- if prerequisites exist but workloads do not, focus on HelmRelease or
  controller-generated child objects
- if workloads exist but no pods are running, this is no longer a "missing from
  cluster" incident; switch to a runtime-health runbook

---

### 5. User-Visible Behavior

Question:

- what external symptom matches the missing state?

Checks:

- failing DNS name
- 404 or 503 at expected endpoint
- auth redirect loop
- missing UI or API surface

Interpretation:

- confirm the symptom matches the control-plane findings
- avoid treating user-visible failure as the primary diagnostic source

---

## Decision Points

### Git Does Not Declare The Service

Outcome:

- expected absence
- review recent PRs, toggles, disable flags, or lifecycle changes

Owner:

- repository that changed declared state

### Git Declares It But Render Output Is Wrong

Outcome:

- template, overlay, or generation defect

Owner:

- repository that renders the manifest

### Render Output Is Correct But Flux Is Stale

Outcome:

- source or Kustomization reconciliation issue

Immediate action:

```bash
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization <owning-kustomization> -n flux-system --with-source
```

Owner:

- GitOps controller path and owning infrastructure repo

### Flux Is Ready But HelmRelease Is Missing

Outcome:

- parent chart or higher-level generator did not emit the child resource

Owner:

- parent chart values or rendering path in Git

### HelmRelease Exists But Is Not Ready

Outcome:

- Helm/controller failure, not absence of declaration

Immediate action:

```bash
kubectl describe helmrelease -n <controller-namespace> <service-helmrelease>
kubectl get events -n <controller-namespace> --sort-by=.lastTimestamp
kubectl logs -n flux-system deploy/helm-controller --tail=200
```

Owner:

- owning GitOps repo plus underlying chart or dependency source

---

## Recovery Actions

Prefer declarative recovery first.

### Declarative

- fix Git if declared or rendered truth is wrong
- merge to main through normal PR workflow
- reconcile Flux source and owning Kustomization

### Break-Glass

Use only if service restoration is urgent and GitOps reconciliation cannot wait.

Examples:

- manual `flux reconcile`
- manual `kubectl apply -k` for initial GitOps repair
- temporary manual prerequisite creation to restore controller convergence

Any break-glass cluster change must be backported to Git immediately.

---

## Escalation And Ownership

Durable fix ownership depends on the failed boundary:

- declared truth wrong: owning Git repository
- rendered truth wrong: template or overlay owner
- controller truth wrong: Flux, Helm, or parent chart owner
- runtime-only failure: service owner or dependency owner

If the same failure class repeats, promote the incident into:

- a repo-local operational note if environment-specific
- a platform-docs runbook update if the pattern is generic

---

## Minimal Command Bundle

```bash
flux get sources git -n flux-system
flux get kustomizations -n flux-system
kubectl get helmreleases -A
kubectl describe kustomization -n flux-system <owning-kustomization>
kubectl describe helmrelease -n <controller-namespace> <service-helmrelease>
kubectl get ns <service-namespace>
kubectl get all -n <service-namespace>
kubectl get events -n <service-namespace> --sort-by=.lastTimestamp
```

Use this bundle to determine which boundary is actually broken before changing
Git or making manual cluster edits.
