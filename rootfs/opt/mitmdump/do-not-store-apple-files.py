import asyncio
import re

from mitmproxy import http

async def requestheaders(flow: http.HTTPFlow):
    filename = flow.request.path.split("/")[-1]

    if (
        flow.request.method == "PUT"
        and filename.startswith("._")
        or filename == ".DS_Store"
    ):
        flow.response = http.Response.make(
            202,
            "Accepted",
            {"Content-Type": "text/plain"}
        )
        return
