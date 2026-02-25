# Zmienne
BUF := buf
PROTO_DIR := proto
GEN_DIR := gen
DOCS_DIR := docs
VERSION ?= 1.0.0

.PHONY: all
all: lint generate docs

.PHONY: all-libs
all-libs: build-cpp-lib build-rust-lib build-python-lib build-csharp-lib

# Instalacja buf (jeśli nie jest zainstalowany)
.PHONY: install-buf
install-buf:
	@echo "Instalacja buf..."
	@if which buf > /dev/null 2>&1; then \
		echo "✅ buf już zainstalowany: $$(buf --version)"; \
	else \
		echo "📥 Pobieranie buf..."; \
		mkdir -p ~/.local/bin; \
		curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$$(uname -s)-$$(uname -m)" -o ~/.local/bin/buf; \
		chmod +x ~/.local/bin/buf; \
		echo ""; \
		echo "✅ buf zainstalowany w ~/.local/bin/buf"; \
		echo ""; \
		echo "⚠️  Dodaj do PATH (jeśli jeszcze nie jest):"; \
		echo "   echo 'export PATH=\"\$$HOME/.local/bin:\$$PATH\"' >> ~/.bashrc"; \
		echo "   source ~/.bashrc"; \
		echo ""; \
		echo "Lub uruchom teraz:"; \
		echo "   export PATH=\"\$$HOME/.local/bin:\$$PATH\""; \
		echo "   buf --version"; \
	fi

# Instalacja lokalnych pluginów (protoc, grpc, etc) - dla pracy offline
.PHONY: install-plugins
install-plugins:
	@echo "Instalacja lokalnych pluginów protobuf..."
	@bash scripts/install-local-plugins.sh

# Formatowanie plików proto
.PHONY: format
format:
	@echo "Formatowanie plików proto..."
	@$(BUF) format -w

# Lintowanie plików proto
.PHONY: lint
lint:
	@echo "Lintowanie plików proto..."
	@$(BUF) lint

# Breaking change detection (wymaga poprzedniej wersji w git)
.PHONY: breaking
breaking:
	@echo "Sprawdzanie breaking changes..."
	@$(BUF) breaking --against '.git#branch=main' || echo "Brak poprzedniej wersji lub zmiany breaking"

# Generowanie kodu dla wszystkich języków
.PHONY: generate
generate:
	@echo "Generowanie kodu..."
	@$(BUF) generate

# Generowanie tylko z lokalnymi pluginami (bez internetu)
.PHONY: generate-local
generate-local:
	@echo "Generowanie kodu (lokalne pluginy - protoc)..."
	@bash scripts/generate-local.sh

# Generowanie tylko dla C++
.PHONY: generate-cpp
generate-cpp:
	@echo "Generowanie kodu C++..."
	@mkdir -p $(GEN_DIR)/cpp
	@$(BUF) generate --template buf.gen.cpp.yaml

# Generowanie tylko dla Rust
.PHONY: generate-rust
generate-rust:
	@echo "Generowanie kodu Rust..."
	@mkdir -p $(GEN_DIR)/rust
	@$(BUF) generate --template buf.gen.rust.yaml

# Generowanie tylko dla Python
.PHONY: generate-python
generate-python:
	@echo "Generowanie kodu Python..."
	@mkdir -p $(GEN_DIR)/python
	@$(BUF) generate --template buf.gen.python.yaml

# Generowanie tylko dla C#
.PHONY: generate-csharp
generate-csharp:
	@echo "Generowanie kodu C#..."
	@mkdir -p $(GEN_DIR)/csharp
	@$(BUF) generate --template buf.gen.csharp.yaml

# Generowanie dokumentacji
.PHONY: docs
docs: generate
	@mkdir -p $(DOCS_DIR)
	@echo "Dokumentacja wygenerowana w $(DOCS_DIR)/"
	@ls -la $(DOCS_DIR)/

