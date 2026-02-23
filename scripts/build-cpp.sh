#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_DIR="$SCRIPT_DIR/../gen/cpp"

cd "$CPP_DIR"

echo "Building C++ library..."

# Sprawdź czy pliki są wygenerowane
if [ ! -f "api/v1/common.pb.h" ]; then
    echo "❌ Error: Proto files not generated. Run 'make generate-cpp' first."
    exit 1
fi

# Kopiuj CMakeLists.txt
cp "$SCRIPT_DIR/CMakeLists.txt.template" CMakeLists.txt

# Utwórz katalog build
mkdir -p build
cd build

# Konfiguracja CMake
echo "Configuring with CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# Kompilacja
echo "Compiling..."
make -j$(nproc)

# Tworzenie pakietów
echo "Creating packages..."
cpack

echo "✅ C++ library built successfully!"
echo "Artifacts:"
ls -lh *.tar.gz *.deb *.rpm 2>/dev/null || echo "Package files created"
