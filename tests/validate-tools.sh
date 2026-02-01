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
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "${RED}✗${NC} (unexpected output: $output)"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
        else
            echo -e "${GREEN}✓${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        fi
    else
        echo -e "${RED}✗${NC} (command failed)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
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
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} (file not found)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "📦 Game Development Tools:"
test_command "Godot" "godot --version" "4.5"
test_command "ffmpeg" "ffmpeg -version" "ffmpeg version"

echo ""
echo "🛠️ Base Image Tools (from ai-dev-base):"
test_command "Python" "python3 --version" "Python"
test_command "uv" "uv --version" "uv"
test_command "Bun" "bun --version" ""
test_command "bd (beads)" "bd --version" "bd version"
test_command "Claude CLI" "claude --version || echo 'installed'" "claude"
test_command "GitHub CLI (gh)" "gh --version" "gh version"
test_command "OpenAI Codex CLI" "codex --version || which codex" ""

echo ""
echo "🔧 System Tools:"
test_command "git" "git --version" "git version"
test_command "curl" "curl --version" "curl"
test_command "wget" "wget --version" "GNU Wget"

echo ""
echo "📦 Python Packages:"
test_command "pillow" "python3 -c 'import PIL; print(PIL.__version__)'" ""
test_command "numpy" "python3 -c 'import numpy; print(numpy.__version__)'" ""

echo ""
echo "🔍 Environment:"
test_command "PATH includes local bin" "echo \$PATH" "local/bin"
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
