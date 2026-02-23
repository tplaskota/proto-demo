#!/bin/bash
set -e

VERSION=${1:-1.0.0}
ARTIFACTORY_URL="${ARTIFACTORY_URL:-https://artifactory.example.com/artifactory}"
ARTIFACTORY_REPO="${ARTIFACTORY_REPO:-libs-release-local}"
ARTIFACTORY_USER="${ARTIFACTORY_USER:-admin}"
ARTIFACTORY_PASSWORD="${ARTIFACTORY_PASSWORD}"

CPP_DIR="gen/cpp"
BUILD_DIR="${CPP_DIR}/build"

echo "📤 Publikowanie biblioteki C++ v${VERSION} do artifactory..."

# Sprawdź czy biblioteka została zbudowana
if [ ! -d "${BUILD_DIR}" ]; then
    echo "❌ Brak zbudowanej biblioteki. Uruchom najpierw: make build-cpp-lib"
    exit 1
fi

# Znajdź pakiety
PACKAGES=$(find "${BUILD_DIR}" -name "proto-demo-cpp-${VERSION}-*.tar.gz" -o -name "proto-demo-cpp-${VERSION}-*.deb" -o -name "proto-demo-cpp-${VERSION}-*.rpm")

if [ -z "$PACKAGES" ]; then
    echo "❌ Nie znaleziono pakietów do publikacji"
    exit 1
fi

# Publikuj każdy pakiet
for PACKAGE in $PACKAGES; do
    PACKAGE_NAME=$(basename "$PACKAGE")
    TARGET_URL="${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/proto-demo-cpp/${VERSION}/${PACKAGE_NAME}"
    
    echo "📦 Publikowanie: ${PACKAGE_NAME}"
    
    if [ -n "$ARTIFACTORY_PASSWORD" ]; then
        curl -u "${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}" \
             -T "${PACKAGE}" \
             "${TARGET_URL}"
    else
        echo "ℹ️  Symulacja publikacji (ARTIFACTORY_PASSWORD nie ustawione):"
        echo "   curl -u ${ARTIFACTORY_USER}:*** -T ${PACKAGE} ${TARGET_URL}"
    fi
    
    echo "✅ Opublikowano: ${PACKAGE_NAME}"
done

echo ""
echo "✅ Biblioteka C++ v${VERSION} opublikowana pomyślnie!"
echo ""
echo "Instalacja z artifactory:"
echo "  # Dodaj do CMakeLists.txt:"
echo "  set(PROTO_DEMO_URL \"${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/proto-demo-cpp/${VERSION}/proto-demo-cpp-${VERSION}-Linux.tar.gz\")"
echo "  file(DOWNLOAD \${PROTO_DEMO_URL} proto-demo.tar.gz)"
echo "  execute_process(COMMAND tar xzf proto-demo.tar.gz)"
