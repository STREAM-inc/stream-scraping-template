import argparse
import os
from jinja2 import Environment, FileSystemLoader


def main():
    parser = argparse.ArgumentParser(description="Render a Jinja2 template file.")
    parser.add_argument(
        "--project-name",
        default=os.getenv("PROJECT_NAME", "tsukulink"),
        help="Name of the Scrapy project (also available as env PROJECT_NAME)",
    )
    parser.add_argument(
        "--template-dir",
        default=".",
        help="Directory containing templates (default: current dir)",
    )
    parser.add_argument(
        "--template-file",
        default=os.getenv("TEMPLATE_FILE", "scrapy/settings.py.j2"),
        help="Template file path relative to --template-dir "
        "(default: scrapy/settings.py.j2, env: TEMPLATE_FILE)",
    )
    parser.add_argument(
        "--output-path",
        default=os.getenv("OUTPUT_PATH", "settings.py"),
        help="Output path to write rendered file (default: settings.py, env: OUTPUT_PATH)",
    )

    args = parser.parse_args()

    env = Environment(loader=FileSystemLoader(args.template_dir))
    template = env.get_template(args.template_file)

    context = {
        "project_name": args.project_name,
        "user_agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/91.0.4472.124 Safari/537.36"
        ),
        "robotstxt_obey": True,
        "concurrent_requests": 8,
        "concurrent_requests_per_domain": 4,
        "download_delay": 1.0,
        "randomize_download_delay": True,
        "autothrottle_enabled": True,
        "autothrottle_start_delay": 2.0,
        "autothrottle_max_delay": 60.0,
        "autothrottle_target_concurrency": 1.0,
        "autothrottle_debug": False,
        "retry_enabled": True,
        "retry_times": 10,
        "retry_priority_adjust": -1,
        "default_redis_url": "redis://127.0.0.1:6379",
        "scheduler_persist": True,
    }

    rendered = template.render(**context)

    # Ensure output directory exists
    output_dir = os.path.dirname(os.path.abspath(args.output_path))
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    with open(args.output_path, "w", encoding="utf-8") as f:
        f.write(rendered)

    print(
        f"Generated {args.output_path} "
        f"from {os.path.join(args.template_dir, args.template_file)} "
        f"for project {args.project_name}"
    )


if __name__ == "__main__":
    main()
