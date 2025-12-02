FROM python:3.10-slim

WORKDIR /app

COPY pyproject.toml .
COPY scrapy.cfg .
COPY acitivityjapan ./acitivityjapan

# Install dependencies
# Assuming requirements are in pyproject.toml, but we might need to extract them or just install directly for simplicity if no build tool is present.
# Since user has pyproject.toml but no obvious poetry/uv in the container context yet, let's just install via pip.
# We'll install scrapy and scrapy-redis directly as per pyproject.toml
RUN pip install scrapy scrapy-redis

CMD ["scrapy", "crawl", "acitivityjapanspider"]
