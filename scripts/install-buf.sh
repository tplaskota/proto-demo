#!/bin/bash
# Quick install script for buf

set -e

BUF_VERSION="${BUF_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

echo "🔧 Instalacja buf..."
echo "   Katalog: ${INSTALL_DIR}"
echo "   Wersja: ${BUF_VERSION}"
echo ""

# Sprawdź czy już zainstalowany
if command -v buf &> /dev/null; then
    echo "✅ buf już zainstalowany: $(buf --version)"
    read -p "Czy chcesz przeinstalować? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Utwórz katalog instalacji
mkdir -p "${INSTALL_DIR}"

# Pobierz buf
echo "📥 Pobieranie buf..."
OS=$(uname -s)
ARCH=$(uname -m)

if [ "${BUF_VERSION}" = "latest" ]; then
    URL="https://github.com/bufbuild/buf/releases/latest/download/buf-${OS}-${ARCH}"
else
    URL="https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-${OS}-${ARCH}"
fi

echo "   URL: ${URL}"
curl -sSL "${URL}" -o "${INSTALL_DIR}/buf"
chmod +x "${INSTALL_DIR}/buf"

echo ""
echo "✅ buf zainstalowany pomyślnie w ${INSTALL_DIR}/buf"
echo ""

# Sprawdź czy jest w PATH
if echo "$PATH" | grep -q "${INSTALL_DIR}"; then
    echo "✅ ${INSTALL_DIR} jest już w PATH"
    "${INSTALL_DIR}/buf" --version
else
    echo "⚠️  ${INSTALL_DIR} nie jest w PATH"
    echo ""
    echo "Dodaj do swojego shell config (~/.bashrc lub ~/.zshrc):"
    echo "   export PATH=\"${INSTALL_DIR}:\$PATH\""
    echo ""
    echo "Aby użyć teraz (tymczasowo):"
    echo "   export PATH=\"${INSTALL_DIR}:\$PATH\""
    echo "   buf --version"
    echo ""
    echo "Lub uruchom buf pełną ścieżką:"
    echo "   ${INSTALL_DIR}/buf --version"
    
    # Pokaż wersję
    echo ""
    "${INSTALL_DIR}/buf" --version
fi

echo ""
echo "🎉 Gotowe! Możesz teraz używać buf."
echo ""
echo "Następne kroki:"
echo "  1. export PATH=\"${INSTALL_DIR}:\$PATH\"  # (jeśli potrzeba)"
echo "  2. cd /home/administrator/proto-demo"
echo "  3. make build"
