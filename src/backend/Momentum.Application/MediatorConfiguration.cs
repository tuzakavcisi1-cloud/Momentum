using Mediator;
using Microsoft.Extensions.DependencyInjection;

// Mediator lifetime is a COMPILE-TIME setting (source generator). Because AddMediator is called from
// the Api project (not here, where the generator runs), it must be configured via this assembly
// attribute. Scoped so sync handlers may depend on scoped persistence ports (SyncDbContext, K-A1).
[assembly: MediatorOptions(ServiceLifetime = ServiceLifetime.Scoped)]
