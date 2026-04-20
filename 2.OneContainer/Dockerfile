FROM ollama/ollama

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV PATH="/root/.local/bin:${PATH}"
ENV ANTHROPIC_BASE_URL=http://127.0.0.1:11434
ENV ANTHROPIC_AUTH_TOKEN=ollama
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates bash vim git netcat-openbsd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN echo "alias cc='claude --dangerously-skip-permissions'" >> /etc/bash.bashrc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
