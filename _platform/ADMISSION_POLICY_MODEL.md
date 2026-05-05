# ZaveStudios — Admission Policy Model v0.1

This document defines how Kyverno admission policies are authored, organized, and tested on the ZaveStudios platform.

## Chapter Guide

**Purpose**

Establish the two-layer pattern for admission control so that platform defaults are set at admission without requiring charts or workload authors to know about them.

**Read this when**

- authoring a new Kyverno policy
- a workload is blocked by an admission policy at deploy time
- deciding whether a requirement belongs in a policy or in a chart value
- writing Kyverno tests for the CI pipeline

**Read next**

- `ENFORCEMENT_MATRIX.md` for where policies sit in the enforcement stack
- `GITOPS_MODEL.md` for how policies are reconciled to the cluster

---

## Two-Layer Pattern

Kyverno policies operate in two distinct modes. Using the correct mode for each requirement prevents unnecessary coupling between platform policy and workload chart schemas.

### Mutate — Platform Defaults at Admission

A mutating policy intercepts a resource at admission and adds or modifies fields before the resource is persisted. The workload chart does not need to know the fields exist.

Use mutate when a requirement is a **platform default**: a value that should always be present but that workloads should not need to declare. Labels, annotations, and security context baselines are the canonical examples.

### Validate — Invariants at Admission

A validating policy rejects resources that do not meet a condition. The workload must satisfy the condition or be blocked.

Use validate when a requirement is a **hard invariant**: a condition that must never be absent and that workloads are expected to declare. Restricting image registries, requiring non-root UIDs, or preventing privilege escalation are canonical examples.

**Decision rule:**

If a field should be present on every pod regardless of what the chart author wrote, use mutate. If a field must be set to a specific value by the workload author and the absence or wrong value is a security failure, use validate.

The chart schema rejection problem — where a chart's `values.schema.json` rejects injected values like `podLabels` as additional properties — does not occur with mutating policies because the mutation happens at the Kubernetes API server level, not at Helm template rendering.

---

## Add-if-Absent Idiom

Mutating policies that inject platform defaults must not overwrite values that the chart or workload already set. Use the `+()` syntax in `patchStrategicMerge` to add a field only if it is absent:

```yaml
mutate:
  patchStrategicMerge:
    metadata:
      labels:
        +(app.kubernetes.io/name): "{{ request.object.metadata.labels.release || 'unknown' }}"
        +(app.kubernetes.io/version): "{{ request.object.metadata.labels.version || 'unset' }}"
```

The `+()` prefix means: apply this patch only if the key does not already exist. If the chart sets `app.kubernetes.io/name`, the policy leaves it alone.

---

## Autogen Behavior

Kyverno automatically extends Pod-level rules to Deployment, StatefulSet, DaemonSet, Job, and CronJob pod templates via generated `autogen-*` rules.

Write policies targeting `Pod`. Kyverno generates the controller variants. Do not manually duplicate rules for each controller kind.

The autogen rules appear in `kubectl describe clusterpolicy` output and are the rules that fire on Deployment admission. If a Deployment is blocked by an autogen rule, the fix is the same as for the Pod-level rule — the autogen rule is a mechanical projection of it.

---

## Repo Location and Naming

All platform Kyverno policies live in `platform/policies/kyverno/` in the gitops repository. One file per policy.

Naming convention:

- `inject-*` — mutating policies that add platform defaults
- `require-*` — validating policies that enforce required fields
- `restrict-*` — validating policies that block disallowed values

The `kustomization.yaml` in that directory is the Flux reconciliation entry point. Add new policy files there.

---

## CI Fidelity

`kyverno apply` in the CI pipeline processes mutating policies before validating policies, in the same order that the Kubernetes admission webhook chain runs them. This means:

1. A mutating policy injects a label
2. The validating policy that requires that label sees the mutated resource, not the original

CI results are therefore faithful to cluster admission behavior. A workload that passes `kyverno apply` in CI will pass admission on the cluster, and vice versa, provided the policy set in CI matches the policy set on the cluster.

This is why shifting Kyverno checks left into the CI pipeline (platform-pipelines#60) covers both policy types and eliminates the deploy-time discovery loop.

---

## Authoring Checklist

When writing a new policy:

1. Decide mutate or validate using the decision rule above.
2. Use `+(key)` for any mutating patch that should not overwrite existing values.
3. Target `Pod` and let autogen handle controllers.
4. Name the file `inject-*`, `require-*`, or `restrict-*` per the naming convention.
5. Add the file to `platform/policies/kyverno/kustomization.yaml`.
6. Write a `kyverno test` case that covers at least one passing and one failing resource.

---

## Related Documentation

- `ENFORCEMENT_MATRIX.md` — maps platform rules to enforcement points including Kyverno policies
- `GITOPS_MODEL.md` — describes how platform policies are reconciled to the cluster
- `DIAGNOSTIC_MODEL.md` — gap-analysis lens for rendered vs live state