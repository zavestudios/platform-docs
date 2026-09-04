# ZaveStudios — Workload Contract Schema v0.1

The **authoritative workload contract**: the canonical intent surface for
governed workloads.

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

Formation guidance:

- `spec.persistence` is reserved for backing stores that behave like
  workload-attached data dependencies consumed through direct application
  credentials.
- `postgres` and `mysql` are the canonical relational examples for this
  surface.
- `redis` remains an allowed value in Formation v0.1 for compatibility with
  current platform behavior.
- This does not establish a general rule that caches, brokers, search systems,
  or other shared stateful technologies belong under `spec.persistence`.

Stateful technology categories such as message brokers, event streaming
platforms, and search / analytics stores should be treated as separate platform
capability families unless the platform explicitly decides they behave like
workload-owned backing stores.

---

# Stateful Capability Taxonomy (Formation Guidance)

Formation distinguishes between workload-owned persistence and shared
stateful capabilities.

Decision rule:

- Use `spec.persistence` when the workload needs a primary backing store with
  direct secret injection, connection policy, and backup / recovery semantics
  that attach to that workload.
- Do not add new `spec.persistence.engine` values for every stateful technology
  category by default.
- Treat shared systems such as brokers, streaming platforms, and search tiers
  as separate capability families unless the contract is intentionally expanded
  to support them.

Examples of stateful capability families that should not be inferred from the
current `persistence` enum:

- message brokers
- event streaming platforms
- search / analytics stores
- future shared cache tiers

This keeps the persistence surface narrow while preserving a path for bounded
future expansion.

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
Stateful shared-service capability families are not yet part of the supported
v0.1 workload contract surface.
Structural capabilities are deferred until role/deployable-unit modeling is introduced in a future schema version.

## Formation v0.1 Observability Capability Semantics

`metrics` and `tracing` are valid feature capabilities in Formation, but their
declaration is meaningful only when the platform materializes the corresponding
GitOps and runtime behavior.

Tenants declare observability intent in the contract.
The platform defines collection mechanics, endpoints, labels, and controllers.

### `metrics`

Declaring:

```yaml
spec:
  capabilities:
    - name: metrics
```

means the workload is expected to expose Prometheus-format metrics on a
platform-known endpoint.

Formation expectations:

- the workload exposes a named Kubernetes `Service` port `metrics`
- the scrape path defaults to `/metrics`
- GitOps materializes the scrape object required by the active monitoring stack
- Prometheus discovers the workload through platform-owned selectors, not
  ad hoc tenant scrape config

Tenants do not author raw Prometheus scrape jobs in workload repositories.

### `tracing`

Declaring:

```yaml
spec:
  capabilities:
    - name: tracing
```

means the workload is expected to emit OpenTelemetry Protocol (OTLP) traces to
a platform-owned collector path.

Formation expectations:

- workloads emit OTLP to a platform-owned in-cluster receiver
- the receiver is platform-owned and forwards traces to the tracing backend
- workloads must not send traces directly to Tempo or define tenant-specific
  tracing backends
- GitOps materializes the required environment variables, service endpoints,
  and collector wiring

The canonical Formation path is:

```text
workload -> platform-owned Alloy receiver -> Tempo
```

The exact receiver service address is a platform implementation detail and must
be published through GitOps-managed configuration rather than hardcoded by
tenants.

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

