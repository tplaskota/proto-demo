# Praca Offline - Bez dostępu do internetu

Projekt można używać całkowicie **offline** po odpowiedniej konfiguracji.

## 🌐 Tryby pracy

### 1. **Tryb Online** (domyślny)
Używa zdalnych pluginów z Buf Schema Registry (BSR).

**Zalety:**
- ✅ Automatyczne pobieranie pluginów
- ✅ Zawsze najnowsze wersje
- ✅ Obsługa Rust (prost/tonic)

**Wady:**
- ❌ Wymaga dostępu do internetu
- ❌ Zależność od BSR

**Plik:** `buf.gen.yaml`

### 2. **Tryb Offline** 
Używa lokalnie zainstalowanych pluginów (protoc, grpc).

**Zalety:**
- ✅ Działa bez internetu
- ✅ Pełna kontrola nad wersjami
- ✅ Szybsze działanie (bez pobierania)

**Wady:**
- ❌ Wymaga ręcznej instalacji pluginów
- ❌ Brak wsparcia dla Rust (wymaga cargo i lokalnej kompilacji)

**Plik:** `buf.gen.yaml` (po zmianie) lub `buf.gen.local.yaml`

---

## 🔧 Konfiguracja Offline

### Krok 1: Zainstaluj buf (bez internetu nie trzeba)

Buf jest pojedynczym binarnym plikiem - możesz go skopiować z innego komputera:

```bash
# Na komputerze Z INTERNETEM:
curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$(uname -s)-$(uname -m)" -o buf
chmod +x buf

# Skopiuj plik 'buf' na komputer bez internetu do ~/.local/bin/
```

### Krok 2: Zainstaluj lokalne pluginy

**Automatycznie (wymaga internetu raz):**
```bash
make install-plugins
```

Lub **ręcznie:**

#### Ubuntu/Debian:
```bash
sudo apt-get install -y \
    protobuf-compiler \
    libprotobuf-dev \
    protobuf-compiler-grpc \
    libgrpc++-dev \
    python3-grpc-tools \
    python3-protobuf
```

#### Fedora/RHEL:
```bash
sudo dnf install -y \
    protobuf-compiler \
    protobuf-devel \
    grpc-cpp \
    grpc-plugins \
    python3-grpcio-tools
```

#### macOS:
```bash
brew install protobuf grpc
pip3 install grpcio-tools protobuf
```

### Krok 3: Przełącz na lokalne pluginy

**Opcja A: Edytuj główny plik (już zrobione)**

Plik `buf.gen.yaml` został już zmodyfikowany do używania lokalnych pluginów.

**Opcja B: Używaj osobnego pliku**

```bash
# Generuj z lokalnym szablonem
buf generate --template buf.gen.local.yaml
# lub
make generate-local
```

---

## 📋 Weryfikacja instalacji

Sprawdź czy wszystkie narzędzia są dostępne:

```bash
# Protobuf compiler
protoc --version

# C++ plugin
which protoc-gen-cpp

# gRPC C++ plugin
which grpc_cpp_plugin

# gRPC Python plugin
which grpc_python_plugin

# Python protobuf
python3 -c "import google.protobuf; print('OK')"

# Python grpc tools
python3 -c "import grpc_tools.protoc; print('OK')"
```

---

## 🚀 Użycie Offline

### Generowanie kodu (C++ i Python):

```bash
# Z głównym plikiem (teraz używa lokalnych pluginów)
make generate

# Lub z dedykowanym plikiem
make generate-local
```

### ⚠️ Rust - Specjalne podejście

Rust **nie używa buf** do generowania kodu. Zamiast tego używamy standardowego podejścia cargo z `build.rs`.

**Dlaczego?**
- Pluginy buf dla Rust (prost/tonic) wymagają internetu
- Cargo z `build.rs` to standardowe podejście w ekosystemie Rust
- Działa całkowicie offline po jednorazowym pobraniu dependencji

**Jak to działa:**

Plik `gen/rust/build.rs` kompiluje proto automatycznie podczas `cargo build`:

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let proto_files = [
        "../../proto/api/v1/common.proto",
        "../../proto/api/v1/user.proto",
        "../../proto/api/v1/user_service.proto",
    ];

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .compile_protos(&proto_files, &["../../proto"])?;

    Ok(())
}
```

**Użycie:**
```bash
# Po zmianie proto - wystarczy przebudować:
cd gen/rust
cargo build --release

# Lub użyj Makefile:
make build-rust-lib
```

---

## 📦 Budowanie bibliotek Offline

Po wygenerowaniu kodu, budowanie bibliotek nie wymaga internetu:

```bash
# C++ library
make build-cpp-lib

# Python wheel (może wymagać pip dla zależności - zainstaluj wcześniej)
make build-python-lib

# Rust (wymaga cargo, ale nie internetu jeśli dependencje są zcache'owane)
make build-rust-lib
```

---

## 🔄 Przełączanie między trybami

### Powrót do trybu Online (remote plugins):

1. Przywróć `buf.gen.yaml` z remote plugins
2. Lub użyj git: `git checkout buf.gen.yaml`

### Używaj trybu Offline:

Aktualny `buf.gen.yaml` już używa lokalnych pluginów!

---

## 📝 Podsumowanie

| Funkcja | Online (Remote) | Offline (Local) |
|---------|----------------|-----------------|
| **Generowanie C++** | ✅ | ✅ |
| **Generowanie Python** | ✅ | ✅ |
| **Generowanie Rust** | ✅ | ⚠️ (wymaga build.rs) |
| **Dostęp do internetu** | Wymagany | Nie wymagany |
| **Instalacja** | Automatyczna | Ręczna (raz) |
| **Szybkość** | Wolniejsze (pobieranie) | Szybsze |

---

## 🆘 Troubleshooting

### "protoc: command not found"

Zainstaluj protobuf-compiler:
```bash
# Ubuntu/Debian
sudo apt-get install protobuf-compiler

# macOS
brew install protobuf
```

### "grpc_cpp_plugin: not found"

Zainstaluj grpc pluginy:
```bash
# Ubuntu/Debian
sudo apt-get install protobuf-compiler-grpc

# macOS
brew install grpc
```

### "No module named 'grpc_tools'"

```bash
pip3 install grpcio-tools protobuf
```

### Generowanie kończy się błędem

Sprawdź które pluginy są zainstalowane:
```bash
bash scripts/install-local-plugins.sh
```

---

**Teraz możesz pracować całkowicie offline!** 🎉
