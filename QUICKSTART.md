# Quick Start Guide

## Instalacja i pierwsze kroki

### 1. Instalacja buf

**Automatyczna (zalecane):**
```bash
make install-buf
```

To zainstaluje buf w `~/.local/bin/` i poda instrukcje dodania do PATH.

**Dodaj do PATH (raz, na stałe):**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Ręczna instalacja:**
```bash
# Użyj skryptu
bash scripts/install-buf.sh

# Lub ręcznie
mkdir -p ~/.local/bin
curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$(uname -s)-$(uname -m)" -o ~/.local/bin/buf
chmod +x ~/.local/bin/buf
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Weryfikacja instalacji

```bash
buf --version
# Powinno wyświetlić: 1.28.0 lub nowsza wersja
```

### 3. Formatowanie i walidacja

```bash
# Formatuj wszystkie pliki proto
make format

# Sprawdź zgodność z najlepszymi praktykami
make lint
```

### 4. Generowanie kodu

```bash
# Wygeneruj kod dla wszystkich języków (C++, Rust, Python)
make generate
```

Lub dla konkretnego języka:

```bash
make generate-cpp     # tylko C++
make generate-rust    # tylko Rust
make generate-python  # tylko Python
```

### 5. Sprawdzanie wyników

```bash
# Zobacz wygenerowane pliki
ls -R gen/

# Zobacz dokumentację
ls -la docs/
```

### 6. Uruchomienie testów

```bash
make test
```

## Co dalej?

### Edycja plików proto

Wszystkie pliki `.proto` znajdują się w `proto/api/v1/`:

- [common.proto](proto/api/v1/common.proto) - wspólne typy
- [user.proto](proto/api/v1/user.proto) - modele użytkownika
- [user_service.proto](proto/api/v1/user_service.proto) - definicja serwisu

### Przykładowa edycja

1. Otwórz [user.proto](proto/api/v1/user.proto)
2. Dodaj nowe pole do `User`:
   ```protobuf
   // Numer telefonu
   string phone_number = 10;
   ```
3. Sformatuj: `make format`
4. Sprawdź linter: `make lint`
5. Sprawdź breaking changes: `make breaking`
6. Wygeneruj kod: `make generate`

### Przeglądanie dokumentacji

```bash
# Otwórz w przeglądarce (Linux)
xdg-open docs/index.html

# macOS
open docs/index.html

# Windows
start docs/index.html
```

### Użycie wygenerowanego kodu

Zobacz szczegółowe przykłady w [EXAMPLES.md](EXAMPLES.md):

- Python - prosty przykład z grpcio
- C++ - z CMake
- Rust - z tonic

## Przydatne komendy

```bash
# Pełna budowa
make build

# Czyszczenie
make clean

# Informacje o projekcie
make info

# Pomoc
make help
```

## Troubleshooting

### Błąd: "buf: command not found"

Zainstaluj buf przez `make install-buf` lub ręcznie (patrz krok 1).

### Błędy lintowania

```bash
# Zobacz szczegóły błędów
buf lint --error-format=text

# Automatycznie napraw formatowanie
buf format -w
```

### Problemy z generowaniem

```bash
# Sprawdź konfigurację
cat buf.gen.yaml

# Wymuś ponowne generowanie
make clean && make generate
```

### Błędy z pluginami

Pluginy są pobierane automatycznie z Buf Schema Registry (BSR). Jeśli masz problemy:

```bash
# Wyczyść cache
rm -rf ~/.cache/buf

# Spróbuj ponownie
make generate
```

## Następne kroki

1. **Przeczytaj** pełną dokumentację w [README.md](README.md)
2. **Zobacz** przykłady w [EXAMPLES.md](EXAMPLES.md)
3. **Dodaj** własne serwisy w `proto/api/v1/`
4. **Zintegruj** z Twoim projektem

## Przydatne linki

- [Buf Documentation](https://docs.buf.build)
- [Buf Plugins](https://buf.build/plugins)
- [Protocol Buffers Style Guide](https://protobuf.dev/programming-guides/style/)
- [gRPC Documentation](https://grpc.io/docs/)

---

Powodzenia! 🚀
