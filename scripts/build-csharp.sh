#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSHARP_DIR="$SCRIPT_DIR/../gen/csharp"

# Scaffold projektu z szablonów (wzorzec jak CMakeLists.txt.template)
echo "Scaffolding C# project from templates..."
mkdir -p "$CSHARP_DIR"
cp "$SCRIPT_DIR/csharp/ProtoDemo.csproj.template" "$CSHARP_DIR/ProtoDemo.csproj"

cd "$CSHARP_DIR"

echo "Building C# library..."

# Sprawdź czy dotnet jest zainstalowany
if ! command -v dotnet &> /dev/null; then
    echo "❌ Error: dotnet SDK not installed. Install from https://dotnet.microsoft.com/"
    exit 1
fi

# Kompilacja (Grpc.Tools automatycznie kompiluje proto podczas buildu)
echo "Building with dotnet (Grpc.Tools compiles proto files)..."
dotnet build -c Release

# Tworzenie pakietu NuGet
echo "Creating NuGet package..."
dotnet pack -c Release -o ./nupkg

echo "✅ C# library built successfully!"
echo "Artifacts:"
ls -lh bin/Release/net6.0/ProtoDemo.dll 2>/dev/null || echo "  - DLL: bin/Release/net6.0/ProtoDemo.dll"
ls -lh nupkg/*.nupkg 2>/dev/null || echo "  - NuGet: nupkg/ProtoDemo.*.nupkg"
