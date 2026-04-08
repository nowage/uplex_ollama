#!/bin/bash

# Claude Code + Ollama 환경 테스트 스크립트

set -e

echo "=== Claude Code + Ollama 환경 테스트 ==="
echo ""

# 컨테이너 상태 확인
echo "[1/6] 컨테이너 상태 확인..."
if docker ps | grep -q ollama; then
    echo "✅ Ollama 컨테이너 실행 중"
else
    echo "❌ Ollama 컨테이너 미실행"
    exit 1
fi

if docker ps | grep -q claude; then
    echo "✅ Claude 컨테이너 실행 중"
else
    echo "❌ Claude 컨테이너 미실행"
    exit 1
fi
echo ""

# Ollama 헬스체크
echo "[2/6] Ollama 헬스체크..."
if docker exec ollama curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Ollama API 응답 정상"
else
    echo "❌ Ollama API 응답 없음"
    exit 1
fi
echo ""

# Ollama 모델 확인
echo "[3/6] Ollama 모델 확인..."
if docker exec ollama ollama list | grep -q "qwen3-coder:30b"; then
    echo "✅ qwen3-coder:30b 모델 설치됨"
else
    echo "⚠️  qwen3-coder:30b 모델 미설치 (pull 진행 중일 수 있음)"
fi
echo ""

# Claude 컨테이너에서 Ollama 연결 테스트
echo "[4/6] Claude → Ollama 네트워크 연결 테스트..."
if docker exec claude nc -z ollama 11434; then
    echo "✅ Claude → Ollama 네트워크 연결 성공"
else
    echo "❌ Claude → Ollama 네트워크 연결 실패"
    exit 1
fi
echo ""

# uplexsoft 유저 환경변수 확인
echo "[5/6] uplexsoft 유저 환경 확인..."
UPLEX_BASE_URL=$(docker exec claude bash -c 'source /etc/profile.d/claude.sh && echo $ANTHROPIC_BASE_URL')
if [ "$UPLEX_BASE_URL" = "http://ollama:11434" ]; then
    echo "✅ uplexsoft 환경변수 설정됨"
else
    echo "❌ uplexsoft 환경변수 미설정"
    exit 1
fi

if docker exec claude test -f /home/uplexsoft/.claude/settings.json; then
    echo "✅ uplexsoft settings.json 존재"
else
    echo "❌ uplexsoft settings.json 미존재"
    exit 1
fi
echo ""

# root 유저 환경 확인
echo "[6/6] root 유저 환경 확인..."
ROOT_BASE_URL=$(docker exec -u root claude bash -c 'source /etc/profile.d/claude.sh && echo $ANTHROPIC_BASE_URL')
if [ "$ROOT_BASE_URL" = "http://ollama:11434" ]; then
    echo "✅ root 환경변수 설정됨"
else
    echo "❌ root 환경변수 미설정"
    exit 1
fi

if docker exec -u root claude test -f /root/.claude/settings.json; then
    echo "✅ root settings.json 존재"
else
    echo "❌ root settings.json 미존재"
    exit 1
fi
echo ""

# 최종 결과
echo "=== 테스트 완료 ==="
echo ""
echo "✅ 모든 테스트 통과!"
echo ""
echo "사용법:"
echo "  - uplexsoft 유저: docker exec -it claude bash"
echo "  - root 유저:       docker exec -it -u root claude bash"
echo "  - Claude Code:     cc"
echo ""
