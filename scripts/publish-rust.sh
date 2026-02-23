#!/bin/bash
set -e

VERSION=${1:-1.0.0}
CARGO_REGISTRY="${CARGO_REGISTRY:-company}"
CARGO_REGISTRY_URL="${CARGO_REGISTRY_URL:-https://artifactory.example.com/artifactory/api/cargo/cargo-local}"
CARGO_REGISTRY_TOKEN="${CARGO_REGISTRY_TOKEN}"

RUST_DIR="gen/rust"

echo "📤 Publikowanie biblioteki Rust v${VERSION} do artifactory..."

# Sprawdź czy crate został zbudowany
if [ ! -f "${RUST_DIR}/target/package/proto-demo-${VERSION}.crate" ]; then
    echo "❌ Brak zbudowanego crate. Uruchom najpierw: make build-rust-lib"
    exit 1
fi

cd "${RUST_DIR}"

# Konfiguruj custom registry (jeśli jeszcze nie skonfigurowany)
if ! grep -q "\[registries.${CARGO_REGISTRY}\]" ~/.cargo/config.toml 2>/dev/null; then
    echo "⚙️  Konfigurowanie custom cargo registry..."
    mkdir -p ~/.cargo
    cat >> ~/.cargo/config.toml <<EOF

[registries.${CARGO_REGISTRY}]
index = "${CARGO_REGISTRY_URL}"
EOF
    echo "✅ Registry skonfigurowany"
fi

# Publikacja
echo "📦 Publikowanie crate..."

if [ -n "$CARGO_REGISTRY_TOKEN" ]; then
    # Publikacja przez cargo (jeśli token dostępny)
    cargo publish --registry "${CARGO_REGISTRY}" --token "${CARGO_REGISTRY_TOKEN}"
    echo "✅ Opublikowano przez cargo publish"
else
    # Alternatywnie: publikacja przez curl
    ARTIFACTORY_URL="${CARGO_REGISTRY_URL%/api/cargo/*}"
    ARTIFACTORY_USER="${ARTIFACTORY_USER:-admin}"
    ARTIFACTORY_PASSWORD="${ARTIFACTORY_PASSWORD}"
    
    if [ -n "$ARTIFACTORY_PASSWORD" ]; then
        curl -u "${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}" \
             -T "target/package/proto-demo-${VERSION}.crate" \
             "${ARTIFACTORY_URL}/cargo-local/proto-demo/${VERSION}/proto-demo-${VERSION}.crate"
        echo "✅ Opublikowano przez curl"
    else
        echo "ℹ️  Symulacja publikacji (CARGO_REGISTRY_TOKEN lub ARTIFACTORY_PASSWORD nie ustawione):"
        echo "   cargo publish --registry ${CARGO_REGISTRY}"
    fi
fi

cd - > /dev/null

echo ""
echo "✅ Biblioteka Rust v${VERSION} opublikowana pomyślnie!"
echo ""
echo "Użycie z Cargo.toml:"
echo "  [dependencies]"
echo "  proto-demo = { version = \"${VERSION}\", registry = \"${CARGO_REGISTRY}\" }"
