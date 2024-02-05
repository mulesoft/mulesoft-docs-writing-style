#!/bin/bash

function is_debug {
    [ "$1" == "-d" ]
}

MODE=$1
if is_debug "$MODE"; then
    echo "💬 debug mode activated."
fi

declare -a failed_tests=()

while read file; do
    rule_name=$(basename "$file" .yml)
    rule_name_bold="$(tput bold)$rule_name$(tput sgr0)"
    violation_count=$(vale "test-files/$rule_name.adoc" | grep $rule_name | grep -v .adoc | wc -l | bc)
    expected_count=$(yq e ".${rule_name}" $(dirname "$0")/violation-count-map.yaml)
    if [ "$expected_count" != "null" ]; then
        if is_debug "$MODE"; then
            echo
            echo "----------------------------- $rule_name_bold -----------------------------"
            vale "test-files/$rule_name.adoc"
        fi
        if [ "$violation_count" -eq "$expected_count" ]; then
            echo "✅ $rule_name_bold passes."
        else
            echo "❌ Expected $rule_name_bold to have $expected_count violations, actually has $violation_count violations."
            failed_tests+=("$rule_name")
        fi
    else
        echo "⚠ $rule_name_bold does not have any associated test cases, skipped."
    fi
done < <(find $(dirname "$dir")/MuleSoft -name "*.yml")

if [ ${#failed_tests[@]} -ne 0 ]; then
    echo "😭 The following tests have failed: ${failed_tests[@]}."
    echo 'Please fix. If needed, run `make test-debug` to help troubleshoot.'
    echo ''
    exit 1
else
    echo "🎉 Congratulations, all test cases have passed."
fi

echo "Script complete."
