#!/bin/bash

# Base directory for Helm charts
CHARTS_DIR="charts"
ENVS_DIR="envs"
REPORTS_DIR="reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$REPORTS_DIR/helm_versions_$TIMESTAMP.csv"

# Ensure reports directory exists
mkdir -p "$REPORTS_DIR"

# Function to extract values from YAML files
extract_value() {
    local file=$1
    local key=$2
    grep -E "^[[:space:]]*${key}:[[:space:]]*" "$file" | awk -F': ' '{print $2}' | tr -d '"'
}

# Get list of environments
ENV_NAMES=($(ls "$ENVS_DIR" | sed 's/.yaml//' | tr '[:lower:]' '[:upper:]'))

# Write CSV header
printf "Chart,Version,App Version" > "$OUTPUT_FILE"
for env in "${ENV_NAMES[@]}"; do
    printf ",%s" "$env Environment" >> "$OUTPUT_FILE"
done
printf ",Enabled Environments\n" >> "$OUTPUT_FILE"

# Loop through each chart directory
for chart in $(find "$CHARTS_DIR" -mindepth 1 -maxdepth 1 -type d); do
    chart_name=$(basename "$chart")
    chart_yaml="$chart/Chart.yaml"

    if [[ -f "$chart_yaml" ]]; then
        version=$(extract_value "$chart_yaml" "version")
        app_version=$(extract_value "$chart_yaml" "appVersion")
    else
        continue
    fi

    # Collect environment overrides
    env_overrides=()
    for env in "${ENV_NAMES[@]}"; do
        env_file="$chart/values-$(echo "$env" | tr '[:upper:]' '[:lower:]').yaml"
        if [[ -f "$env_file" ]]; then
            image_tag=$(grep -E "^[[:space:]]*tag:[[:space:]]*" "$env_file" | awk -F': ' '{print $2}' | tr -d '"')
            env_overrides+=("$image_tag")
        else
            env_overrides+=("-")
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

    # Write to CSV
    printf "%s,%s,%s" "$chart_name" "$version" "$app_version" >> "$OUTPUT_FILE"
    for env_override in "${env_overrides[@]}"; do
        printf ",%s" "$env_override" >> "$OUTPUT_FILE"
    done
    printf ",%s\n" "${enabled_envs[*]}" >> "$OUTPUT_FILE"

done

echo "CSV output saved to $OUTPUT_FILE"
