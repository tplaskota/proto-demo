# Biblioteki - Build i Publikacja

Projekt generuje **3 niezależne biblioteki** - każda może być zbudowana i opublikowana osobno do artifactory.

## 🎯 Przegląd bibliotek

| Język  | Typ artefaktu | Format | Lokalizacja |
|--------|---------------|--------|-------------|
| **C++** | Shared + Static library | `.tar.gz`, `.deb`, `.rpm` | `gen/cpp/` |
| **Rust** | Crate | `.crate` | `gen/rust/` |
| **Python** | Wheel package | `.whl`, `.tar.gz` | `gen/python/` |

## 📦 Transport: JSON

Wszystkie biblioteki wspierają **JSON jako transport**:

- **C++**: nlohmann/json mapping
- **Rust**: serde JSON serialization (derive annotations)
- **Python**: protobuf `json_format` (wbudowane)

Proto3 jest używane we wszystkich definicjach.

---

## 🔨 Budowanie bibliotek

### Budowanie wszystkich bibliotek

```bash
make all-libs
# lub
make build-all  # pełna budowa (protobuf + wszystkie biblioteki)
```

### Budowanie pojedynczej biblioteki

```bash
# C++ library (shared + static)
make build-cpp-lib

# Rust crate
make build-rust-lib

# Python wheel
make build-python-lib
```

### Z niestandardową wersją

```bash
VERSION=2.1.0 make build-cpp-lib
VERSION=2.1.0 make build-rust-lib
VERSION=2.1.0 make build-python-lib
```

---

## 📤 Publikacja do Artifactory

### Konfiguracja artifactory

Ustaw zmienne środowiskowe:

```bash
# Dla wszystkich
export ARTIFACTORY_URL="https://artifactory.example.com/artifactory"
export ARTIFACTORY_USER="your-username"
export ARTIFACTORY_PASSWORD="your-password"

# Dodatkowo dla C++
export ARTIFACTORY_REPO="libs-release-local"

# Dodatkowo dla Rust
export CARGO_REGISTRY="company"
export CARGO_REGISTRY_URL="https://artifactory.example.com/artifactory/api/cargo/cargo-local"
export CARGO_REGISTRY_TOKEN="your-token"  # opcjonalnie

# Dodatkowo dla Python
export PYPI_URL="https://artifactory.example.com/artifactory/api/pypi/pypi-local"
export PYPI_USERNAME="your-username"
export PYPI_PASSWORD="your-password"
```

### Publikacja wszystkich bibliotek

```bash
make publish-all
```

### Publikacja pojedynczej biblioteki

```bash
make publish-cpp      # C++ do generic/maven artifactory
make publish-rust     # Rust do cargo registry
make publish-python   # Python do PyPI artifactory
```

### Z niestandardową wersją

```bash
VERSION=2.1.0 make publish-cpp
```

---

## 📚 Szczegóły bibliotek

### 1. C++ Library

**Lokalizacja:** `gen/cpp/`

**Generowane artefakty:**
- `libproto_demo_cpp.so` - shared library
- `libproto_demo_cpp.a` - static library
- `proto-demo-cpp-{VERSION}-Linux.tar.gz` - archiwum
- `proto-demo-cpp-{VERSION}.deb` - pakiet Debian
- `proto-demo-cpp-{VERSION}.rpm` - pakiet RPM

**Budowanie:**
```bash
make generate-cpp      # Generuj kod protobuf
make build-cpp-lib     # Zbuduj bibliotekę
```

**Użycie w CMakeLists.txt:**
```cmake
find_package(proto_demo_cpp REQUIRED)
target_link_libraries(my_app proto_demo::proto_demo_cpp)
```

**JSON support:**
```cpp
#include "api/v1/user.pb.h"
#include <nlohmann/json.hpp>

api::v1::User user;
user.set_username("alice");

// To JSON
nlohmann::json j = user;
std::string json_str = j.dump();

// From JSON
auto user2 = j.get<api::v1::User>();
```

**Publikacja:**
```bash
make publish-cpp
# lub ręcznie:
bash scripts/publish-cpp.sh 1.0.0
```

---

### 2. Rust Crate

**Lokalizacja:** `gen/rust/`

