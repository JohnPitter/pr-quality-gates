<div align="center">

# PR Quality Gates

**101 gates de qualidade, segurança, arquitetura, performance, confiabilidade, API, infraestrutura, documentação, git e AI/ML para projetos Go — organizados em 16 categorias com filtro seletivo.**

[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?style=flat-square&logo=go&logoColor=white)](https://go.dev)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-E8622C?style=flat-square)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/Version-0.4.0-2D8E5E?style=flat-square)](#)
[![License](https://img.shields.io/badge/License-MIT-orange?style=flat-square)](#license)

[Features](#features) · [Categorias](#categorias) · [Como Funciona](#como-funciona) · [Instalação](#instalação) · [Uso](#uso) · [Roadmap](#roadmap)

</div>

---

## O que é o PR Quality Gates?

Plugin do Claude Code que roda **101 gates determinísticos** contra um projeto Go, organizados em **16 categorias**. Você escolhe quais categorias rodar — desde `core` (23 gates críticos, ~3-8k tokens) até `all` (101 gates, ~15-40k tokens).

**Sem LLM no caminho crítico:** as métricas são medidas por ferramentas reais (gosec, govulncheck, gitleaks, errorlint, contextcheck, bodyclose, fieldalignment, hadolint, actionlint, buf, tfsec, revive, e análises customizadas). O Claude só entra pra explicar violações e sugerir refactors.

**Baseline-aware:** em projetos legados, congele o estado atual e deixe o plugin falhar só em violações novas.

---

## Aviso de custo de token

O plugin roda ferramentas localmente (custo zero), mas a saída é consumida pelo Claude. Planeje:

| Comando | Gates rodados | Tokens aproximados |
|---|---|---|
| `/pr-quality-gates:quality-report` | 23 (core) | **3-8k** |
| `/pr-quality-gates:category-report <nome>` | 4-15 (1 categoria) | **1-5k** |
| `/pr-quality-gates:full-audit` | 101 (todos) | **15-40k** |

**Recomendação:** use `quality-report` no dia-a-dia, `category-report` para drill-down, e `full-audit` só quando realmente necessário (audit trimestral, planejamento de refactor).

---

## Categorias

16 categorias temáticas. Cada gate pertence a exatamente uma.

| # | Categoria | Gates | O que cobre |
|---|---|---|---|
| 1 | **security** | 10 | SAST, supply chain, secrets, maintenance, pinning, SBOM, rate limit, body size, server timeouts, CORS |
| 2 | **quality** | 4 | CCN, coverage, mutation, module size |
| 3 | **architecture** | 8 | Coupling (layers/impl), project layout, ISP, DI, error taxonomy, god struct, cohesion, change coupling |
| 4 | **performance** | 8 | Benchmark regression, escape analysis, struct layout, I/O buffering, GOMAXPROCS, N+1, allocs in loop, sync.Pool |
| 5 | **reliability** | 15 | Error wrap, ctx propagation, panic, timeouts, race, copylocks, errcheck, defer Close, ticker Stop, goroutine leak, cache TTL, unbounded growth, concurrent map, nil check, bodyclose |
| 6 | **observability** | 5 | PII in logs, log levels, structured logging, metric cardinality, trace propagation |
| 7 | **operational** | 6 | Health endpoints, graceful shutdown, retry idempotency, circuit breaker, feature flags, startup check |
| 8 | **data** | 5 | Transactions, migration rollback, SQL injection, foreign keys, schema compat |
| 9 | **testing** | 5 | Negative paths, fuzz required, timeout tests, goroutine leak tests, property tests |
| 10 | **compliance** | 4 | Data retention, audit trail, right-to-forget, consent tracking |
| 11 | **release** | 4 | CHANGELOG, semver, release signing, reproducible build |
| 12 | **api** ⭐ | 8 | REST status codes, idempotency, OpenAPI spec, versioning, pagination, GraphQL limits, gRPC compat, content negotiation |
| 13 | **infrastructure** ⭐ | 7 | Dockerfile user, Dockerfile hardening, K8s manifests, K8s security, Terraform (tfsec), GitHub Actions (actionlint), Helm |
| 14 | **documentation** ⭐ | 6 | README sections, godoc coverage, ADR directory, CONTRIBUTING+SECURITY, link health, runbook |
| 15 | **git-hygiene** ⭐ | 6 | Conventional commits, PR size, signed commits, no merge commits, large files, branch naming |
| 16 | **ai-ml** ⭐ | 7 | Prompt injection, LLM timeout, model pinning, PII in prompts, rate limit, response validation, cost tracking |

⭐ = novo em v0.4.0

### Presets

- **`core`** = security + reliability + quality (23 gates) — **default em pre-commit**
- **`all`** = todas as 16 categorias (101 gates) — **default em CI**
- Qualquer combinação via `PR_QUALITY_CATEGORIES=security,reliability,api,ai-ml`

### Cobertura das regras

Cada gate marca a cobertura no header:
- **`FULL`** — usa ferramenta OSS consagrada (gosec, gremlins, errorlint, hadolint, actionlint, etc). Baixo falso positivo.
- **`HEURISTIC`** — grep/regex baseado. Pode ter falso positivo/negativo, útil como sinal inicial. Vários emitem `[INFO]` em vez de `[FAIL]`.

Dos 101 gates: ~45 são `FULL` (ferramenta especializada), ~56 são `HEURISTIC`. Roadmap v0.5 upgrade dos heurísticos pra Go AST analyzers.

---

## Instalação

```
/plugin marketplace add JohnPitter/pr-quality-gates-marketplace
/plugin install pr-quality-gates@pr-quality-gates
```

Ferramentas auxiliares são instaladas automaticamente na primeira execução via `go install`: gosec, govulncheck, gitleaks, gocyclo, gremlins, errcheck, errorlint, contextcheck, bodyclose, fieldalignment, ineffassign, apidiff, cyclonedx-gomod, nilaway, benchstat, revive (~16 tools Go + opcionais: hadolint, actionlint, tfsec, buf, helm).

---

## Uso

### Dia-a-dia: categoria `core`

```
/pr-quality-gates:quality-report
```

23 gates (security + reliability + quality). ~3-8k tokens.

### Drill-down por categoria

```
/pr-quality-gates:category-report api
/pr-quality-gates:category-report ai-ml
/pr-quality-gates:category-report infrastructure
```

### Audit completo

```
/pr-quality-gates:full-audit
```

Todos os 101 gates. ~15-40k tokens — **usar com moderação**.

### Baseline (legacy adoption)

```
/pr-quality-gates:baseline-freeze
```

Congela violações atuais de CCN e module-size. Dali em diante, só novas falham.

---

## Variáveis de ambiente

| Var | Efeito |
|---|---|
| `PR_QUALITY_CATEGORIES=all\|core\|<list>` | Quais categorias rodar |
| `PR_QUALITY_BASELINE=1` | Modo captura (freeze estado atual) |
| `PR_QUALITY_FULL=1` | Ignora baseline (audit de tudo) |
| `BASE_REF=origin/main` | Ref para comparações (CHANGELOG, PR size, etc) |

---

## Estrutura

```
pr-quality-gates/
  .claude-plugin/plugin.json
  lib/
    common.sh                  # bootstrap + helpers
    baseline.sh                # ratchet mode
    categories.sh              # filtro + runner
  hooks/
    pre-commit.sh              # roda "core"
    pr-check.sh                # roda "all" (CI)
  gates/
    security/      (10)   quality/       (4)
    architecture/  (8)    performance/   (8)
    reliability/   (15)   observability/ (5)
    operational/   (6)    data/          (5)
    testing/       (5)    compliance/    (4)
    release/       (4)    api/           (8)  *
    infrastructure/(7)  * documentation/ (6)  *
    git-hygiene/   (6)  * ai-ml/         (7)  *
  config/
    thresholds.json     categories.json    depguard.yml
  commands/
    quality-report.md      full-audit.md
    category-report.md     baseline-freeze.md
```

`*` = novo em v0.4.0

---

## Roadmap

### v0.5 — Precisão (HEURISTIC → FULL)

Substituir gates `HEURISTIC` por analisadores Go AST nativos via `go/analysis`:
- **reliability:** goroutine-leak, concurrent-map, cache-ttl, defer-close, unbounded-growth
- **architecture:** interface-discipline, god-struct, di-discipline
- **performance:** unbounded-loops, alloc-in-loop, sync-pool
- **ai-ml:** prompt-injection (proper taint analysis), pii-in-prompts
- **api:** rest-status-codes, idempotency

Meta: 45 → 80 gates em modo `FULL` (baixo falso positivo).

### v0.6 — Escala e performance do próprio plugin

- **Diff-aware execution:** rodar só categorias afetadas pelo diff
- **Paralelização:** 101 gates em paralelo no CI (~5x mais rápido)
- **Dashboard histórico:** trend de cada categoria em JSON versionado
- **Cache:** resultados de gates FULL cacheados por hash do AST

### v0.7 — Advisory tiers e PR integration

- **BLOCKER / WARNING / INFO** severity levels configuráveis
- **Override governado:** skip com justificativa obrigatória em audit log
- **PR inline comments** no GitHub (estilo SonarCloud bot)
- **Autofix bot** para categorias como git-hygiene (format commit message, split PR)

### v0.8 — Categorias domain-specific (opt-in)

- **frontend** — se detectar React/Vue/Svelte: bundle size, tree shaking, CSS dead code, CSP, XSS
- **mobile** — APK size, permissões justificadas, network state, battery drain
- **accessibility** — WCAG AA, contraste, keyboard nav, screen reader, alt tags
- **i18n** — hardcoded strings, timezone-awareness, unicode, RTL

### v0.9 — Multi-linguagem

- Suporte a **Python, TypeScript, Rust** via plugins filhos
- Marketplace ecosystem: `pr-quality-gates-python`, `pr-quality-gates-rust`
- Core framework (categorias + runner + baseline) compartilhado

---

## License

MIT License — use livremente.
