FROM python:3.12.8-bookworm

# uv をグローバルにインストール
RUN curl -LsSf https://astral.sh/uv/install.sh \
  | env UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 sh

WORKDIR /opt/app

RUN mkdir -p /opt/app
COPY sample-app/pyproject.toml /opt/app

ENV UV_PROJECT_ENVIRONMENT="/opt/.venv"
ENV PATH="/opt/.venv/bin:$PATH"

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync

COPY sample-app /opt/app

CMD ["uv", "run", "uvicorn", "main:app", "--reload", "--port", "8000", "--host", "0.0.0.0"]