**Generowane artefakty:**
- `target/release/libproto_demo.rlib` - biblioteka
- `target/package/proto-demo-{VERSION}.crate` - crate package
- `target/doc/` - dokumentacja

**Kompilacja proto:**
Rust używa `build.rs` z `tonic-build` zamiast buf. Proto są kompilowane automatycznie podczas `cargo build`.

**Budowanie:**
```bash
# Nie trzeba generate - build.rs kompiluje proto automatycznie
make build-rust-lib    # Zbuduj crate (kompiluje proto w build.rs)
```

**Użycie w Cargo.toml:**
```toml
[dependencies]
proto-demo = { version = "1.0.0", registry = "company" }
```

**JSON support (serde):**
```rust
use proto_demo::api::v1::User;
use proto_demo::{to_json, from_json};

let user = User {
    username: "alice".to_string(),
    email: "alice@example.com".to_string(),
    ..Default::default()
};

// To JSON
let json = to_json(&user)?;
println!("{}", json);

// From JSON
let user2: User = from_json(&json)?;
```

**Publikacja:**
```bash
make publish-rust
# lub ręcznie:
bash scripts/publish-rust.sh 1.0.0
```

---

### 3. Python Wheel Package

**Lokalizacja:** `gen/python/`

**Generowane artefakty:**
- `dist/proto_demo-{VERSION}-py3-none-any.whl` - wheel package
- `dist/proto-demo-{VERSION}.tar.gz` - source distribution

**Budowanie:**
```bash
make generate-python      # Generuj kod protobuf
make build-python-lib     # Zbuduj wheel
```

**Instalacja:**
```bash
pip install proto-demo==1.0.0 \
  --index-url https://artifactory.example.com/artifactory/api/pypi/pypi-local/simple
```

**Użycie:**
```python
from proto_demo.api.v1 import user_pb2
from google.protobuf import json_format

# Tworzenie message
user = user_pb2.User(
    username="alice",
    email="alice@example.com"
)

# To JSON
json_str = json_format.MessageToJson(user)
print(json_str)

# From JSON
user2 = json_format.Parse(json_str, user_pb2.User())
```

**Publikacja:**
```bash
make publish-python
# lub ręcznie:
bash scripts/publish-python.sh 1.0.0
```

---

## 🔄 Pełny workflow

### Rozwój i publikacja nowej wersji

```bash
# 1. Edytuj pliki .proto
vim proto/api/v1/user.proto

# 2. Formatuj i waliduj
make format
make lint
make breaking  # sprawdź breaking changes

# 3. Generuj kod dla wszystkich języków
make generate

# 4. Zbuduj wszystkie biblioteki
VERSION=1.1.0 make all-libs

# 5. Testuj lokalnie
# ... testy jednostkowe i integracyjne ...

# 6. Opublikuj wszystkie biblioteki
VERSION=1.1.0 make publish-all
```

### Publikacja tylko jednego języka

```bash
# Tylko Python
make generate-python
VERSION=1.2.0 make build-python-lib
VERSION=1.2.0 make publish-python
```

---

## 📋 Wymagania

### C++
- CMake >= 3.15
- kompilator C++17 (g++ lub clang)
- protobuf-dev
- grpc++
- nlohmann-json

### Rust
- rustc >= 1.70
- cargo

### Python
- Python >= 3.8
- pip
- build
- twine

---

## 🐛 Troubleshooting

### C++ - Brak nlohmann/json

```bash
# Ubuntu/Debian
sudo apt-get install nlohmann-json3-dev

# macOS
brew install nlohmann-json
```

### Rust - Cargo registry error

Sprawdź konfigurację w `~/.cargo/config.toml`:
```toml
[registries.company]
index = "https://artifactory.example.com/artifactory/api/cargo/cargo-local"
```

### Python - Twine upload failed

Sprawdź credentials:
```bash
python3 -m twine upload --repository-url $PYPI_URL \
  --username $PYPI_USERNAME --password $PYPI_PASSWORD dist/*
```

---

## 📖 Dodatkowe zasoby

- [README.md](../README.md) - główna dokumentacja projektu
- [QUICKSTART.md](../QUICKSTART.md) - szybki start
- [EXAMPLES.md](../EXAMPLES.md) - przykłady użycia

---

**Każda biblioteka jest niezależnym artefaktem gotowym do publikacji!** 🚀
