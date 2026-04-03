#!/bin/bash
# Ollama GPU Docker 컨테이너 관리 스크립트

CONTAINER_NAME="ollama"
IMAGE="ollama/ollama"
PORT="11434"
VOLUME_GENERAL="$HOME/localLLM/df:/df"
VOLUME_WEIGHT="$HOME/localLLM/ollama:/root/.ollama"

usage() {
    echo "Usage: $0 {start|stop|restart|status|logs|pull}"
    exit 1
}

start() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "[skip] ${CONTAINER_NAME} 이미 실행 중"
        return
    fi

    # 중지된 컨테이너 존재 시 제거
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker rm "${CONTAINER_NAME}"
    fi

    echo "[start] ${CONTAINER_NAME}"
    docker run -d \
        --name "${CONTAINER_NAME}" \
        --gpus all \
        --restart unless-stopped \
        -p "${PORT}:11434" \
        -v "${VOLUME_GENERAL}" \
        -v "${VOLUME_WEIGHT}" \
        "${IMAGE}"
}

stop() {
    echo "[stop] ${CONTAINER_NAME}"
    docker stop "${CONTAINER_NAME}"
}

restart() {
    stop
    start
}

status() {
    docker ps -a --filter "name=^${CONTAINER_NAME}$" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

logs() {
    docker logs -f "${CONTAINER_NAME}"
}

pull() {
    echo "[pull] ${IMAGE}"
    docker pull "${IMAGE}"
}

case "${1}" in
    start)   start   ;;
    stop)    stop    ;;
    restart) restart ;;
    status)  status  ;;
    logs)    logs    ;;
    pull)    pull    ;;
    *)       usage   ;;
esac
