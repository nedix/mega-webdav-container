import asyncio
import re

from mitmproxy import http

async def requestheaders(flow: http.HTTPFlow):
    if flow.request.method != "PUT":
        return

    filename = flow.request.path.split("/")[-1]

    if filename.startswith("._") or filename == ".DS_Store":
        flow.response = http.Response.make(
            202,
            "Accepted",
            {"Content-Type": "text/plain"}
        )
