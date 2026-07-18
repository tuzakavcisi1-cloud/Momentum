# Dependencies — slice-1 (backend omurga)

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

## License-gate summary
All packages are permissive OSI licenses (MIT / Apache-2.0 / BSD-3-Clause) — no copyleft, no
commercial-use restriction. **Banned families avoided:** MediatR 13+ (commercial), AutoMapper
(commercial), FluentAssertions 8+ (commercial).

**One deviation from the letter of the spec:** GOREV §4 / ADR K-H2 named Shouldly as "MIT"; its
real license is **BSD-3-Clause**. The *package choice* is already ratified by ADR K-H2; only the
license label was inaccurate. BSD-3-Clause satisfies the gate's intent (permissive, non-commercial),
but since GOREV §6 says "yalnız MIT/Apache", this is surfaced here (not silently passed) for Cowork.
