# Dependencies — slice-1 (backend omurga) + slice-2b1/2b2

> ADR 0001 K-H1 / red line #3: every package carries a license + CVE line.
> Licenses were read from each package's NuGet `.nuspec` (SPDX expression) or, where the
> nuspec uses a legacy `licenseUrl` / `license file`, from the project's repository LICENSE.
> CVE status: `dotnet list package --vulnerable --include-transitive` reported **0** advisories
> across the whole solution on 2026-07-18 (see `araclar/verify.ps1` CVE gate + `KANIT/slice-1`).

## Production (src/backend)

| Package | Version | License | CVE (2026-07-18) | Notes |
|---|---|---|---|---|
| Mediator.Abstractions | 3.0.2 | MIT | none | martinothamar/Mediator; nuspec `license file=LICENSE` (repo is MIT). ADR K-B1a. |
| Mediator.SourceGenerator | 3.0.2 | MIT | none | Analyzer, `PrivateAssets=all`. Latest **stable** (not preview). |
| Microsoft.CodeAnalysis.BannedApiAnalyzers | 5.6.0 | MIT | none | src/backend only (Directory.Build.props). Bans `DateTime.*` (K-C5/K-H1). |
| Microsoft.AspNetCore.OpenApi | 9.0.18 | MIT | none | Built-in OpenAPI JSON; pinned to the 9.0.x shared framework. |
| Scalar.AspNetCore | 2.16.15 | MIT | none | API reference UI (no built-in Swagger UI in .NET 9). |
| Asp.Versioning.Http | 8.1.1 | MIT | none | URL-segment versioning (`/v1`). No 9.x line published; 8.1.1 runs on net9.0. |
| Serilog.AspNetCore | 9.0.0 | Apache-2.0 | none | Structured logging + request logging + correlation-id. |

## Test (tests/)

| Package | Version | License | CVE (2026-07-18) | Notes |
|---|---|---|---|---|
| Microsoft.NET.Test.Sdk | 17.12.0 | MIT | none | SDK-blessed net9 combo (17.x / VSTest, not the 18.x MTP default). |
| xunit | 2.9.2 | Apache-2.0 | none | |
| xunit.runner.visualstudio | 2.8.2 | Apache-2.0 | none | |
| NetArchTest.Rules | 1.3.2 | MIT | none | BenMorris/NetArchTest (repo LICENSE = MIT; nuspec omits license node). Loads net9 assemblies OK. |
| Shouldly | 4.3.0 | **BSD-3-Clause** | none | ⚠ ADR/GOREV labelled this "MIT"; the actual SPDX is **BSD-3-Clause** (still permissive, no commercial restriction). Ratified by Cowork (slice-1). |
| Microsoft.AspNetCore.Mvc.Testing | 9.0.18 | MIT | none | `WebApplicationFactory<Program>`; pinned to the 9.0.x shared framework. |
| CsCheck | 4.7.0 | Apache-2.0 | none | slice-2a. Property-based testing (ADR 0002 K2-H2). Test-only; 0 transitive deps. License re-verified from the nuspec SPDX expression (`Apache-2.0`) — matches ADR risk #9 closure. |
| Microsoft.EntityFrameworkCore | 9.0.1 | MIT | none | slice-2b1 (Infrastructure). Pinned to 9.0.1 to match the Npgsql provider (avoids a Relational assembly conflict). |
| Microsoft.EntityFrameworkCore.Design | 9.0.1 | MIT | none | slice-2b1 (Infrastructure, `PrivateAssets=all`). Migration scaffolding (`dotnet ef`). |
| Npgsql.EntityFrameworkCore.PostgreSQL | 9.0.4 | **PostgreSQL** | none | slice-2b1 (Infrastructure). ⚠ ERRATA: SPDX is **PostgreSQL License** (permissive, BSD/MIT-like — no copyleft/commercial restriction), NOT MIT. Added to the allowed permissive family for this slice. |
| FluentValidation | 12.1.1 | Apache-2.0 | none | slice-2b1 (Application). Structural /v1/sync validation (K-G2). SPDX confirmed Apache-2.0. |
| Testcontainers.PostgreSql | 4.13.0 | MIT | none | slice-2b1 (test-only). Real-DB hazard/concurrency gates (ADR 0002 K2-H). |
| Microsoft.Extensions.Hosting.Abstractions | 9.0.0 | MIT | none | slice-2b2 (Infrastructure, production). `OutboxDispatcher : BackgroundService` — Infrastructure is a plain SDK project (no `Microsoft.AspNetCore.App` shared framework), so the Generic Host abstractions need an explicit reference. Does NOT pull in SignalR/AspNetCore (D9-b's arch rule stays true). SPDX confirmed from nuspec. |
| Microsoft.AspNetCore.SignalR.Client | 9.0.0 | MIT | none | slice-2b2 (test-only: Momentum.Persistence.Tests AND Momentum.Api.Tests — D10 v3 correction, both projects, not one). Real `HubConnection` for D8-vi/vii. SPDX confirmed from nuspec. |
| Microsoft.Extensions.TimeProvider.Testing | 9.0.0 | MIT | none | slice-2b2 (test-only: Momentum.Persistence.Tests). `FakeTimeProvider` — D8-iii's deterministic lease/backoff advance (no real sleep). SPDX confirmed from nuspec. |

## License-gate summary
All packages are permissive OSI licenses (MIT / Apache-2.0 / BSD-3-Clause / **PostgreSQL License**) —
no copyleft, no commercial-use restriction. **Banned families avoided:** MediatR 13+ (commercial),
AutoMapper (commercial), FluentAssertions 8+ (commercial), FsCheck (locked to CsCheck),
AspNetCore.HealthChecks.* (own check written instead), naming-convention packages.

**slice-2b1 license errata:** Npgsql.EntityFrameworkCore.PostgreSQL is under the **PostgreSQL License**
(not MIT). It is a permissive, non-copyleft, non-commercial-restrictive license (BSD/MIT-family) and is
added to the allowed family for this slice — surfaced here (not silently passed) per GOREV D11.

**One deviation from the letter of the spec:** GOREV §4 / ADR K-H2 named Shouldly as "MIT"; its
real license is **BSD-3-Clause**. The *package choice* is already ratified by ADR K-H2; only the
license label was inaccurate. BSD-3-Clause satisfies the gate's intent (permissive, non-commercial),
but since GOREV §6 says "yalnız MIT/Apache", this is surfaced here (not silently passed) for Cowork.

**slice-2b2:** 3 new packages, all MIT (SPDX confirmed from nuspec, see rows above). No SignalR
server package exists — SignalR ships inside `Microsoft.AspNetCore.App` (the Api project's shared
framework), not as a NuGet reference. YASAK list honored: no Redis/backplane package, no MessagePack,
no new mock/mapper/assertion library (all test doubles in this slice — `RecordingSignalPublisher`,
`RecordingGroupManager`, `FakeHubCallerContext` — are hand-written), no `AspNetCore.HealthChecks.*`.
