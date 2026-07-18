namespace Momentum.Application.Abstractions;

/// <summary>
/// Marker: a command that manages its own transaction(s) and must be SKIPPED by the ambient
/// <c>TransactionBehavior</c> (ADR 0001 K-G1, K2-E5). <c>SyncCommand</c> uses this — it runs one
/// transaction per op, not one for the whole batch.
/// </summary>
public interface ITransactionOptOut;
