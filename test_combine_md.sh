#!/usr/bin/env bash
#
# test_combine_md.sh
#
# Verifies that `combine_md -r` recursively discovers markdown files in
# nested subdirectories, combines them with the correct wiki-style
# headers, and excludes previously generated combined_*.md files
# regardless of which directory they live in.
#
# Usage: ./test_combine_md.sh

set -uo pipefail

SCRIPT="$HOME/bin/combine_md"
pass=0
fail=0

assert_contains() {
    local haystack="$1" needle="$2" desc="$3"
    if grep -qF -- "$needle" <<< "$haystack"; then
        echo "PASS: $desc"
        pass=$((pass + 1))
    else
        echo "FAIL: $desc (expected to find: $needle)"
        fail=$((fail + 1))
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" desc="$3"
    if grep -qF -- "$needle" <<< "$haystack"; then
        echo "FAIL: $desc (did not expect to find: $needle)"
        fail=$((fail + 1))
    else
        echo "PASS: $desc"
        pass=$((pass + 1))
    fi
}

if [ ! -x "$SCRIPT" ] && [ ! -f "$SCRIPT" ]; then
    echo "FAIL: $SCRIPT not found"
    exit 1
fi

workdir=$(mktemp -d)
outdir=$(mktemp -d)
trap 'rm -rf "$workdir" "$outdir"' EXIT

# Set up a nested fixture:
#   root.md
#   sub1/nested.md
#   sub1/sub2/deep.md
#   sub1/combined_20250101_000000.md   (should be excluded, even though nested)
mkdir -p "$workdir/sub1/sub2"
echo "root content" > "$workdir/root.md"
echo "nested content" > "$workdir/sub1/nested.md"
echo "deep content" > "$workdir/sub1/sub2/deep.md"
echo "old combined output" > "$workdir/sub1/combined_20250101_000000.md"

(cd "$workdir" && bash "$SCRIPT" -r -o "$outdir") > "$workdir/.run.log" 2>&1

combined_file=$(find "$outdir" -maxdepth 1 -name 'combined_*.md' | head -n1)

if [ -z "$combined_file" ]; then
    echo "FAIL: no combined output file was created"
    cat "$workdir/.run.log"
    exit 1
fi

output=$(cat "$combined_file")

assert_contains "$output" "[[root]]" "root-level file included"
assert_contains "$output" "[[sub1/nested]]" "first-level nested file included"
assert_contains "$output" "[[sub1/sub2/deep]]" "second-level nested file included"
assert_contains "$output" "root content" "root file content present"
assert_contains "$output" "nested content" "nested file content present"
assert_contains "$output" "deep content" "deep file content present"
assert_not_contains "$output" "old combined output" "pre-existing nested combined_*.md excluded"

echo
echo "Results: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
