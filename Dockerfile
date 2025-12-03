FROM python:3.10-slim

# ----- Project name (can be overridden at build/run time) -----
# Build-time argument (optional default)
ARG PROJECT=scraper
# Runtime environment variable
ENV PROJECT=${PROJECT}

WORKDIR /app


# Install dependencies
RUN pip install scrapy scrapy-redis

# Copy basic config files
COPY pyproject.toml scrapy.cfg ./

# Copy whole project (including the Scrapy module dir == $PROJECT)
COPY . .

# Use a shell so that $PROJECT is expanded and concatenated with "spider"
CMD ["sh", "-c", "scrapy crawl ${PROJECT}_s"]
