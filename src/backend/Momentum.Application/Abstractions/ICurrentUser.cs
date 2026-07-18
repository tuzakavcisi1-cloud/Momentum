namespace Momentum.Application.Abstractions;

/// <summary>
/// Port for the ambient authenticated user (ADR 0001 K-D5).
/// slice-1 defines the CONTRACT only; the implementation and the owner query-filter
/// arrive with the auth/identity slice. Not consumed nor registered in this slice.
/// </summary>
public interface ICurrentUser
{
    /// <summary>The authenticated user's id, or <c>null</c> when anonymous.</summary>
    Guid? UserId { get; }
}
