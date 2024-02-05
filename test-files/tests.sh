#!/bin/sh

is_debug() {
    [ "$1" = "-d" ]
}

MODE=$1
if is_debug "$MODE"; then
    echo "💬 debug mode activated."
fi

failed_tests_file=$(mktemp)

find $(dirname "$dir")/MuleSoft -name "*.yml" | while read file; do
    rule_name=$(basename "$file" .yml)
    rule_name_bold="\033[1m$rule_name\033[0m"
    violation_count=$(vale "test-files/$rule_name.adoc" | grep $rule_name | grep -v .adoc | wc -l |  bc)
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
            printf "$rule_name " >> "$failed_tests_file"
        fi
    else
        echo "⚠ $rule_name_bold does not have any associated test cases, skipped."
    fi
done

failed_tests=$(cat "$failed_tests_file")
echo
if [ -n "$failed_tests" ]; then
    echo "😭 The following tests have failed: \033[1m$failed_tests\033[0m"
    echo 'Please fix them. Run `make test-debug` to help troubleshoot.'
    echo ''
    rm "$failed_tests_file"
    exit 1
else
    echo "🎉 Congratulations, all test cases have passed."
fi

echo "Script complete."