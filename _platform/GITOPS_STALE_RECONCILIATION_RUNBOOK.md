# GitOps Stale Reconciliation Runbook

## Purpose

This runbook covers the failure class where Git state and controller state have
partially advanced, but the expected child controller action does not converge
predictably.

Use this when the first symptom is:

- the corrective commit is merged
- the owning `Kustomization` is still in progress or not ready
- the child `HelmRelease` or controller still reports an earlier failure
- the platform does not self-heal within the expected reconcile window

---

## Symptom

An operator makes a corrective Git change, but the blocked reconciliation unit
does not respond predictably.

Typical examples:

- upstream `Kustomization`s reconcile the new source revision, but the blocked
  unit still appears stuck
- `HelmRelease` status still shows the earlier failure after corrected inputs
  are known to be live
- the child controller does not create a fresh successful action without manual
  intervention

---

## Required Inputs

Before starting, identify:

- `<gitops-repo>`: owning GitOps repository
- `<owning-kustomization>`: top-level Flux `Kustomization` blocked on the
  change
- `<helmrelease-namespace>` and `<helmrelease-name>` if Helm is involved
- `<expected-git-revision>`: commit SHA or source revision containing the fix
- `<values-source-object>` if the release uses generated ConfigMaps or Secrets

If ownership is unclear, stop and resolve it first using `REPO_TAXONOMY.md`,
`OPERATING_MODEL.md`, and `GITOPS_MODEL.md`.

---

## Stale Threshold

Treat the reconciliation as **stale**, not "still working", when all of the
following are true:

1. corrected Git state is merged
2. the owning source and `Kustomization` have observed that state
3. corrected generated inputs are live in the cluster
4. one full reconcile interval for the blocked child controller has elapsed
5. the child controller still reports the earlier failure or has not produced a
   fresh attempt

For `HelmRelease` objects, use the release's configured `spec.interval` as the
default threshold unless there is stronger controller-specific evidence.

---

## Boundary Ladder

### 1. Declared Truth

Question:

- does Git contain the corrective change you expect?

Checks:

```bash
git -C /path/to/<gitops-repo> log --oneline -n 20
git -C /path/to/<gitops-repo> show <expected-git-revision> -- <relevant-path>
```

Interpretation:

- if the fix is not in Git, stop
- if the fix is in Git, continue

---

### 2. Rendered Truth

Question:

- does the live rendered input actually reflect the fix?

Checks:

```bash
kubectl get helmrelease -n <helmrelease-namespace> <helmrelease-name> -o yaml
kubectl get configmap -n <helmrelease-namespace> <values-source-object> -o yaml
kubectl get secret -n <helmrelease-namespace> <values-source-object> -o yaml
```

If a `valuesFrom` source is used, extract the actual payload:

```bash
kubectl get configmap -n <helmrelease-namespace> <values-source-object> \
  -o jsonpath='{.data.values\.yaml}'
```

Interpretation:

- if the live values source still contains the old bad input, the fix has not
  reached rendered truth
- if the live values source is corrected, continue

---

### 3. Controller Truth

Question:

- did the owning controller observe the corrected object, and did the child
  controller create a fresh attempt?

Checks:

```bash
kubectl describe kustomization -n flux-system <owning-kustomization>
kubectl describe helmrelease -n <helmrelease-namespace> <helmrelease-name>
```

Focus on:

- `metadata.generation`
- `status.observedGeneration`
- `status.lastAttemptedGeneration`
- latest failure message
- attempted release action
- attempted revision

Interpretation:

- if `metadata.generation` is ahead of `status.observedGeneration`, the child
  controller has not consumed the latest object yet
- if the child controller has consumed the latest object but still reports the
  earlier failure after corrected inputs are live, treat it as stale

---

### 4. Live Runtime Truth

Question:

- did the controller actually create a fresh action?

Checks:

```bash
helm history <helmrelease-name> -n <helmrelease-namespace>
kubectl get events -n <helmrelease-namespace> --sort-by=.lastTimestamp
```

Interpretation:

- if no new action is recorded after the corrected input is live, the
  reconciliation is stalled
- if a new action is recorded and still fails, the fix is incomplete rather
  than stale

---

## Decision Points

### Corrected Input Is Not Live

Outcome:

- upstream apply/render path is still wrong

Immediate action:

```bash
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization <owning-kustomization> -n flux-system --with-source
```

Owner:

- owning GitOps path and Kustomization apply surface

### Corrected Input Is Live But Child Controller Has Not Consumed Latest Generation

Outcome:

- child controller lag or blocked handoff

Immediate action:

```bash
flux reconcile kustomization <owning-kustomization> -n flux-system --with-source
```

Owner:

- controller handoff between Kustomization and child controller

### Corrected Input Is Live, Generation Is Current, But No Fresh Successful Attempt Appears

Outcome:

- stale reconciliation

Immediate action for Helm:

```bash
flux reconcile helmrelease <helmrelease-name> -n <helmrelease-namespace> --force
```

Interpretation:

- if the forced reconcile succeeds, capture this as a stale-reconciliation
  recovery
- if the forced reconcile creates a new failure, follow the new failure instead

Owner:

- child controller behavior and platform control-plane design

---

## Recovery Actions

Prefer declarative recovery first.

### Declarative

- merge the corrective Git change
- reconcile source and owning `Kustomization`
- verify corrected generated inputs are live

### Break-Glass

Use only once corrected inputs are already proven live and the child
controller remains stale beyond the threshold.

Example:

```bash
flux reconcile helmrelease <helmrelease-name> -n <helmrelease-namespace> --force
```

Any forced reconcile used to recover a stale control-plane state must be
captured in the issue, incident note, or runbook update that follows.

---

## Escalation And Ownership

Durable fix ownership depends on the failed boundary:

- corrected input never reached the cluster: owning GitOps path
- corrected input is live but child controller did not re-attempt: controller
  behavior and control-plane design
- forced reconcile succeeds: treat as a stale-reconciliation pattern and reduce
  recurrence structurally

If this failure class repeats:

- update `gitops` with the environment-specific evidence and commands
- update `platform-docs` if the pattern is generic across workloads or control
  planes
- audit `wait: true`, dependency chains, and top-level reconciliation blast
  radius

---

## Minimal Command Bundle

```bash
kubectl describe kustomization -n flux-system <owning-kustomization>
kubectl describe helmrelease -n <helmrelease-namespace> <helmrelease-name>
kubectl get configmap -n <helmrelease-namespace> <values-source-object> -o yaml
helm history <helmrelease-name> -n <helmrelease-namespace>
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization <owning-kustomization> -n flux-system --with-source
flux reconcile helmrelease <helmrelease-name> -n <helmrelease-namespace> --force
```

Use this bundle to determine whether the fix is missing, unconsumed, or stale
before broadening scope.
