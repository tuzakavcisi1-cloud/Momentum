using Asp.Versioning;
using Asp.Versioning.Builder;
using FluentValidation;
using Mediator;
using Momentum.Application.Features.Auth;

namespace Momentum.Api.Endpoints;

/// <summary>
/// <c>POST /v1/auth/{register,login,refresh,logout}</c> (IS-EMRI-o83 D1/§2.1/2). Anonymous by design
/// (there is no <see cref="Momentum.Application.Abstractions.ICurrentUser"/> yet at this point in the
/// flow) -- unlike Sync/Task endpoints, none of these four check <c>currentUser.UserId</c>.
/// </summary>
public static class AuthEndpoints
{
    public static void Map(IEndpointRouteBuilder app, ApiVersionSet versionSet)
    {
        var v1 = app.MapGroup("/v{version:apiVersion}/auth").WithApiVersionSet(versionSet);

        v1.MapPost("/register", HandleRegisterAsync).MapToApiVersion(new ApiVersion(1, 0)).WithName("AuthRegister");
        v1.MapPost("/login", HandleLoginAsync).MapToApiVersion(new ApiVersion(1, 0)).WithName("AuthLogin");
        v1.MapPost("/refresh", HandleRefreshAsync).MapToApiVersion(new ApiVersion(1, 0)).WithName("AuthRefresh");
        v1.MapPost("/logout", HandleLogoutAsync).MapToApiVersion(new ApiVersion(1, 0)).WithName("AuthLogout");
    }

    private static async Task<IResult> HandleRegisterAsync(
        RegisterRequest request, IValidator<RegisterRequest> validator, IMediator mediator, CancellationToken cancellationToken)
    {
        var validation = await validator.ValidateAsync(request, cancellationToken);
        if (!validation.IsValid)
        {
            return Results.ValidationProblem(validation.ToDictionary());
        }

        var result = await mediator.Send(new RegisterCommand(request.Email, request.Password), cancellationToken);
        return result.Code switch
        {
            AuthResultCode.Ok => Results.Created("/v1/auth/login", result.Tokens),
            AuthResultCode.EmailTaken => Results.Conflict(new { detail = "email already registered" }),
            _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
        };
    }

    private static async Task<IResult> HandleLoginAsync(
        LoginRequest request, IValidator<LoginRequest> validator, IMediator mediator, CancellationToken cancellationToken)
    {
        var validation = await validator.ValidateAsync(request, cancellationToken);
        if (!validation.IsValid)
        {
            return Results.ValidationProblem(validation.ToDictionary());
        }

        var result = await mediator.Send(new LoginCommand(request.Email, request.Password), cancellationToken);
        return result.Code switch
        {
            AuthResultCode.Ok => Results.Ok(result.Tokens),
            AuthResultCode.InvalidCredentials => Results.Unauthorized(),
            _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
        };
    }

    private static async Task<IResult> HandleRefreshAsync(
        RefreshRequest request, IValidator<RefreshRequest> validator, IMediator mediator, CancellationToken cancellationToken)
    {
        var validation = await validator.ValidateAsync(request, cancellationToken);
        if (!validation.IsValid)
        {
            return Results.ValidationProblem(validation.ToDictionary());
        }

        var result = await mediator.Send(new RefreshCommand(request.RefreshToken), cancellationToken);
        return result.Code switch
        {
            AuthResultCode.Ok => Results.Ok(result.Tokens),
            AuthResultCode.InvalidOrExpiredRefreshToken => Results.Unauthorized(),
            _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError),
        };
    }

    private static async Task<IResult> HandleLogoutAsync(
        LogoutRequest request, IValidator<LogoutRequest> validator, IMediator mediator, CancellationToken cancellationToken)
    {
        var validation = await validator.ValidateAsync(request, cancellationToken);
        if (!validation.IsValid)
        {
            return Results.ValidationProblem(validation.ToDictionary());
        }

        await mediator.Send(new LogoutCommand(request.RefreshToken), cancellationToken); // always Ok (idempotent, LogoutCommandHandler)
        return Results.NoContent();
    }
}
