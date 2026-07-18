using System.Reflection;
using Momentum.Api.Endpoints;
using Momentum.Application.Abstractions;
using Momentum.Domain;
using Momentum.Infrastructure;
using NetArchTest.Rules;
using Shouldly;
using Xunit;

namespace Momentum.ArchitectureTests;

/// <summary>
/// ADR 0001 K-A1/K-H1 architecture rules (GOREV slice-1 D9). Each rule is a real
/// TYPE-dependency check via NetArchTest (Mono.Cecil), not a mere project-reference check;
/// D10 proves each rule bites by introducing a real type dependency (captured in KANIT).
/// </summary>
public sealed class ArchitectureRuleTests
{
    private static readonly Assembly DomainAssembly = typeof(DomainAssemblyReference).Assembly;
    private static readonly Assembly ApplicationAssembly = typeof(ICurrentUser).Assembly;
    private static readonly Assembly InfrastructureAssembly = typeof(InfrastructureAssemblyReference).Assembly;
    private static readonly Assembly ApiAssembly = typeof(HealthEndpoints).Assembly;

    [Fact]
    public void Sanity_NetArchTest_loads_the_net9_assemblies()
    {
        // If NetArchTest cannot load the .NET 9 assemblies it returns no types -> report loudly
        // (GOREV slice-1 D9: do not silently drop a rule).
        Types.InAssembly(ApplicationAssembly).GetTypes().ShouldNotBeEmpty();
        Types.InAssembly(InfrastructureAssembly).GetTypes().ShouldNotBeEmpty();
        Types.InAssembly(DomainAssembly).GetTypes().ShouldNotBeEmpty();
        Types.InAssembly(ApiAssembly).GetTypes().ShouldNotBeEmpty();
    }

    [Fact]
    public void Rule1_Application_must_not_depend_on_Infrastructure()
    {
        var result = Types.InAssembly(ApplicationAssembly)
            .ShouldNot()
            .HaveDependencyOn("Momentum.Infrastructure")
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(FailureMessage(result));
    }

    [Fact]
    public void Rule2_Api_endpoints_must_not_depend_on_Infrastructure_concrete_types()
    {
        var result = Types.InAssembly(ApiAssembly)
            .That()
            .ResideInNamespace("Momentum.Api.Endpoints")
            .ShouldNot()
            .HaveDependencyOn("Momentum.Infrastructure")
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(FailureMessage(result));
    }

    [Fact]
    public void Rule3_Domain_must_not_depend_on_EfCore_AspNetCore_or_Npgsql()
    {
        var result = Types.InAssembly(DomainAssembly)
            .ShouldNot()
            .HaveDependencyOnAny("Microsoft.EntityFrameworkCore", "Microsoft.AspNetCore", "Npgsql")
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(FailureMessage(result));
    }

    private static string FailureMessage(TestResult result)
    {
        var failing = result.FailingTypeNames is null ? "(none)" : string.Join(", ", result.FailingTypeNames);
        return $"Architecture rule violated. Failing types: {failing}";
    }
}
