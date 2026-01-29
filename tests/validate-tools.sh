#!/bin/bash
# Validate all tools are installed and accessible in the image

set -e

echo "🧪 Validating Godot Game Dev Base Image..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_command() {
    local name=$1
    local command=$2
    local expected_pattern=$3

    echo -n "Testing $name... "

    if output=$($command 2>&1); then
        if [ -n "$expected_pattern" ]; then
            if echo "$output" | grep -q "$expected_pattern"; then
                echo -e "${GREEN}✓${NC} ($output)"
                ((TESTS_PASSED++))
            else
                echo -e "${RED}✗${NC} (unexpected output: $output)"
                ((TESTS_FAILED++))
            fi
        else
            echo -e "${GREEN}✓${NC}"
            ((TESTS_PASSED++))
        fi
    else
        echo -e "${RED}✗${NC} (command failed)"
        ((TESTS_FAILED++))
    fi
}

# Test file existence
test_file() {
    local name=$1
    local file=$2

    echo -n "Testing $name exists... "

    if [ -f "$file" ]; then
        content=$(cat "$file")
        echo -e "${GREEN}✓${NC} ($content)"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} (file not found)"
        ((TESTS_FAILED++))
    fi
}

echo "📦 Core Tools:"
test_command "Godot" "godot --version" "4.5.1"
test_command "Python" "python3 --version" "Python 3.11"
test_command "uv" "uv --version" ""
test_command "Bun" "bun --version" "1.1"
test_command "bd (beads)" "bd --version" ""

echo ""
echo "🛠️ System Tools:"
test_command "git" "git --version" "git version"
test_command "curl" "curl --version" "curl"
test_command "wget" "wget --version" "GNU Wget"
test_command "ffmpeg" "ffmpeg -version" "ffmpeg version"

echo ""
echo "📄 Image Metadata:"
test_file "Image Version" "/opt/image-version"
test_file "Image Manifest" "/opt/image-manifest"

echo ""
echo "🔍 Environment:"
test_command "PATH includes tools" "echo \$PATH" "cargo"
test_command "User is vscode" "whoami" "vscode"
test_command "Shell is bash" "echo \$SHELL" "bash"

echo ""
echo "📊 Results:"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