# Czyszczenie wygenerowanych plików
.PHONY: clean
clean:
	@echo "Czyszczenie wygenerowanych plików..."
	@rm -rf $(GEN_DIR)/cpp/build $(GEN_DIR)/cpp/dist $(GEN_DIR)/cpp/CMakeLists.txt
	@rm -rf $(GEN_DIR)/rust/target
	@rm -rf $(GEN_DIR)/python/dist $(GEN_DIR)/python/build $(GEN_DIR)/python/*.egg-info $(GEN_DIR)/python/proto_demo $(GEN_DIR)/python/pyproject.toml
	@rm -rf $(GEN_DIR)/csharp/bin $(GEN_DIR)/csharp/obj $(GEN_DIR)/csharp/nupkg
	@rm -rf $(GEN_DIR)/cpp/api $(GEN_DIR)/python/api $(GEN_DIR)/csharp/Api
	@rm -rf $(DOCS_DIR)/*
	@echo "Wyczyszczono."

# Czyszczenie kompletne (włącznie z wygenerowanym kodem)
.PHONY: clean-all
clean-all: clean
	@echo "Czyszczenie wszystkich wygenerowanych plików..."
	@rm -rf $(GEN_DIR)/cpp/api $(GEN_DIR)/python/api
	@rm -rf $(GEN_DIR)/rust $(GEN_DIR)/csharp
	@echo "Wyczyszczono wszystko (szablony projektów zachowane w scripts/)."

# Pełna budowa (tylko protobuf)
.PHONY: build
build: clean-all format lint generate docs
	@echo "Budowa protobuf zakończona pomyślnie!"

# Pełna budowa wszystkiego (protobuf + biblioteki)
.PHONY: build-all
build-all: build all-libs
	@echo "Pełna budowa zakończona pomyślnie!"

# Testy - walidacja schematu
.PHONY: test
test: lint
	@echo "Uruchamianie testów..."
	@$(BUF) build -o /dev/null
	@echo "Wszystkie testy przeszły pomyślnie!"

# Eksport do pliku image (do debugowania)
.PHONY: image
image:
	@echo "Eksportowanie image..."
	@$(BUF) build -o image.bin
	@$(BUF) build -o image.json
	@echo "Image zapisany w image.bin i image.json"

# ============================================================================
# BUDOWANIE BIBLIOTEK (3 niezależne artefakty)
# ============================================================================

# Budowanie biblioteki C++
.PHONY: build-cpp-lib
build-cpp-lib: generate-cpp
	@echo "🔨 Budowanie biblioteki C++..."
	@VERSION=$(VERSION) bash scripts/build-cpp.sh

# Budowanie biblioteki Rust
.PHONY: build-rust-lib
build-rust-lib:
	@echo "🔨 Budowanie biblioteki Rust (kompilacja proto przez cargo build.rs)..."
	@VERSION=$(VERSION) bash scripts/build-rust.sh

# Budowanie biblioteki Python
.PHONY: build-python-lib
build-python-lib: generate-python
	@echo "🔨 Budowanie biblioteki Python..."
	@VERSION=$(VERSION) bash scripts/build-python.sh

# Budowanie biblioteki C#
.PHONY: build-csharp-lib
build-csharp-lib:
	@echo "🔨 Budowanie biblioteki C# (kompilacja proto przez Grpc.Tools)..."
	@VERSION=$(VERSION) bash scripts/build-csharp.sh

# ============================================================================
# PUBLIKACJA DO ARTIFACTORY
# ============================================================================

.PHONY: publish-cpp
publish-cpp: build-cpp-lib
	@echo "📤 Publikacja biblioteki C++ do artifactory..."
	@bash scripts/publish-cpp.sh $(VERSION)

.PHONY: publish-rust
publish-rust: build-rust-lib
	@echo "📤 Publikacja biblioteki Rust do artifactory..."
	@bash scripts/publish-rust.sh $(VERSION)

.PHONY: publish-python
publish-python: build-python-lib
	@echo "📤 Publikacja biblioteki Python do artifactory..."
	@bash scripts/publish-python.sh $(VERSION)

.PHONY: publish-csharp
publish-csharp: build-csharp-lib
	@echo "📤 Publikacja biblioteki C# do artifactory..."
	@bash scripts/publish-csharp.sh $(VERSION)

.PHONY: publish-all
publish-all: publish-cpp publish-rust publish-python publish-csharp
	@echo "✅ Wszystkie biblioteki opublikowane!"

# Informacje o projekcie
.PHONY: info
info:
	@echo "=== Informacje o projekcie proto-demo ==="
	@echo "Version: $(VERSION)"
	@echo "Buf version: $$($(BUF) --version)"
	@echo "Proto files:"
	@find $(PROTO_DIR) -name "*.proto" -type f
	@echo ""
	@echo "Języki generowania: C++, Rust, Python (JSON support)"
	@echo "Dokumentacja: HTML, Markdown, OpenAPI"
	@echo ""
	@echo "Biblioteki:"
	@echo "  - C++: gen/cpp/ (shared + static library)"
	@echo "  - Rust: gen/rust/ (crate)"
	@echo "  - Python: gen/python/ (wheel package)"

# Help
.PHONY: help
help:
	@echo "=== Proto Demo - Dostępne komendy ==="
	@echo ""
	@echo "📦 Instalacja i konfiguracja:"
	@echo "  make install-buf          - Instaluje buf CLI"
	@echo "  make install-plugins      - Instaluje lokalne pluginy (protoc, grpc) dla pracy offline"
	@echo ""
	@echo "🔨 Generowanie kodu (protobuf):"
	@echo "  make format               - Formatuje pliki proto"
	@echo "  make lint                 - Uruchamia linter"
	@echo "  make breaking             - Wykrywa breaking changes"
	@echo "  make generate             - Generuje kod dla wszystkich języków (WYMAGA INTERNETU)"
	@echo "  make generate-local       - Generuje kod z lokalnymi pluginami (OFFLINE)"
	@echo "  make generate-cpp         - Generuje kod tylko dla C++"
	@echo "  make generate-rust        - Generuje kod tylko dla Rust"
	@echo "  make generate-python      - Generuje kod tylko dla Python"
	@echo "  make docs                 - Generuje dokumentację"
	@echo ""
	@echo "🏗️  Budowanie bibliotek (3 niezależne artefakty):"
	@echo "  make build-cpp-lib        - Buduje bibliotekę C++ (shared + static)"
	@echo "  make build-rust-lib       - Buduje bibliotekę Rust (crate)"
	@echo "  make build-python-lib     - Buduje bibliotekę Python (wheel)"
	@echo "  make all-libs             - Buduje wszystkie 3 biblioteki"
	@echo ""
	@echo "📤 Publikacja do artifactory:"
	@echo "  make publish-cpp          - Publikuje C++ library"
	@echo "  make publish-rust         - Publikuje Rust crate"
	@echo "  make publish-python       - Publikuje Python wheel"
	@echo "  make publish-all          - Publikuje wszystkie biblioteki"
	@echo ""
	@echo "🧪 Testowanie:"
	@echo "  make test                 - Uruchamia walidację schematu"
	@echo ""
	@echo "🧹 Czyszczenie:"
	@echo "  make clean                - Czyści buildy bibliotek"
	@echo "  make clean-all            - Czyści wszystko (włącznie z generowanym kodem)"
	@echo ""
	@echo "ℹ️  Informacje:"
	@echo "  make info                 - Wyświetla informacje o projekcie"
	@echo "  make image                - Eksportuje buf image"
	@echo ""
	@echo "🚀 Szybkie komendy:"
	@echo "  make build                - Pełna budowa protobuf (format + lint + generate + docs)"
	@echo "  make build-all            - Pełna budowa (protobuf + wszystkie biblioteki)"
	@echo "  make all                  - Domyślna akcja (lint + generate + docs)"
	@echo ""
	@echo "📝 Przykład workflow:"
	@echo "  1. make build             # Generuj kod protobuf"
	@echo "  2. make build-cpp-lib     # Zbuduj bibliotekę C++"
	@echo "  3. make publish-cpp       # Opublikuj do artifactory"
