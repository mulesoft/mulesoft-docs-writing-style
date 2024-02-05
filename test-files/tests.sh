#!/bin/bash

function is_debug {
    [ "$1" == "-d" ]
}

MODE=$1
if is_debug "$MODE"; then
    echo "debug mode activated."
fi

find $(dirname "$dir")/MuleSoft -name "*.yml" | while read file; do
    rule_name=$(basename "$file" .yml)
    violation_count=$(vale "test-files/$rule_name.adoc" | grep $rule_name | grep -v .adoc | wc -l |  bc)
    expected_count=$(yq e ".${rule_name}" $(dirname "$0")/violation-count-map.yaml)
    if [ "$expected_count" != "null" ]; then
        if is_debug "$MODE"; then
            vale "test-files/$rule_name.adoc"
        fi
        if [ "$violation_count" -eq "$expected_count" ]; then
            echo "$rule_name passes."
        else
            echo "Error: $rule_name has $violation_count violations, expected $expected_count"
        fi
    # else
    #     echo "$rule_name does not have any associated test cases, skipped."
    fi
done