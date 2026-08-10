# ═══════════════════════════════════════════════════════════════════
# CP2 — Containerization: Production-ready multi-stage Dockerfile
# ═══════════════════════════════════════════════════════════════════

# ── Stage 1: Builder ──────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /app

# Copy only requirements first for better Docker layer caching
COPY requirements.txt .

# Install dependencies in a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# ── Stage 2: Runtime ──────────────────────────────────────────────
FROM python:3.11-slim AS runtime

# Create a non-root user for security
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid appgroup --shell /bin/bash --create-home appuser

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY app/ ./app/
COPY utils/ ./utils/

# Change to non-root user
USER appuser

# Expose port from environment variable PORT (cloud assigns dynamically)
EXPOSE 8000

# Health check - container orchestration needs this
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:${PORT:-8000}/health', timeout=5).raise_for_status()" || exit 1

# Run with uvicorn, bind to PORT from environment
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
