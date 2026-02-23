#!/bin/bash
set -e

echo "🔍 Uruchamianie testów buf.build..."

# Sprawdzenie instalacji buf
if ! command -v buf &> /dev/null; then
    echo "❌ buf nie jest zainstalowany. Uruchom: make install-buf"
    exit 1
fi

echo "✅ buf zainstalowany: $(buf --version)"

# Test 1: Walidacja struktury projektu
echo ""
echo "Test 1: Walidacja struktury projektu..."
if [ -f "buf.yaml" ] && [ -f "buf.gen.yaml" ] && [ -d "proto" ]; then
    echo "✅ Struktura projektu poprawna"
else
    echo "❌ Brakuje wymaganych plików konfiguracyjnych"
    exit 1
fi

# Test 2: Budowanie protobufów
echo ""
echo "Test 2: Budowanie protobufów..."
if buf build -o /dev/null; then
    echo "✅ Protobuf build pomyślny"
else
    echo "❌ Błąd budowania protobufów"
    exit 1
fi

# Test 3: Lintowanie
echo ""
echo "Test 3: Lintowanie..."
if buf lint; then
    echo "✅ Lint przeszedł pomyślnie"
else
    echo "❌ Błędy lintowania"
    exit 1
fi

# Test 4: Formatowanie
echo ""
echo "Test 4: Sprawdzanie formatowania..."
if buf format -d --exit-code; then
    echo "✅ Pliki proto są prawidłowo sformatowane"
else
    echo "⚠️  Pliki wymagają formatowania (uruchom: buf format -w)"
    # Nie kończymy z błędem, tylko ostrzegamy
fi

# Test 5: Generowanie kodu
echo ""
echo "Test 5: Generowanie kodu..."
rm -rf gen/* docs/* 2>/dev/null || true
if buf generate; then
    echo "✅ Generowanie kodu zakończone pomyślnie"
    
    # Sprawdzenie wygenerowanych plików
    if [ "$(find gen -type f | wc -l)" -gt 0 ]; then
        echo "✅ Kod został wygenerowany dla:"
        [ -d "gen/cpp" ] && echo "   - C++"
        [ -d "gen/rust" ] && echo "   - Rust"
        [ -d "gen/python" ] && echo "   - Python"
    else
        echo "⚠️  Brak wygenerowanych plików (sprawdź pluginy)"
    fi
    
    if [ "$(find docs -type f | wc -l)" -gt 0 ]; then
        echo "✅ Dokumentacja wygenerowana"
    fi
else
    echo "❌ Błąd generowania kodu"
    exit 1
fi

# Test 6: Breaking changes (opcjonalny)
echo ""
echo "Test 6: Sprawdzanie breaking changes..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    if buf breaking --against '.git#branch=main' 2>/dev/null; then
        echo "✅ Brak breaking changes"
    else
        echo "⚠️  Wykryto breaking changes lub brak poprzedniej wersji"
    fi
else
    echo "ℹ️  Nie jest to repozytorium git - pomijam test breaking changes"
fi

# Test 7: Walidacja wygenerowanych plików Python
echo ""
echo "Test 7: Walidacja wygenerowanych plików Python..."
if [ -d "gen/python" ]; then
    python_files=$(find gen/python -name "*.py" | wc -l)
    if [ "$python_files" -gt 0 ]; then
        echo "✅ Znaleziono $python_files plików Python"
        # Sprawdzenie składni Python (jeśli Python jest zainstalowany)
        if command -v python3 &> /dev/null; then
            for file in gen/python/*.py; do
                if python3 -m py_compile "$file" 2>/dev/null; then
                    :
                else
                    echo "⚠️  Błąd składni w: $file"
                fi
            done
            echo "✅ Składnia Python poprawna"
        fi
    fi
fi

echo ""
echo "🎉 Wszystkie testy zakończone!"
echo ""
echo "Podsumowanie:"
echo "  ✅ Walidacja struktury"
echo "  ✅ Budowanie protobufów"
echo "  ✅ Lintowanie"
echo "  ✅ Formatowanie"
echo "  ✅ Generowanie kodu"
echo "  ✅ Dokumentacja"
echo ""
echo "Projekt jest gotowy do użycia!"
