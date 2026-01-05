#!/bin/bash

# Docker container status
# Container names from env vars (set in ~/.profile or ~/.bashrc)
DOCKER_APP=${DOCKER_CONTAINER_APP:-"app"}
DOCKER_REDIS=${DOCKER_CONTAINER_REDIS:-"redis"}
DOCKER_PG=${DOCKER_CONTAINER_PG:-"pgsql"}
DOCKER_MAIL=${DOCKER_CONTAINER_MAIL:-"mailpit"}

get_status() {
    local name=$1
    local label=$2
    local status=$(docker ps --filter "name=$name" --format "{{.Status}}" 2>/dev/null)

    if [ -n "$status" ]; then
        if echo "$status" | grep -q "healthy\|Up"; then
            echo "$label %{F#00FF41}●%{F-}"
        else
            echo "$label %{F#FFD700}●%{F-}"
        fi
    else
        echo "$label %{F#FF6347}●%{F-}"
    fi
}

app=$(get_status "$DOCKER_APP" "App")
redis=$(get_status "$DOCKER_REDIS" "Redis")
pg=$(get_status "$DOCKER_PG" "PG")
mail=$(get_status "$DOCKER_MAIL" "Mail")

echo "%{T4}󰡨%{T-} $app $redis $pg $mail"
