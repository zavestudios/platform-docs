# ZaveStudios — Workload Contract Schema v0.1

This document defines the **authoritative workload contract** for the ZaveStudios platform.

The contract is the sole workload interface to the platform (tenant and portfolio).
Repositories, pipelines, infrastructure, and runtime configuration must be derived from this file.

If something cannot be expressed in this schema, it is not part of the supported platform surface.

---

# Canonical Workload Contract Definition

All platform documents must reference this shape verbatim.
The conventional filename is `zave.yaml`.

```yaml
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: <service-name>

spec:
  runtime: <runtime>
  exposure: <exposure-type>
  delivery: <strategy>
```

Contract constraints:

- The contract shape is a Kubernetes-style object with `apiVersion`, `kind`, `metadata`, and `spec`.
- Optional sections extend behavior, but may not change the canonical top-level structure.
- Structural keys are required for object identity and versioning.

---

# Contract Principles

The schema is designed to enforce the following constraints:

- Workloads declare **intent**, not implementation
- Platform mechanics must be derivable automatically
- Allowed variance must be bounded and enumerable
- Runtime behavior must remain predictable
- Governance must be enforceable statically

The contract must therefore remain:

- Small
- Versioned
- Machine-validatable
- Backward-compatible

---

# Top-Level Structure

The top-level structure is defined in `Canonical Workload Contract Definition`.
Optional sections extend behavior in controlled ways.
Tenant "infrastructure decisions" are counted from tenant-selected values under `spec`.

---

# Definition of Infrastructure Decision

For the Tier 0 "five or fewer decisions" principle:

- `apiVersion`, `kind`, and `metadata.name` are structural fields, not tenant decisions.
- Required tenant decisions for a minimal workload are:
  - `spec.runtime`
  - `spec.exposure`
  - `spec.delivery`
- `spec.resources.tier` is optional and should default safely.

Minimal workload example:

```yaml
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: payments-api
spec:
  runtime: container
  exposure: public-http
  delivery: rolling
```

---

# Metadata Section

```yaml
metadata:
  name: payments-api
```

Rules:

- Must be DNS-compatible
- Must be unique within the platform
- Immutable once deployed
- Used as the canonical service identifier

---

# Runtime Section

```yaml
spec:
  runtime: container
```

Declared values:

- container

Contract version support (Formation / v0.1):

- Implemented: `container`, `static`
- Reserved for future versions: `node`, `python`, `go`, `java`

This value determines runtime policy, probe defaults, and compatibility checks.

For static-site workloads (`spec.runtime: static`):

- The repository remains fully contract-governed.
- Delivery semantics, validation gates, and lifecycle rules are unchanged.
- Runtime profile differs (static artifact serving vs long-lived app process), not governance level.

---

# Build Section (Transitional Model)

```yaml
spec:
  build:
    mode: dockerfile
    dockerfilePath: Dockerfile
```

Rules in v0.1:

- `build.mode` must be `dockerfile`
- Tenant-provided Dockerfile is allowed
- Direct image reference fields are not allowed in contract input
- Platform build workflows remain platform-owned and generated
- Reserved for future contract versions: `build.mode: managed`

This preserves the transitional model: BYO Dockerfile now, managed runtime abstractions later.

---

# Exposure Section

```yaml
spec:
  exposure: public-http
```

Allowed values:

- none
- internal-http
- public-http
- grpc
- async

This determines:

- ingress configuration
- service mesh policy
- DNS behavior
- routing configuration

No custom ingress configuration is allowed outside this field.

---

# Delivery Strategy Section

```yaml
spec:
  delivery: rolling
```

Allowed values:

- rolling
- recreate
- blue-green
- canary

The strategy is declared intent in the contract.  
Support may be partial depending on contract version.

v0.1 implementation status:

- Implemented end-to-end: `rolling`
- Reserved: `recreate`, `blue-green`, `canary`

When implemented, strategy controls:

- deployment orchestration
- traffic shifting logic
- rollback behavior
- promotion semantics

Workload repositories must not define deployment YAML directly.

---

# Persistence Section (Optional)

```yaml
spec:
  persistence:
    engine: postgres
```

Allowed engines:

- postgres
- mysql
- redis
- none

This determines:

- managed service provisioning
- secret injection
- connection policy
- backup automation

Storage configuration must not appear outside this section.

---

# Capability Section (Optional)

Capabilities extend workloads with reusable platform modules.

```yaml
spec:
  capabilities:
    - name: metrics
    - name: tracing
```

Capabilities are:

- versioned
- platform-owned
- attachable without tenant YAML

Capability classes:

- Feature capabilities (do not change deployment shape), e.g.:
  - metrics
  - tracing
