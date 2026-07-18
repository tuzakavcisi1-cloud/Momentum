using FluentValidation;

namespace Momentum.Application.Features.Sync;

/// <summary>
/// STRUCTURAL validation only (ADR 0001 K-G2 first use; GOREV slice-2b1 D3). Semantic validation stays
/// in the Domain (op-level <c>RejectedInvalid</c> never drops the batch). Over 100 ops -> 400, nothing
/// processed. An empty <c>ops</c> list (pull-only) is legal.
/// </summary>
public sealed class SyncRequestValidator : AbstractValidator<SyncRequest>
{
    public SyncRequestValidator()
    {
        RuleFor(request => request.Ops).NotNull();
        RuleFor(request => request.Ops!.Count).LessThanOrEqualTo(100).When(request => request.Ops is not null);
        RuleFor(request => request.SinceCursor!.Seq).GreaterThanOrEqualTo(0).When(request => request.SinceCursor is not null);
    }
}
