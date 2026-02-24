#!/bin/bash
set -e

echo "📦 Instalacja lokalnych pluginów protobuf..."
echo ""

# Wykryj system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

echo "System: $OS"
echo ""

install_debian_ubuntu() {
    echo "🔧 Instalacja dla Debian/Ubuntu..."
    sudo apt-get update
    sudo apt-get install -y \
        protobuf-compiler \
        libprotobuf-dev \
        protobuf-compiler-grpc \
        libgrpc++-dev \
        python3-grpc-tools \
        python3-protobuf \
        python3-build
    
    # Sprawdź czy grpc_cpp_plugin jest dostępny
    if ! command -v grpc_cpp_plugin &> /dev/null; then
        echo "⚠️  grpc_cpp_plugin nie znaleziony, instaluję z grpc..."
        sudo apt-get install -y grpc-proto libgrpc-dev
    fi
    
    # Sprawdź czy grpc_csharp_plugin jest dostępny
    if ! command -v grpc_csharp_plugin &> /dev/null; then
        echo "ℹ️  grpc_csharp_plugin nie znaleziony w pakietach."
        echo "   Dla C# musisz zainstalować grpc-tools przez NuGet lub pobrać z:"
        echo "   https://packages.grpc.io/ lub zbudować z https://github.com/grpc/grpc"
    fi
}

install_fedora_rhel() {
    echo "🔧 Instalacja dla Fedora/RHEL..."
    sudo dnf install -y \
        protobuf-compiler \
        protobuf-devel \
        grpc-cpp \
        grpc-plugins \
        python3-grpcio-tools \
        python3-protobuf \
        python3-build
}

install_arch() {
    echo "🔧 Instalacja dla Arch Linux..."
    sudo pacman -S --noconfirm \
        protobuf \
        grpc \
        python-grpcio-tools \
        python-protobuf \
        python-build
}

install_macos() {
    echo "🔧 Instalacja dla macOS..."
    brew install protobuf grpc
    pip3 install grpcio-tools protobuf mypy-protobuf build
}

install_dotnet() {
    echo ""
    echo "📦 Instalacja .NET SDK (dla C#)..."
    if command -v dotnet &> /dev/null; then
        echo "✅ dotnet już zainstalowany: $(dotnet --version)"
        return
    fi
    
    case "$OS" in
        ubuntu|debian)
            sudo apt-get install -y dotnet-sdk-8.0
            ;;
        fedora|rhel|centos)
            sudo dnf install -y dotnet-sdk-8.0
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm dotnet-sdk
            ;;
        Darwin|darwin)
            brew install --cask dotnet
            ;;
        *)
            echo "ℹ️  Zainstaluj dotnet SDK ręcznie z: https://dotnet.microsoft.com/"
            ;;
    esac
}

# Instalacja według systemu
case "$OS" in
    ubuntu|debian|pop)
        install_debian_ubuntu
        ;;
    fedora|rhel|centos)
        install_fedora_rhel
        ;;
    arch|manjaro)
        install_arch
        ;;
    Darwin|darwin)
        install_macos
        ;;
    *)
        echo "❌ Nieznany system: $OS"
        echo ""
        echo "Zainstaluj ręcznie:"
        echo "  - protobuf-compiler (protoc)"
        echo "  - grpc++ i pluginy"
        echo "  - python3-grpcio-tools"
        echo "  - dotnet SDK (dla C#)"
        exit 1
        ;;
esac

# Instalacja .NET SDK (opcjonalne, dla C#)
install_dotnet() {
    echo "sam se zainstaluj"
}

echo ""
echo "✅ Instalacja zakończona!"
echo ""
echo "Sprawdzanie zainstalowanych narzędzi..."
echo ""

# Sprawdzenie instalacji
check_tool() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1: $(command -v $1)"
        if [ "$1" = "protoc" ]; then
            $1 --version
        fi
    else
        echo "❌ $1: NIE ZNALEZIONO"
    fi
}

check_tool protoc
check_tool grpc_cpp_plugin
check_tool grpc_python_plugin

# Tworzenie symlinków wymaganych przez buf (protoc_builtin: grpc-cpp/grpc-python)
echo ""
echo "🔗 Tworzenie symlinków dla buf (protoc-gen-grpc-*)..."
mkdir -p ~/.local/bin
if command -v grpc_cpp_plugin &> /dev/null; then
    ln -sf "$(which grpc_cpp_plugin)" ~/.local/bin/protoc-gen-grpc-cpp
    echo "✅ protoc-gen-grpc-cpp -> $(which grpc_cpp_plugin)"
else
    echo "❌ grpc_cpp_plugin nie znaleziony - pomiń symlink"
fi
if command -v grpc_python_plugin &> /dev/null; then
    ln -sf "$(which grpc_python_plugin)" ~/.local/bin/protoc-gen-grpc-python
    echo "✅ protoc-gen-grpc-python -> $(which grpc_python_plugin)"
else
    echo "❌ grpc_python_plugin nie znaleziony - pomiń symlink"
fi
echo "⚠️  Upewnij się, że ~/.local/bin jest na \$PATH:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""

# Sprawdź pluginy Python
if python3 -c "import grpc_tools.protoc" 2>/dev/null; then
    echo "✅ Python grpc_tools: zainstalowane"
else
    echo "❌ Python grpc_tools: NIE ZAINSTALOWANE"
    echo "   Zainstaluj: pip3 install grpcio-tools"
fi

# Python protobuf
if python3 -c "import google.protobuf" 2>/dev/null; then
    echo "✅ Python protobuf: zainstalowane"
else
    echo "❌ Python protobuf: NIE ZAINSTALOWANE"
    echo "   Zainstaluj: pip3 install protobuf"
fi

echo ""
echo "🎉 Gotowe! Możesz teraz używać lokalnych pluginów."
echo ""
echo "Użycie:"
echo "  buf generate --template buf.gen.local.yaml  # Tylko lokalne pluginy"
echo "  make generate                                # Używa buf.gen.yaml"
