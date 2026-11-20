"""HTTP application providing deployment information and health status."""

import html
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST = "0.0.0.0"
PORT = 8000
REVISION = os.environ.get("APP_REVISION", "local")

PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CI/CD Pipeline Integration</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #101820;
            color: #eef2f5;
            margin: 0;
            padding: 60px 24px;
        }
        main {
            max-width: 760px;
            margin: auto;
            background: #1b2935;
            padding: 36px;
            border-radius: 12px;
        }
        h1 { color: #ffffff; }
        h2 { color: #a8d5ba; }
        .status {
            color: #71e5a0;
            font-weight: bold;
        }
        .component {
            background: #263746;
            padding: 16px;
            margin: 12px 0;
            border-radius: 6px;
        }
        code {
            color: #a8d5ba;
            overflow-wrap: anywhere;
        }
        a { color: #9ac7ff; }
        footer {
            margin-top: 28px;
            color: #b4c2ce;
        }
    </style>
</head>
<body>
<main>
    <p>CIS4930 | Computing Tools for Workforce</p>
    <h1>CI/CD Pipeline Integration</h1>
    <p class="status">Application operational</p>

    <h2>Deployment information</h2>

    <div class="component">Version control: GitHub</div>
    <div class="component">Build automation: GitHub Actions</div>
    <div class="component">Infrastructure management: Terraform</div>
    <div class="component">Runtime: Docker</div>

    <h2>Application revision</h2>
    <code>__REVISION__</code>

    <p><a href="/health">View application health response</a></p>

    <footer>Developed by Nafis Anwar</footer>
</main>
</body>
</html>
"""


class AppHandler(BaseHTTPRequestHandler):
    """Handle application and health endpoint requests."""

    def send_content(self, status, content_type, body):
        payload = body.encode("utf-8")

        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        path = self.path.split("?", 1)[0]

        if path == "/":
            page = PAGE.replace("__REVISION__", html.escape(REVISION))
            self.send_content(200, "text/html; charset=utf-8", page)

        elif path == "/health":
            response = {
                "status": "ok",
                "service": "cis4930-application",
                "revision": REVISION
            }

            self.send_content(
                200,
                "application/json",
                json.dumps(response)
            )

        else:
            self.send_content(
                404,
                "application/json",
                json.dumps({"error": "Not found"})
            )


if __name__ == "__main__":
    print(f"Application listening on port {PORT}", flush=True)

    server = ThreadingHTTPServer((HOST, PORT), AppHandler)
    server.serve_forever()