- Structural capabilities (change deployable shape), e.g.:
  - job-runner
  - cron
  - queue-consumer

v0.1 allows only feature capabilities.
Structural capabilities are deferred until role/deployable-unit modeling is introduced in a future schema version.

---

# Resources Section (Optional)

```yaml
spec:
  resources:
    tier: standard
```

Allowed tiers (example):

- small
- standard
- large

This maps to:

- CPU/memory defaults
- scaling bounds
- cost controls

Raw resource requests must not be tenant-defined.

---

# AI Workload Support (Reserved for Future Versions)

The ZaveStudios platform infrastructure targets **CNCF Kubernetes AI Conformance** certification to ensure AI/ML workloads are portable, reproducible, and interoperable across conformant environments.

CNCF AI Conformance guarantees that AI workloads using standard Kubernetes APIs can run consistently across certified platforms without environment-specific customization.

**Formation v0.1 Status:**

AI workloads are currently supported as standard container workloads. Future contract versions will introduce AI-specific abstractions.

**Resources Section — GPU Support (Reserved):**

Future versions may support GPU resource tiers:

```yaml
spec:
  resources:
    tier: gpu-small  # Reserved: gpu-small, gpu-standard, gpu-large
```

GPU tiers would map to:

- GPU allocation and scheduling
- Accelerator-optimized node selection
- Cost controls and quota management
- CUDA/ROCm driver compatibility

**Runtime Section — AI Runtimes (Reserved):**

Future versions may support AI-specific runtime types:

```yaml
spec:
  runtime: ai-training  # Reserved: ai-training, ai-inference, ai-batch
```

These runtime types would determine:

- Job execution patterns (training vs inference workloads)
- Resource lifecycle (ephemeral training jobs vs long-lived inference services)
- Autoscaling behavior (batch-oriented vs request-driven)

**Capability Section — AI Modules (Reserved):**

Future versions may support AI-specific capabilities:

```yaml
spec:
  capabilities:
    - name: ai-training    # Reserved: distributed training orchestration
    - name: ai-inference   # Reserved: model serving and inference optimization
    - name: model-registry # Reserved: model versioning and artifact management
```

**Formation v0.1 Workaround:**

During Formation, AI workloads use the existing contract model:

```yaml
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: ml-model-training

spec:
  runtime: container      # Standard container runtime
  exposure: none          # Training jobs may not need ingress
  delivery: rolling       # Or future: job-based delivery

  build:
    mode: dockerfile      # Dockerfile with ML framework dependencies

  persistence:
    engine: postgres      # For experiment tracking, model metadata

  resources:
    tier: large           # Request large tier; GPU allocation is infrastructure-level config
```

Infrastructure teams configure GPU node pools and scheduling separately. Contract-based GPU allocation is reserved for future versions.

**Rationale:**

- **Portability**: CNCF AI Conformance ensures GPU workloads remain portable across certified clusters
- **Bounded variance**: AI workloads declare resource tiers, not raw CUDA device requests
- **Infrastructure separation**: Platform owns GPU provisioning and node configuration
- **Formation discipline**: Reserve AI-specific abstractions until contract schema stabilizes

---

# Full Example

```yaml
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: payments-api

spec:
  runtime: container
  exposure: public-http
  delivery: rolling

  build:
    mode: dockerfile

  persistence:
    engine: postgres

  capabilities:
    - name: metrics
    - name: tracing

  resources:
    tier: standard
```

This file must be sufficient for the platform to:

- generate a repository scaffold
- bind CI workflows
- provision dependencies
- register GitOps state
- deploy a functioning service

If manual infrastructure decisions remain necessary, the schema is incomplete.

---

# Validation Requirements

The platform must enforce:

- schema validation at PR time
- runtime/runtime compatibility checks
- delivery strategy compatibility
- exposure policy validation
- capability compatibility checks

Invalid contracts must never reach GitOps.

---

# Versioning Model

The contract must follow:

- additive-only changes within a version
- explicit upgrade paths between versions
- platform-provided migration tooling

Example:

```
zave contract migrate v1 → v2
```

Tenants must never rewrite contracts manually during upgrades.

---

# Non-Goals

The contract intentionally does not allow:

- custom pipeline definitions
- custom image references
- custom ingress objects
- custom cluster resources
- manual network topology
- arbitrary environment overlays

These are platform responsibilities.

---

# Strategic Role

This schema is the **foundation of the platform control surface**.

Every downstream system must derive from it:

- repo scaffolding
- pipeline generation
- GitOps composition
- runtime configuration
- governance enforcement

If a behavior cannot be derived from the contract, it should not exist in the platform.
