# ZaveStudios — Control Plane Model v0.1.5

This defines where authority resides across the system.

---

## Control Plane Layers

### 1. Contract Plane — Intent Authority

The workload contract defines:

- runtime classification
- delivery strategy selection
- capability enablement
- persistence requirements
- exposure rules

Nothing outside the contract should influence workload structure.

Scope note:

- The workload contract is the intent surface for `tenant` and `portfolio` workloads.
- Shared `platform-service` runtimes are platform-owned capabilities, not tenant workloads.
- Those services must still be represented in GitOps, but they are not required to use the tenant workload contract as their authoring interface.

---

### 2. CI Plane — Build Proposal Authority

CI pipelines are responsible only for:

- validating contract compliance
- building artifacts
- proposing environment changes
- emitting deployable versions

CI must not:

- mutate cluster state directly
- define infrastructure topology
- bypass GitOps

CI proposes. It does not enact.

---

### 3. GitOps Plane — State Authority

GitOps owns:

- workload lifecycle registration
- environment promotion state
- service routing configuration
- capability activation
- cluster reconciliation

For shared runtime platform services, GitOps remains the authoritative lifecycle surface even when the service is not authored as a tenant workload contract.

Git is the operational control plane.
All runtime state must be representable in Git.

# Exception Authority Rules

Explicit exceptions:

- Bootstrap exception: `kubectl` is allowed only to install/repair Flux and apply the initial GitOps entrypoint.
- Break-glass exception: `kubectl` is allowed only for emergency mitigation; all changes must be backported to Git immediately.

---

### 4. Runtime Plane — Execution Authority

The runtime environment executes:

- reconciled Kubernetes resources
- platform capabilities
- tenant workloads
- observability collection
- policy enforcement

The runtime must never be a source of truth — only a reflection of Git state.

---

## Authority Flow Summary

```
Tenant intent → Contract
Contract → CI proposal
CI → GitOps state update
GitOps → Cluster reconciliation
Cluster → Running system
```

No layer should bypass another.

---

# Strategic Role

The Control Plane Model defines the fundamental authority boundaries in the ZaveStudios platform.

Each layer has a distinct responsibility:

- **Contract Plane** — captures tenant intent
- **CI Plane** — validates and builds
- **GitOps Plane** — maintains authoritative state
- **Runtime Plane** — executes the declared state

These boundaries are architectural invariants. Violations create ambiguity and risk.
