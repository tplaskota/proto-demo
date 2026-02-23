#!/bin/bash
set -e

VERSION=${1:-1.0.0}
ARTIFACTORY_URL=${ARTIFACTORY_CSHARP_URL:-"https://artifactory.company.com/nuget"}
ARTIFACTORY_USER=${ARTIFACTORY_USER:-"admin"}
ARTIFACTORY_TOKEN=${ARTIFACTORY_TOKEN:-""}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSHARP_DIR="$SCRIPT_DIR/../gen/csharp"

echo "📤 Publishing C# library version $VERSION to artifactory..."

cd "$CSHARP_DIR"

# Sprawdź czy pakiet istnieje
PACKAGE="nupkg/ProtoDemo.${VERSION}.nupkg"
if [ ! -f "$PACKAGE" ]; then
    echo "❌ Error: Package not found: $PACKAGE"
    echo "Run 'make build-csharp-lib' first."
    exit 1
fi

# Publikacja do NuGet feed
if [ -z "$ARTIFACTORY_TOKEN" ]; then
    echo "⚠️  ARTIFACTORY_TOKEN not set. Skipping upload."
    echo ""
    echo "To publish to NuGet feed, set:"
    echo "  export ARTIFACTORY_CSHARP_URL='https://artifactory.company.com/nuget'"
    echo "  export ARTIFACTORY_USER='your-username'"
    echo "  export ARTIFACTORY_TOKEN='your-api-token'"
    echo ""
    echo "Then run:"
    echo "  dotnet nuget push $PACKAGE --source \$ARTIFACTORY_CSHARP_URL --api-key \$ARTIFACTORY_TOKEN"
    exit 0
fi

echo "Pushing to NuGet feed: $ARTIFACTORY_URL"
dotnet nuget push "$PACKAGE" \
    --source "$ARTIFACTORY_URL" \
    --api-key "$ARTIFACTORY_TOKEN"

echo "✅ C# library published successfully!"
