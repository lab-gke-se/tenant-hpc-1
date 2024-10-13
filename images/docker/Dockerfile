FROM python:3.11-slim-bookworm as builder

WORKDIR /
COPY ./src/worker/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src/worker/main.py .

# CMD python3 ./main.py

FROM debian:bookworm-slim
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder ./ ./

CMD ["python", "main.py"] 