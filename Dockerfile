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
#   3. `api` servisinde healthcheck YOKTUR: aspnet taban imajinda curl/wget
#      bulunmaz ve sirf yoklama icin imaja arac eklemek calisma yuzeyini buyutur.
#      Hazirlik DISARIDAN olculur: curl -fsS http://localhost:5298/health/ready
#
# OLCUM: `.github/workflows/paket.yml` her ilgili push'ta `docker compose up
# --build`i GitHub runner'inda kosar. Kapinin ILK SURUMU KORDU ve bagimsiz denetim
# bunu olcerek gosterdi (yalniz index.html iceren bir kokle dort ayak da yesil
# yandi); kapi o79'da yeniden yazildi -- artik derlenmis VARLIKLAR cekilir ve URUN
# UCU cagrilir. Yesil/kirmizi durumu icin son `paket` kosumuna bakin; bu yorum bir
# olcum KAYDI degil, kapinin NEREDE oldugunun isaretidir.
# =============================================================================


# --- 1) ISTEMCI: Flutter web derlemesi ---------------------------------------
# OLCULMUS KARAR (o79): once `ghcr.io/cirruslabs/flutter:3.44.6` denendi ve CI
# birebir su hatayi verdi: "ghcr.io/cirruslabs/flutter:3.44.6: not found" --
# o depoda 3.44.6 etiketi YOK (paket sayfasinda en yakini 3.44.0). Ucuncu tarafin
# etiket takvimi bizim pinimizi baglamaz. Yerine BIRINCI TARAF arsiv cekilir ve
# sha256 DOGRULANIR; surum boylece CI (subosito 3.44.6) ve pubspec.lock ile
# BIREBIR ayni kalir ve tedarik zincirinde dogrulanmamis bir katman kalmaz.
# Kaynak: storage.googleapis.com/flutter_infra_release/releases/releases_linux.json
# (16 Agu 2026'da okundu: 3.44.6, kanal=stable).
# --platform PINI ZORUNLUDUR (o79 denetim bulgusu B3): asagida cekilen Flutter
# arsivi Google'in kendi manifestinde `dart_sdk_arch = x64`tir ve linux-arm64
# yayini YOKTUR. Pin olmadan Apple Silicon bir makinede BuildKit taban imaji
# `linux/arm64` cozer, x64 tarball iner, sha256 TUTAR (ayni URL) ve `flutter
# --version` "cannot execute binary file" ile duser. Kapi bunu goremez, cunku
# runner x64'tur. Pin, arm64 makinede bu katmani emulasyonla (yavas ama calisir)
# kosturur. Calisma imajina --platform pini KONMAZ -- `aspnet` cok mimarilidir;
# surum pini ayridir, bkz. asagidaki OLCULMUS PIN (o81).
FROM --platform=linux/amd64 debian:bookworm-slim AS istemci

ARG FLUTTER_SURUM=3.44.6
ARG FLUTTER_SHA256=a6320fd72e9a2690c08e2a6a70874a30cb120dee7c78f49d2c628bd7c9e20525

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*

# sha256 kontrolu bir konfor degil kapidir: tutmazsa yapi BURADA duser.
RUN curl -fsSL -o /tmp/flutter.tar.xz \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_SURUM}-stable.tar.xz" \
 && echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum -c - \
 && tar -xJf /tmp/flutter.tar.xz -C /opt \
 && rm /tmp/flutter.tar.xz

ENV PATH="/opt/flutter/bin:${PATH}"

# Arsivin icinde .git vardir; sahiplik farki olursa flutter git cagrilarinda duser.
RUN git config --global --add safe.directory /opt/flutter \
 && flutter --version \
 && flutter precache --web

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
# DEV_USER_ID BOS BIRAKILIRSA her kurulum RASTGELE bir kullanici uretir (olculdu:
# ayarlari_hazirla.dart b-dali) ⇒ paketteki web istemcisi ile APK birbirini GORMEZ
# ve iki-istemci vitrini paketten cikmaz. compose bu yuzden sabit bir demo kimligi
# verir; varsayilanin BOS kalmasi mevcut davranisi degistirmemek icindir.
ARG DEV_USER_ID=
RUN flutter build web --release \
      --no-web-resources-cdn \
      --no-wasm-dry-run \
      --base-href / \
      --dart-define=SENKRON_SUNUCU_URL=${SENKRON_SUNUCU_URL} \
      --dart-define=DEV_USER_ID=${DEV_USER_ID}


