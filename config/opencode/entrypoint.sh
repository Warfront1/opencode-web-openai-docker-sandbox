#!/bin/sh

CONFIG_FILE="/tmp/opencode.json"

generate_models_json() {
    if [ -z "$CUSTOM_MODELS" ]; then
        echo "{}"
        return
    fi

    MODELS_JSON=""
    for m in $(echo "$CUSTOM_MODELS" | tr ',' ' '); do
        MODELS_JSON="$MODELS_JSON \"$m\": { \"name\": \"$m\" },"
    done

    echo "{ ${MODELS_JSON%,} }"
}

MODELS_JSON=$(generate_models_json)

cat > "$CONFIG_FILE" <<EOF
{
  "provider": {
    "my-openai-compatible-provider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My OpenAI-Compatible Provider",
      "options": {
        "baseURL": "http://nginx-api-gateway/api/v1"
      },
      "models": $MODELS_JSON
    }
  }
}
EOF

exec opencode web --port 4096 --hostname 0.0.0.0
