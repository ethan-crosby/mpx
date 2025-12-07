#!/bin/bash

set -e

echo "============================================"
echo "MPX Recipe Finder - Comprehensive Test Suite"
echo "============================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"
flutter pub get

echo ""
echo -e "${YELLOW}Step 2: Generating mock files...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo -e "${YELLOW}Step 3: Running unit and widget tests...${NC}"
flutter test --coverage

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Unit and widget tests passed!${NC}"
else
    echo -e "${RED}✗ Unit and widget tests failed!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 4: Checking for connected devices...${NC}"
DEVICES=$(flutter devices | grep -c "•")

if [ "$DEVICES" -gt 0 ]; then
    echo -e "${GREEN}Found $DEVICES device(s)${NC}"
    echo ""
    read -p "Do you want to run integration tests? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Step 5: Running integration tests...${NC}"
        flutter test integration_test/
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Integration tests passed!${NC}"
        else
            echo -e "${RED}✗ Integration tests failed!${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Skipping integration tests${NC}"
    fi
else
    echo -e "${YELLOW}No devices found. Skipping integration tests.${NC}"
    echo "To run integration tests, connect a device or start an emulator."
fi

echo ""
echo "======================================"
echo -e "${GREEN}All selected tests completed!${NC}"
echo "======================================"
echo ""

if [ -f "coverage/lcov.info" ]; then
    echo "Test coverage report generated at: coverage/lcov.info"
    echo ""
    echo "To view coverage in HTML format, install lcov and run:"
    echo "  genhtml coverage/lcov.info -o coverage/html"
    echo "  open coverage/html/index.html"
fi

echo ""
echo "Test Summary:"
echo "  ✓ Models tested (Ingredient, Recipe, Product)"
echo "  ✓ Services tested (Ingredient, Recipe, UPC)"
echo "  ✓ Repository tested (Spoonacular API)"
echo "  ✓ Storage tested (LocalStore)"
echo "  ✓ ViewModels tested (Ingredient, Recipe)"
echo "  ✓ Widgets tested (Tiles, Views)"
if [[ $REPLY =~ ^[Yy]$ ]] && [ "$DEVICES" -gt 0 ]; then
    echo "  ✓ Integration tests completed"
fi

