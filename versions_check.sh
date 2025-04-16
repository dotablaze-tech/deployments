#!/bin/bash

# Base directory for Helm charts
CHARTS_DIR="charts"
ENVS_DIR="envs"

# Function to extract values from YAML files
extract_value() {
    local file=$1
    local key=$2
    grep -E "^[[:space:]]*${key}:[[:space:]]*" "$file" | awk -F': ' '{print $2}' | tr -d '"'
}

# Loop through each chart directory
for chart in $(find "$CHARTS_DIR" -mindepth 1 -maxdepth 1 -type d); do
    chart_name=$(basename "$chart")
    chart_yaml="$chart/Chart.yaml"

    if [[ -f "$chart_yaml" ]]; then
        version=$(extract_value "$chart_yaml" "version")
        app_version=$(extract_value "$chart_yaml" "appVersion")
        echo "Chart: $chart_name"
        echo "  Version: $version"
        echo "  App Version: $app_version"
    fi

    for env_file in "$chart"/values-*.yaml; do
        [[ -f "$env_file" ]] || continue
        env_name=$(basename "$env_file" | sed 's/values-//; s/.yaml//')
        image_tag=$(grep -E "^[[:space:]]*tag:[[:space:]]*" "$env_file" | awk -F': ' '{print $2}' | tr -d '"')
        if [[ -n "$image_tag" ]]; then
            echo "  Environment Override ($env_name): Image Tag: $image_tag"
        fi
    done

    # Check if chart is enabled in environment configs
    enabled_envs=()
    for env_config in "$ENVS_DIR"/*.yaml; do
        [[ -f "$env_config" ]] || continue
        env_name=$(basename "$env_config" | sed 's/.yaml//')
        if grep -q "helmPath: $chart" "$env_config"; then
            enabled_envs+=("$env_name")
        fi
    done

    if [[ ${#enabled_envs[@]} -gt 0 ]]; then
        echo "  Enabled in: ${enabled_envs[*]}"
    fi

    echo ""
done