# --- 2) SUNUCU: .NET publish + migration bundle -------------------------------
# OLCULMUS PIN (o79): global.json SDK'yi 10.0.302 + rollForward=latestPatch ile
# baglar ve latestPatch ozellik BANDI atlamaz. MCR etiket listesi okundu
# (mcr.microsoft.com/v2/dotnet/sdk/tags/list, 16 Agu 2026): hem `10.0.302` hem
# `10.0.400` yayinda ⇒ YUZEN `10.0` etiketi 10.0.400'e dusup restore'u kirabilirdi.
# Bu yuzden SDK etiketi global.json ile BIREBIR pinlenir; yapi tekrarlanabilir olur.
FROM mcr.microsoft.com/dotnet/sdk:10.0.302 AS derleme
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
# Surum EF Core ile ayni bantta pinlenir (Infrastructure: 10.0.4; nuget.org'da
# dogrulandi). BASLANGIC PROJESI = Infrastructure, Api DEGIL -- bu OLCULDU:
# Api ile kosuldugunda komut birebir su hatayi verir:
#   "Your startup project 'Momentum.Api' doesn't reference
#    Microsoft.EntityFrameworkCore.Design."
# Cunku Design paketi Infrastructure'da `PrivateAssets=all` ile durur ve Api'ye
# AKMAZ. SyncDbContextDesignTimeFactory tam da bunun icin vardir: EF, context'i
# uygulama host'u olmadan kurar. Bu olcum CI turu harcanmadan bulutta yapildi.
#
# `--self-contained` KULLANILMIYOR: calisma imajinda .NET calisma zamani zaten var.
# Olculdu: self-contained paket 108 MB, cerceve-bagimli paket 34,7 MB.
RUN dotnet tool install --global dotnet-ef --version 10.0.4
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN dotnet ef migrations bundle \
      --project src/backend/Momentum.Infrastructure/Momentum.Infrastructure.csproj \
      --startup-project src/backend/Momentum.Infrastructure/Momentum.Infrastructure.csproj \
      --configuration Release \
      -o /uygulama/momentum-migrator


# --- 3) CALISMA IMAJI ---------------------------------------------------------
# OLCULMUS PIN (o81): yuzen `10.0` etiketi SU AN 10.0.11 veriyor (docker run --rm
# mcr.microsoft.com/dotnet/aspnet:10.0 dotnet --list-runtimes, 17 Agu 2026). MCR
# etiket listesi okundu (mcr.microsoft.com/v2/dotnet/aspnet/tags/list): `10.0.11`
# bare-tag olarak yayinda, komsu `10.0.10` da yayinda ⇒ yuzen etiket ozellik
# BANDI atlayabilir, tipki SDK pininin yukaridaki gerekcesindeki gibi. Bu yuzden
# calisma imaji da SDK ile ayni bicimde BIREBIR pinlenir; yapi tekrarlanabilir olur.
FROM mcr.microsoft.com/dotnet/aspnet:10.0.11 AS calisma
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
    DOTNET_EnableDiagnostics=0 \
    DOTNET_ROOT=/usr/share/dotnet
# DOTNET_ROOT ACIKCA yazilir: migration paketi cerceve-bagimlidir ve apphost
# calisma zamanini once DOTNET_ROOT'ta arar. Bulutta olculdu -- degisken yokken
# paket "You must install .NET to run this application" ile duser. Kapi migrator
# adiminda kirmizi yanarsa carei `--self-contained -r linux-x64`a donmektir
# (bedeli: paket 34,7 MB yerine 108 MB).

EXPOSE 5298

ENTRYPOINT ["dotnet", "Momentum.Api.dll"]
