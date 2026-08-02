import os, sys, subprocess, shutil
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
# IZOLE MUTANT -- Momentum deposuna DOKUNMAZ. Iddia: "A1'in CS0023'u SDK degil,
# net9 HEDEFI + C#14 (SDK10) kombinasyonundan doguyor; net10 hedefinde kayboluyor."
KOK = r"C:\dev\_o48_mutant"
shutil.rmtree(KOK, ignore_errors=True)
os.makedirs(KOK)
open(os.path.join(KOK, "global.json"), "w", encoding="utf-8").write(
    '{ "sdk": { "version": "10.0.302", "rollForward": "latestPatch" } }')
open(os.path.join(KOK, "Program.cs"), "w", encoding="utf-8").write(
    "int[] a = new[] { 1, 2, 3 };\n"
    "var b = a.Reverse().ToArray();\n"
    "System.Console.WriteLine(string.Join(\",\", b));\n")

SABLON = ('<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'
          '<OutputType>Exe</OutputType><TargetFramework>{tf}</TargetFramework>'
          '<Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings>'
          '<LangVersion>{lv}</LangVersion></PropertyGroup></Project>')

for etiket, tf, lv in [("net9.0 + LangVersion=latest (C#14)", "net9.0", "latest"),
                       ("net9.0 + LangVersion=13        ", "net9.0", "13"),
                       ("net10.0 + LangVersion=latest    ", "net10.0", "latest")]:
    open(os.path.join(KOK, "m.csproj"), "w", encoding="utf-8").write(
        SABLON.format(tf=tf, lv=lv))
    shutil.rmtree(os.path.join(KOK, "obj"), ignore_errors=True)
    shutil.rmtree(os.path.join(KOK, "bin"), ignore_errors=True)
    p = subprocess.run(["dotnet", "build", "m.csproj", "--nologo", "-v", "q"], cwd=KOK,
                       capture_output=True, text=True, encoding="utf-8", errors="replace",
                       timeout=300)
    c = (p.stdout or "") + (p.stderr or "")
    hata = [s.strip() for s in c.splitlines() if "error" in s.lower()]
    print("[" + etiket + "] EXIT=" + str(p.returncode) +
          ("   -> " + hata[0][:150] if hata else "   -> DERLENDI"))
print("BITTI")
