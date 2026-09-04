# ZaveStudios — Observability Model v0.1

## Classification

Observability is a **hybrid platform concern**:

- a **shared platform service surface** for collection, storage, query, and
  operator access
- a **workload capability surface** for tenant-declared intent such as
  `tracing` and `metrics`

It is not purely a tenant-local integration and it is not purely a hidden
platform internal.

Why:

- collection paths are shared across workloads
- storage and query backends are platform-owned
- access and auth to operator surfaces are platform concerns
- tenant signal emission must still be declared intentionally

Therefore:

- tenants declare observability intent
- platform GitOps materializes the collection and routing path
- operator access and baseline workflow remain platform-owned

---

## Formation Scope

In Formation v0.1, the current observability stack is composed of shared
runtime components and workload-specific materialization.

Shared runtime examples include:

- Grafana for dashboards and exploration
- Loki for logs
- Prometheus for metrics
- Tempo for traces
- Alloy for collection and forwarding

Tenant workloads do not define their own observability backends as the normal
governed path.

---

## Ownership Model

### Platform Docs

`platform-docs` owns:

- capability semantics
- ownership boundaries
- canonical operator workflow
- rules for what counts as completed observability materialization

### GitOps

`gitops` owns:

- runtime installation and reconciliation of the shared observability stack
- platform-owned collector and routing resources
- tenant manifest materialization required to connect workloads to that stack

### Tenant Repositories

Tenant repositories own:

- declaring supported observability intent in `zave.yaml`
- application-level instrumentation or plugin enablement
- any workload-local config required to emit signals through the platform path

Tenants do not own:

- direct backend selection
- bespoke collector topologies as the default governed path
- ad hoc operator access patterns

---

## Canonical Paths

### Logs

The canonical Formation path for logs is:

```text
workload stdout/stderr or structured app logs -> platform collector path -> Loki -> Grafana
```

### Metrics

The canonical Formation `metrics` capability remains a Prometheus-style scrape
path:

```text
workload metrics endpoint -> Service -> ServiceMonitor -> Prometheus -> Grafana
```

Implications:

- declaring `metrics` means the workload exposes a scrapeable metrics endpoint
- GitOps must materialize the monitoring object required by the active stack
- OTLP metrics emitted by a workload may be useful implementation detail, but
  do not by themselves satisfy the current Formation `metrics` capability
  contract unless the contract and GitOps standard are explicitly expanded

### Traces

The canonical Formation `tracing` path is:

```text
workload -> platform-owned Alloy receiver -> Tempo -> Grafana
```

Implications:

- workloads emit OTLP using platform-published configuration
- workloads do not send traces directly to Tempo
- the receiver and forwarding path are platform-owned runtime concerns

---

## Capability Completion Rules

An observability capability is not complete when it is only declared in the
contract.

It is complete only when all of the following are true:

1. contract intent is declared
2. GitOps materialization exists
3. the responsible controller reconciles successfully
4. the live runtime path is verifiable
5. an operator can follow the documented workflow to see the signal

This follows [`DIAGNOSTIC_MODEL.md`](DIAGNOSTIC_MODEL.md): declared truth, rendered truth, controller
truth, runtime truth, and user-visible behavior must line up.

---

## Workload Selection Rule

Do not force the same first validation workload to prove every signal type.

Use the workload that best matches the capability being validated:

- `mia` v1 was the initial tracing validation workload; it is now retired and
  should be treated as historical validation evidence, not the current
  reference workload
- `rigoberta` is the current metrics materialization example because it already
  uses the Prometheus-style `ServiceMonitor` path

If a workload does not yet satisfy the canonical semantics of a capability, its
contract should not claim that capability as complete platform behavior.

---

## Rollout Guidance

Recommended Formation sequence:

1. stabilize the shared platform observability runtime
2. prove one tracing workload end to end
3. prove one metrics workload end to end
4. document the operator workflow: request -> logs -> metrics -> trace
5. expand capability rollout to additional governed workloads
6. automate validation and generation where feasible

This keeps doctrine aligned with live platform behavior instead of letting
capability declarations outrun materialization.

