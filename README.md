# Proto Demo - Projekt Buf.build

Kompleksowy projekt demonstracyjny wykorzystujący **buf.build** do zarządzania Protocol Buffers z generowaniem kodu dla C++, Rust i Python oraz automatyczną dokumentacją, linterem i testami.

## 📋 Spis treści

- [Funkcje](#-funkcje)
- [Wymagania](#-wymagania)
- [Instalacja](#-instalacja)
- [Struktura projektu](#-struktura-projektu)
- [Użycie](#-użycie)
- [Praca Offline](#-praca-offline)
- [Biblioteki](#-biblioteki)
- [Konfiguracja](#-konfiguracja)
- [Testowanie](#-testowanie)
- [Generowanie kodu](#-generowanie-kodu)

## ✨ Funkcje

- ✅ **Kompilacja protobufów** dla C++, Rust, Python i C#
- ✅ **Transport JSON** - wszystkie języki wspierają JSON serialization
- ✅ **4 niezależne biblioteki** - każda z osobnym buildem i publikacją do artifactory
- ✅ **Automatyczny linter** z najlepszymi praktykami (STANDARD, COMMENTS, UNARY_RPC)
- ✅ **Wykrywanie breaking changes** (breaking change detection)
- ✅ **Automatyczna dokumentacja** (HTML, Markdown, OpenAPI/Swagger)
- ✅ **Type stubs** dla Python (.pyi)
- ✅ **Walidatory** (buf validate)
- ✅ **gRPC** dla wszystkich języków
- ✅ **Streaming** (server, client, bidirectional)
- ✅ **Paginacja** i metadane
- ✅ **Testy automatyczne**
- ✅ **Publikacja do artifactory** (Maven/Cargo/PyPI/NuGet)

## 🔧 Wymagania

- **buf CLI** (>= v1.28.0) - [Instalacja](https://docs.buf.build/installation)
- **make** - do uruchamiania skryptów
- **git** - opcjonalne, dla breaking change detection

### Opcjonalne (do budowania wygenerowanego kodu):
- **C++**: kompilator C++ (g++/clang), protobuf, gRPC
- **Rust**: rustc, cargo
- **Python**: Python 3.7+, grpcio
- **C#**: .NET SDK 6.0+

## 📦 Instalacja

### 1. Instalacja buf CLI

**Automatyczna instalacja (zalecane):**

```bash
make install-buf
# Następnie dodaj do PATH:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Ręczna instalacja:**

```bash
# Użyj skryptu pomocniczego
bash scripts/install-buf.sh

# Lub bezpośrednio
mkdir -p ~/.local/bin
curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$(uname -s)-$(uname -m)" -o ~/.local/bin/buf
chmod +x ~/.local/bin/buf
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Weryfikacja instalacji

```bash
buf --version
```

## 📁 Struktura projektu

```
proto-demo/
├── buf.yaml                    # Główna konfiguracja buf
├── buf.gen.yaml               # Konfiguracja generowania kodu
├── buf.gen.cpp.yaml          # Konfiguracja tylko dla C++
├── buf.gen.rust.yaml         # Konfiguracja tylko dla Rust
├── buf.gen.python.yaml       # Konfiguracja tylko dla Python
├── Makefile                   # Automatyzacja zadań
├── README.md                  # Dokumentacja projektu
│
├── proto/                     # Definicje Protocol Buffers
│   └── api/
│       └── v1/
│           ├── common.proto          # Wspólne typy (metadata, status, błędy)
│           ├── user.proto            # Model użytkownika i Request/Response
│           └── user_service.proto    # Definicja serwisu gRPC
│
├── gen/                       # Wygenerowany kod (gitignore)
│   ├── cpp/                  # Kod C++
│   │   ├── CMakeLists.txt   # CMake config dla budowania biblioteki
│   │   └── build.sh         # Skrypt budowania biblioteki C++
│   ├── rust/                 # Kod Rust
│   │   ├── Cargo.toml       # Cargo config dla crate
│   │   ├── src/lib.rs       # Główny plik biblioteki
│   │   └── build.sh         # Skrypt budowania crate
│   └── python/               # Kod Python + type stubs
│       ├── pyproject.toml   # Python package config
│       ├── proto_demo/      # Package structure
│       └── build.sh         # Skrypt budowania wheel
│
├── docs/                      # Wygenerowana dokumentacja
│   ├── index.html            # Dokumentacja HTML
│   ├── index.md              # Dokumentacja Markdown
│   └── api.swagger.json      # Specyfikacja OpenAPI
│
├── scripts/                   # Skrypty publikacji
│   ├── publish-cpp.sh        # Publikacja C++ do artifactory
│   ├── publish-rust.sh       # Publikacja Rust do cargo registry
│   └── publish-python.sh     # Publikacja Python do PyPI artifactory
│
└── tests/                     # Testy
    └── run_tests.sh          # Skrypt testowy
```

## 🚀 Użycie

### Szybki start

```bash
# Pełna budowa projektu (tylko protobuf)
make build

# Pełna budowa (protobuf + wszystkie biblioteki)
make build-all

# Lub krok po kroku:
make format    # Formatowanie
make lint      # Lintowanie
make generate  # Generowanie kodu protobuf
make docs      # Generowanie dokumentacji
make all-libs  # Budowanie wszystkich 3 bibliotek
```

### Główne komendy

```bash
# Wyświetl dostępne komendy
make help

# Formatuj pliki proto
make format

# Uruchom linter
make lint

# Sprawdź breaking changes (wymaga git)
make breaking

# Generuj kod dla wszystkich języków
make generate

# Generuj kod tylko dla jednego języka
make generate-cpp
make generate-rust
make generate-python

# Zbuduj biblioteki (artefakty do artifactory)
make build-cpp-lib      # C++ shared + static library
make build-rust-lib     # Rust crate
make build-python-lib   # Python wheel

# Publikuj do artifactory
make publish-cpp
make publish-rust
make publish-python
make publish-all        # wszystkie biblioteki

# Uruchom testy
make test

# Wyczyść wygenerowane pliki
make clean

# Informacje o projekcie
make info
```

## ⚙️ Konfiguracja

### buf.yaml - Główna konfiguracja

- **Proto3** jako wersja protokołu
- **Linter**: STANDARD + COMMENTS + UNARY_RPC
- **Breaking change detection**: FILE level
- **Konwencje nazewnictwa**:
  - Enum zero value: `_UNSPECIFIED`
  - Service suffix: `Service`

### buf.gen.yaml - Generowanie kodu z JSON support

#### Pluginy C++:
- `buf.build/protocolbuffers/cpp` - kod protobuf
- `buf.build/grpc/cpp` - gRPC stubs
- `buf.build/community/chrusty-json` - JSON mapping (nlohmann/json)

#### Pluginy Rust:
- `buf.build/community/neoeinstein-prost` - kod protobuf (prost) z **serde derive**
- `buf.build/community/neoeinstein-tonic` - gRPC (tonic)

#### Pluginy Python:
- `buf.build/protocolbuffers/python` - kod protobuf (wbudowane JSON support)
- `buf.build/grpc/python` - gRPC stubs
- `buf.build/protocolbuffers/pyi` - type stubs

#### Dokumentacja:
- `buf.build/bufbuild/doc` - HTML i Markdown
- `buf.build/grpc-ecosystem/openapiv2` - OpenAPI/Swagger

## 🌐 Praca Offline

Projekt działa **całkowicie offline** po jednorazowej konfiguracji.

### Podejście per język:

**C++ i Python:** Używają lokalnych narzędzi `protoc` i `grpc_*_plugin`
```bash
# Instalacja (raz, wymaga internetu)
make install-plugins

# Generowanie (offline)
make generate
```

**Rust:** Używa standardowego `cargo build.rs` z `tonic-build`
```bash
# Pierwszy build pobierze dependencje (wymaga internetu raz)
make build-rust-lib

# Następne buildy działają offline (cargo cache)
```

**Szczegóły:** Zobacz [OFFLINE.md](OFFLINE.md) dla pełnej dokumentacji.

---

## 📦 Biblioteki

Projekt generuje **4 niezależne biblioteki** gotowe do publikacji w artifactory:

### 1. C++ Library (`gen/cpp/`)
- **Format**: shared library (.so) + static library (.a)
- **Pakiety**: .tar.gz, .deb
- **JSON**: google::protobuf::util (wbudowane)
- **Build**: `make build-cpp-lib`
- **Publish**: `make publish-cpp`

### 2. Rust Crate (`gen/rust/`)
- **Format**: .crate package
- **JSON**: serde serialization (derive annotations)
- **Kompilacja proto**: build.rs z tonic-build (offline po pierwszym buildzie)
- **Build**: `make build-rust-lib`
- **Publish**: `make publish-rust`

### 3. Python Wheel (`gen/python/`)
- **Format**: .whl wheel package
- **JSON**: protobuf json_format (wbudowane)
- **Build**: `make build-python-lib`
- **Publish**: `make publish-python`

### 4. C# NuGet Package (`gen/csharp/`)
- **Format**: .nupkg NuGet package + .dll
- **JSON**: Google.Protobuf JsonFormatter (wbudowane)
- **Kompilacja proto**: Grpc.Tools podczas dotnet build (offline po pierwszym buildzie)
- **Build**: `make build-csharp-lib`
- **Publish**: `make publish-csharp`

**Szczegóły:** Zobacz [LIBRARIES.md](LIBRARIES.md) dla pełnej dokumentacji budowania i publikacji bibliotek.

## 🧪 Testowanie

### Uruchomienie testów

```bash
# Automatyczne testy (w tests/run_tests.sh)
make test

# Lub bezpośrednio:
bash tests/run_tests.sh
```

### Co testujemy?

1. ✅ Walidacja struktury projektu
2. ✅ Budowanie protobufów
3. ✅ Lintowanie (zgodność z best practices)
4. ✅ Formatowanie kodu
5. ✅ Generowanie kodu dla wszystkich języków
6. ✅ Generowanie dokumentacji
7. ✅ Breaking changes (jeśli git dostępny)
8. ✅ Walidacja składni wygenerowanego kodu Python

## 🔨 Generowanie kodu

### Wygenerowane pliki

Po uruchomieniu `make generate`:

#### C++ (`gen/cpp/`)
- `api/v1/*.pb.h` - nagłówki
- `api/v1/*.pb.cc` - implementacja
- `api/v1/*.grpc.pb.h` - gRPC nagłówki
- `api/v1/*.grpc.pb.cc` - gRPC implementacja

#### Rust (`gen/rust/`)
- Kod prost/tonic zgodny z ekosystemem Rust

#### Python (`gen/python/`)
- `api/v1/*_pb2.py` - wygenerowane klasy
- `api/v1/*_pb2_grpc.py` - gRPC stubs
- `api/v1/*_pb2.pyi` - type stubs (dla IDE)

### Użycie wygenerowanego kodu

**Uwaga:** Wszystkie języki wspierają **JSON jako transport** dzięki proto3.

#### Python

```python
from proto_demo.api.v1 import user_pb2
from google.protobuf import json_format

# Tworzenie message
user = user_pb2.User(
    username="alice",
    email="alice@example.com"
)

# JSON serialization (wbudowane w protobuf)
json_str = json_format.MessageToJson(user)
user2 = json_format.Parse(json_str, user_pb2.User())
```

#### Rust

```rust
use proto_demo::api::v1::User;
use proto_demo::{to_json, from_json};

let user = User {
    username: "alice".to_string(),
    ..Default::default()
};

// JSON serialization (serde)
let json = to_json(&user)?;
let user2: User = from_json(&json)?;
```

#### C++

```cpp
#include "api/v1/user.pb.h"
#include <nlohmann/json.hpp>

api::v1::User user;
user.set_username("alice");

// JSON serialization (nlohmann/json)
nlohmann::json j = user;
std::string json_str = j.dump();
```

## 📚 Dokumentacja API

Po wygenerowaniu (`make docs`), dokumentacja jest dostępna w:

- **HTML**: `docs/index.html` - przeglądaj w przeglądarce
- **Markdown**: `docs/index.md` - dla dokumentacji w repo
- **OpenAPI**: `docs/api.swagger.json` - import do Swagger UI/Postman

## 🔄 Workflow deweloperski

### Generowanie kodu protobuf

1. **Edytuj pliki `.proto`** w katalogu `proto/api/v1/`
2. **Formatuj**: `make format`
3. **Lintuj**: `make lint`
4. **Testuj**: `make test`
5. **Sprawdź breaking changes**: `make breaking`
6. **Generuj kod**: `make generate`
7. **Dokumentacja**: automatycznie wygenerowana

### Budowanie i publikacja bibliotek

1. **Zbuduj biblioteki**: `VERSION=1.1.0 make all-libs`
2. **Testuj lokalnie** (jednostkowo i integracyjnie)
3. **Opublikuj**: `VERSION=1.1.0 make publish-all`

Szczegóły w [LIBRARIES.md](LIBRARIES.md).

## 📖 Przykładowe API

Projekt zawiera pełny serwis `UserService` z operacjami:

- ✅ `CreateUser` - tworzenie użytkownika
- ✅ `GetUser` - pobieranie użytkownika
- ✅ `UpdateUser` - aktualizacja użytkownika
- ✅ `DeleteUser` - usuwanie użytkownika
- ✅ `ListUsers` - listowanie z paginacją
- ✅ `StreamUsers` - server streaming
- ✅ `BatchCreateUsers` - client streaming
- ✅ `SyncUsers` - bidirectional streaming

## 🛠️ Rozszerzanie projektu

### Dodawanie nowych serwisów

1. Utwórz nowy plik `.proto` w `proto/api/v1/`
2. Zdefiniuj messages i service
3. Uruchom `make format && make lint`
4. Wygeneruj kod: `make generate`

### Dodawanie nowych języków

Edytuj `buf.gen.yaml` i dodaj nowe pluginy z [Buf Schema Registry](https://buf.build/plugins).

## 📝 Licencja

Projekt demonstracyjny - używaj dowolnie.

## 🤝 Wsparcie

- [Dokumentacja Buf](https://docs.buf.build)
- [Buf Plugins](https://buf.build/plugins)
- [Protocol Buffers Guide](https://protobuf.dev)

---

**Stworzone z ❤️ przy użyciu buf.build**
# proto-demo
