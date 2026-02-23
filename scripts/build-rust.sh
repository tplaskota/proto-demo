#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$SCRIPT_DIR/../gen/rust"

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
