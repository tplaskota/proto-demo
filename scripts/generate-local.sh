#!/bin/bash
set -e

PROTO_DIR="proto"
OUT_CPP="gen/cpp"
OUT_PYTHON="gen/python"

echo "🔨 Generowanie kodu protobuf (lokalne narzędzia)..."
echo ""

# Sprawdź czy protoc jest zainstalowany
if ! command -v protoc &> /dev/null; then
    echo "❌ protoc nie jest zainstalowany"
    echo "   Uruchom: make install-plugins"
    exit 1
fi

echo "✅ protoc: $(protoc --version)"

# Utwórz katalogi wyjściowe
mkdir -p "${OUT_CPP}"
mkdir -p "${OUT_PYTHON}"

# Znajdź wszystkie pliki proto
PROTO_FILES=$(find ${PROTO_DIR} -name "*.proto")

if [ -z "$PROTO_FILES" ]; then
    echo "❌ Nie znaleziono plików .proto w ${PROTO_DIR}"
    exit 1
fi

echo "📁 Znaleziono pliki proto:"
echo "$PROTO_FILES" | sed 's/^/   /'
echo ""

# Generowanie C++
echo "🔧 Generowanie C++..."
protoc \
    --proto_path="${PROTO_DIR}" \
    --cpp_out="${OUT_CPP}" \
    --cpp_opt=speed \
    ${PROTO_FILES}

# Generowanie C++ gRPC (jeśli dostępne)
if command -v grpc_cpp_plugin &> /dev/null; then
    echo "🔧 Generowanie C++ gRPC..."
    protoc \
        --proto_path="${PROTO_DIR}" \
        --grpc_out="${OUT_CPP}" \
        --plugin=protoc-gen-grpc=$(which grpc_cpp_plugin) \
        ${PROTO_FILES}
else
    echo "⚠️  grpc_cpp_plugin nie znaleziony - pomijam generowanie gRPC dla C++"
fi

echo ""

# Generowanie Python
echo "🔧 Generowanie Python..."
protoc \
    --proto_path="${PROTO_DIR}" \
    --python_out="${OUT_PYTHON}" \
    ${PROTO_FILES}

# Generowanie Python gRPC (jeśli dostępne)
if command -v grpc_python_plugin &> /dev/null; then
    echo "🔧 Generowanie Python gRPC..."
    protoc \
        --proto_path="${PROTO_DIR}" \
        --grpc_python_out="${OUT_PYTHON}" \
        --plugin=protoc-gen-grpc_python=$(which grpc_python_plugin) \
        ${PROTO_FILES}
elif python3 -m grpc_tools.protoc --version &> /dev/null; then
    echo "🔧 Generowanie Python gRPC (przez grpc_tools)..."
    python3 -m grpc_tools.protoc \
        --proto_path="${PROTO_DIR}" \
        --python_out="${OUT_PYTHON}" \
        --grpc_python_out="${OUT_PYTHON}" \
        ${PROTO_FILES}
else
    echo "⚠️  grpc_python_plugin nie znaleziony - pomijam generowanie gRPC dla Python"
fi

# Generowanie Python type stubs (opcjonalne)
if python3 -c "import mypy_protobuf" 2>/dev/null; then
    echo "🔧 Generowanie Python type stubs (.pyi)..."
    protoc \
        --proto_path="${PROTO_DIR}" \
        --mypy_out="${OUT_PYTHON}" \
        ${PROTO_FILES}
fi

echo ""
echo "✅ Generowanie zakończone!"
echo ""
echo "Wygenerowane pliki:"
echo "  C++:    $(find ${OUT_CPP} -type f | wc -l) plików"
echo "  Python: $(find ${OUT_PYTHON} -type f | wc -l) plików"
echo ""
echo "Lokalizacje:"
echo "  ${OUT_CPP}/"
echo "  ${OUT_PYTHON}/"
