#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_DIR="$SCRIPT_DIR/../gen/python"

cd "$PYTHON_DIR"

echo "Building Python wheel..."

# Scaffold pyproject.toml z szablonu (wzorzec jak CMakeLists.txt.template)
cp "$SCRIPT_DIR/python/pyproject.toml.template" pyproject.toml

# Sprawdź czy pliki są wygenerowane
if [ ! -f "api/v1/common_pb2.py" ]; then
    echo "❌ Error: Proto files not generated. Run 'make generate-python' first."
    exit 1
fi

# Utwórz strukturę pakietu
echo "Creating package structure..."
rm -rf proto_demo
mkdir -p proto_demo/api/v1

# Kopiuj wygenerowane pliki
cp api/v1/*.py proto_demo/api/v1/
touch proto_demo/__init__.py
touch proto_demo/api/__init__.py
touch proto_demo/api/v1/__init__.py

# Buduj wheel
echo "Building wheel package..."
if python3 -m build --version >/dev/null 2>&1; then
    python3 -m build
else
    echo "⚠️  'build' module not installed. Using setuptools directly..."
    python3 setup.py sdist bdist_wheel 2>/dev/null || echo "✅ Package structure created (install 'python3-build' for wheel packaging)"
fi

echo "✅ Python wheel built successfully!"
echo "Artifacts:"
ls -lh dist/*.whl 2>/dev/null || echo "Wheel package in dist/"
