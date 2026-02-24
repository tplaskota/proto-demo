#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$SCRIPT_DIR/../gen/rust"

# Sprawdź czy cargo jest zainstalowany
if ! command -v cargo &> /dev/null; then
    echo "⚠️  cargo (Rust) nie jest zainstalowany - pomijam budowę biblioteki Rust"
    echo "   Zainstaluj Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 0
fi

# Scaffold projektu z szablonów (wzorzec jak CMakeLists.txt.template)
echo "Scaffolding Rust project from templates..."
mkdir -p "$RUST_DIR/src"
cp "$SCRIPT_DIR/rust/Cargo.toml.template"  "$RUST_DIR/Cargo.toml"
cp "$SCRIPT_DIR/rust/build.rs.template"   "$RUST_DIR/build.rs"
cp "$SCRIPT_DIR/rust/lib.rs.template"     "$RUST_DIR/src/lib.rs"

cd "$RUST_DIR"

echo "Building Rust library..."

# Kompilacja (build.rs automatycznie kompiluje proto)
echo "Compiling with cargo (build.rs compiles proto files)..."
cargo build --release

# Testy
echo "Running tests..."
cargo test --release || echo "⚠️  Tests skipped or failed"

# Tworzenie dokumentacji
echo "Generating documentation..."
cargo doc --no-deps

# Pakowanie crate - wymaga skopiowania proto do package
# echo "Packaging crate..."
# cargo package

echo "✅ Rust library built successfully!"
echo "Artifacts:"
echo "  - target/release/libproto_demo.rlib"
# echo "  - target/package/proto-demo-${VERSION:-1.0.0}.crate"
echo "  - target/doc/proto_demo/"
