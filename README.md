---
name: README
description: Ollama + Claude Code Docker 통합 환경 가이드
date: 2026-04-08
---

# 구성

* **ollama 컨테이너**: GPU 지원 Ollama 서버 (qwen3-coder:30b 자동 pull)
* **claude 컨테이너**: Claude Code 실행 환경 (uplexsoft 유저 기본)

# 사용법

## 1. 볼륨 디렉토리 생성 (최초 1회)

```bash
mkdir -p ~/localLLM/df ~/localLLM/ollama_docker
```

## 2. 컨테이너 빌드 & 시작

```bash
docker compose up -d --build
```

## 3. Claude 컨테이너 접속

```bash
docker exec -it claude bash
```

## 4. Claude Code 실행

> **주의**: 처음 한 번은 퍼미션 문제로 실행 안 됨. 2번째부터 실행하면 사용 가능.

```bash
alias cc='claude --dangerously-skip-permissions'
cc   # 1번째: 퍼미션 에러 발생 (정상)
cc   # 2번째: 정상 실행
```

## 5. qwen3 모델 사용 시 주의사항

qwen3 모델은 현재 작업 폴더를 인식 못할 수 있음. 첫 프롬프트에서 작업 디렉토리를 알려줘야 함.

```
현재 작업 폴더는 /home/uplexsoft/test 입니다. 여기서 작업해주세요.
```

# 환경변수

모든 유저(root, uplexsoft)에서 자동 로드:

```bash
ANTHROPIC_BASE_URL=http://ollama:11434
ANTHROPIC_AUTH_TOKEN=ollama
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

# 볼륨 구성

| 호스트 경로                    | 컨테이너 경로            | 용도                     |
| ------------------------------ | ------------------------ | ------------------------ |
| `~/localLLM/df`               | ollama: `/df`            | 공유 데이터 폴더         |
|                                | claude: `/home/uplexsoft/df` | 공유 데이터 폴더     |
| `~/localLLM/ollama_docker`    | `/root/.ollama`          | Docker Ollama 모델 저장  |
| `claude-home` (named volume)  | `/home/uplexsoft`        | Claude 홈 영속화         |

# 네트워크

| 접근 방법       | URL                          | 비고                  |
| ---------------- | ---------------------------- | --------------------- |
| 컨테이너 내부   | `http://ollama:11434`        | Docker 네트워크       |
| 호스트           | `http://localhost:11436`     | Docker Compose 포트   |
| 기존 systemd    | `http://localhost:11434`     | ollama 유저           |
| 기존 nowage     | `http://localhost:11435`     | nowage 유저           |

# 트러블슈팅

## Claude Code 실행 안될 때

```bash
# 환경변수 확인
echo $ANTHROPIC_BASE_URL

# 없으면 수동 로드
source /etc/profile.d/claude.sh

# Ollama 연결 테스트
curl http://ollama:11434/api/tags
```

## CUDA OOM 에러 발생 시

* qwen3-coder:30b (18GB)는 RTX 4070 Ti SUPER (16GB VRAM)에서 CPU/GPU 분할 로드됨
* `OLLAMA_FLASH_ATTENTION=0` 환경변수로 CUDA graph 비활성화하여 해결
* docker-compose.yml의 ollama 서비스에 설정됨

## 참고

* Dockerfile: `Dockerfile.claude`
* Docker Compose: `docker-compose.yml`
* GPU: NVIDIA GPU 전체 사용 (deploy.resources.reservations)
