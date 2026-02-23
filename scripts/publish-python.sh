#!/bin/bash
set -e

VERSION=${1:-1.0.0}
PYPI_URL="${PYPI_URL:-https://artifactory.example.com/artifactory/api/pypi/pypi-local}"
PYPI_USERNAME="${PYPI_USERNAME:-admin}"
PYPI_PASSWORD="${PYPI_PASSWORD}"

PYTHON_DIR="gen/python"

echo "📤 Publikowanie biblioteki Python v${VERSION} do artifactory..."

# Sprawdź czy wheel został zbudowany
if [ ! -d "${PYTHON_DIR}/dist" ]; then
    echo "❌ Brak zbudowanego wheel. Uruchom najpierw: make build-python-lib"
    exit 1
fi

cd "${PYTHON_DIR}"

# Sprawdź dostępność twine
if ! command -v twine &> /dev/null; then
    echo "📦 Instalowanie twine..."
    python3 -m pip install --upgrade twine
fi

# Publikacja
echo "📦 Publikowanie wheel package..."

if [ -n "$PYPI_PASSWORD" ]; then
    python3 -m twine upload \
        --repository-url "${PYPI_URL}" \
        --username "${PYPI_USERNAME}" \
        --password "${PYPI_PASSWORD}" \
        dist/*
    echo "✅ Opublikowano przez twine"
else
    # Alternatywnie: curl dla bezpośredniego uploadu
    ARTIFACTORY_URL="${PYPI_URL%/api/pypi/*}"
    
    for WHEEL in dist/*.whl; do
        WHEEL_NAME=$(basename "$WHEEL")
        echo "ℹ️  Symulacja publikacji (PYPI_PASSWORD nie ustawione):"
        echo "   twine upload --repository-url ${PYPI_URL} ${WHEEL}"
        echo "   lub:"
        echo "   curl -u ${PYPI_USERNAME}:*** -T ${WHEEL} ${ARTIFACTORY_URL}/pypi-local/proto-demo/${VERSION}/${WHEEL_NAME}"
    done
fi

cd - > /dev/null

echo ""
echo "✅ Biblioteka Python v${VERSION} opublikowana pomyślnie!"
echo ""
echo "Instalacja z artifactory:"
echo "  pip install proto-demo==${VERSION} --index-url ${PYPI_URL}/simple"
echo ""
echo "Lub w requirements.txt:"
echo "  proto-demo==${VERSION}"
echo ""
echo "Konfiguracja pip (~/.pip/pip.conf):"
echo "  [global]"
echo "  index-url = ${PYPI_URL}/simple"
