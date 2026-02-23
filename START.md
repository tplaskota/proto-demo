# Start Tutaj! 🚀

## Krok po kroku - pierwsze uruchomienie

### 1️⃣ Zainstaluj buf

```bash
make install-buf
```

Potem dodaj do PATH (skopiuj i wklej):
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
buf --version
```

Powinno pokazać: `1.65.0` (lub nowsza wersja)

### 2️⃣ Wygeneruj kod protobuf

**ONLINE (wymaga internetu - używa buf.build):**
```bash
make build
```

**OFFLINE (bez internetu - używa lokalnego protoc):**
```bash
# Najpierw zainstaluj pluginy (raz, wymaga internetu)
make install-plugins

# Potem możesz pracować offline
make generate-local
```

To wykona:
- ✅ Formatowanie plików proto (buf)
- ✅ Lintowanie (buf)
- ✅ Generowanie kodu dla C++, Python

### 3️⃣ Sprawdź wygenerowane pliki

```bash
ls -la gen/cpp/     # Kod C++
ls -la gen/rust/    # Kod Rust
ls -la gen/python/  # Kod Python
```

### 4️⃣ (Opcjonalnie) Zbuduj biblioteki

```bash
# Wszystkie biblioteki naraz
make all-libs

# Lub pojedynczo:
make build-cpp-lib      # C++ library
make build-rust-lib     # Rust crate
make build-python-lib   # Python wheel
```

---

## ✅ Szybki test

Sprawdź czy wszystko działa:

```bash
make test
```

---

## 📖 Co dalej?

- **Edytuj proto**: Pliki są w `proto/api/v1/`
- **Dokumentacja**: Zobacz [README.md](README.md)
- **Przykłady JSON**: Zobacz [JSON_EXAMPLES.md](JSON_EXAMPLES.md)
- **Biblioteki**: Zobacz [LIBRARIES.md](LIBRARIES.md)

---

## 🆘 Problemy?

### buf nie działa po instalacji

```bash
# Upewnij się że PATH jest ustawiony
export PATH="$HOME/.local/bin:$PATH"
buf --version
```

### Błędy podczas `make build`

```bash
# Sprawdź czy buf jest zainstalowany
which buf

# Jeśli nie, zainstaluj ponownie
make install-buf
```

### Potrzebujesz pomocy?

```bash
make help  # Zobacz wszystkie dostępne komendy
make info  # Zobacz informacje o projekcie
```

---

## 🎯 Najważniejsze komendy

```bash
make build            # Generuj kod protobuf (WYMAGA INTERNETU)
make generate-local   # Generuj kod offline (protoc)
make install-plugins  # Zainstaluj narzędzia dla trybu offline
make all-libs         # Zbuduj wszystkie biblioteki
make test             # Uruchom testy
make clean-all        # Wyczyść wszystko
make help             # Pomoc
```

## 🌐 Praca offline?

Zobacz [OFFLINE.md](OFFLINE.md) - pełna dokumentacja pracy bez internetu.

**Gotowe! Możesz zacząć pracę z protobufami.** 🎉
