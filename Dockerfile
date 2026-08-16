# syntax=docker/dockerfile:1
# =============================================================================
# Momentum — TEK IMAJ: .NET 10 API + Flutter web istemcisi AYNI KOKENDE
# =============================================================================
# NEDEN TEK IMAJ (ODEV §8(4) + §2):
#   Degerlendirici `docker compose up` yazar ve http://localhost:5298 adresinde
#   CALISAN uygulamayi gorur. Istemci API ile ayni kokenden servis edilir; boyle
#   olunca (a) CORS'a hic gerek kalmaz, (b) IzolasyonBasliklari'nin COOP/COEP
#   basliklari istemci BELGESINE fiilen deger -- IstemciServisi'nin kapattigi
#   beyan edilmis sinir budur, (c) cevrimdisi-oncelikli senkron + cakismali
#   duzeltme vitrini CANLI gosterilebilir (Pages demosunda backend olmadigi icin
#   o ayak ASLA olculemiyordu).
#
# BEYAN EDILMIS SINIRLAR (gizlenmiyor):
#   1. Imaj `ASPNETCORE_ENVIRONMENT=Development` ile kosar. Program.cs'te
#      dev-kimlik kalkani (DevCurrentUser) YALNIZ Development'ta devrededir;
#      diger her ortamda NullCurrentUser = varsayilan-ret ⇒ HER istek 401 doner.
#      Auth dilimi kapsam disidir (CLAUDE.md §5) ve bu paket onu gizlemez.
#   2. Web istemcisi derleme ZAMANINDA kendi kokenini ogrenir
#      (--dart-define=SENKRON_SUNUCU_URL). Varsayilan http://localhost:5298'dir;
#      compose'da portu degistirirsen ISTEMCI API'YI BULAMAZ -- ayni degeri
#      SENKRON_SUNUCU_URL yapi argumaniyla da vermelisin.
#   3. Bu dosya HENUZ CALISTIRILARAK OLCULMEDI: ne bulut kabugunda ne masaustu
#      VM'inde docker daemon var. Tek olcum yeri CI'dir (tek-komut kapisi).
# =============================================================================


# --- 1) ISTEMCI: Flutter web derlemesi ---------------------------------------
# RISK (adlandiriliyor): cirruslabs imaji ucuncu taraftir ve `3.44.6` etiketinin
# varligi OLCULMEDI. CI kirmizi yanarsa ilk bakilacak yer burasidir.
ARG FLUTTER_SURUM=3.44.6
FROM ghcr.io/cirruslabs/flutter:${FLUTTER_SURUM} AS istemci

WORKDIR /kaynak/client

# Bagimlilik katmani ayri: pubspec degismedikce yeniden cozulmez.
COPY src/client/pubspec.yaml src/client/pubspec.lock ./
RUN flutter pub get

COPY src/client ./

# --no-web-resources-cdn ZORUNLUDUR, konfor degil: (a) COEP acikken capraz-koken
# CDN kaynagi bloklanir, (b) paketin tamami AGSIZ bir makinede acilabilmelidir --
# cevrimdisi vitrini olan bir uygulamanin demosu internet istemez.
# base-href `/` cunku istemci kokten servis edilir (Pages'te `/Momentum/` idi).
ARG SENKRON_SUNUCU_URL=http://localhost:5298
RUN flutter build web --release \
      --no-web-resources-cdn \
      --no-wasm-dry-run \
      --base-href / \
      --dart-define=SENKRON_SUNUCU_URL=${SENKRON_SUNUCU_URL}


# --- 2) SUNUCU: .NET publish + migration bundle -------------------------------
# global.json SDK'yi 10.0.302 + rollForward=latestPatch ile pinler. RISK: taban
# imajin SDK'si FARKLI bir ozellik bandindaysa (or. 10.0.1xx) latestPatch banda
# ATLAMAZ ve restore "SDK bulunamadi" ile duser. CI kirmizisinda ikinci bakilacak
# yer burasidir; cozum somut etiket (mcr...sdk:10.0.302) pinlemektir.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS derleme
WORKDIR /kaynak

# Sadece publish icin gereken agac: Api -> Application + Infrastructure + Domain.
# tests/ ve Momentum.sln BILEREK kopyalanmaz (baglam kucuk, restore dar kalir).
COPY global.json ./
COPY src/backend/Directory.Build.props src/backend/BannedSymbols.txt ./src/backend/
COPY src/backend/Momentum.Domain ./src/backend/Momentum.Domain
COPY src/backend/Momentum.Application ./src/backend/Momentum.Application
COPY src/backend/Momentum.Infrastructure ./src/backend/Momentum.Infrastructure
COPY src/backend/Momentum.Api ./src/backend/Momentum.Api

RUN dotnet restore src/backend/Momentum.Api/Momentum.Api.csproj

RUN dotnet publish src/backend/Momentum.Api/Momentum.Api.csproj \
      -c Release -o /uygulama --no-restore

# EF migration paketi (bundle): SEMAYI UYGULAMA DEGIL, AYRI BIR SERVIS KURAR.
# Gerekce: uretimde uygulamanin kendi semasini degistirmesi anti-desendir; compose
# `migrator` servisi bunu kosar, `api` ona service_completed_successfully ile baglidir.
# Surum EF Core ile ayni bantta pinlenir (Infrastructure: 10.0.4).
RUN dotnet tool install --global dotnet-ef --version 10.0.4
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN dotnet ef migrations bundle \
      --project src/backend/Momentum.Infrastructure/Momentum.Infrastructure.csproj \
      --startup-project src/backend/Momentum.Api/Momentum.Api.csproj \
      --configuration Release \
      --self-contained -r linux-x64 \
      -o /uygulama/momentum-migrator


# --- 3) CALISMA IMAJI ---------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS calisma
WORKDIR /app

COPY --from=derleme /uygulama ./
COPY --from=istemci /kaynak/client/build/web ./istemci

# Kok DISI kullanici: paket, degerlendiricinin makinesinde root olarak kosmaz.
RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin momentum \
    && chown -R momentum:momentum /app
USER momentum

# IstemciServisi.KokDizinAnahtari = "Istemci:KokDizin". BOS birakilirsa ara katman
# HIC kurulmaz ve imaj yalnizca API olur (kill switch bedava gelir).
ENV Istemci__KokDizin=/app/istemci \
    ASPNETCORE_URLS=http://+:5298 \
    DOTNET_EnableDiagnostics=0

EXPOSE 5298

ENTRYPOINT ["dotnet", "Momentum.Api.dll"]
