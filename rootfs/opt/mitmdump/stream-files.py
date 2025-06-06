import asyncio

from mitmproxy import http

async def responseheaders(flow: http.HTTPFlow):
    if (
        flow.request.method == "GET"
        and not str(flow.response.headers.get("Content-Type")).startswith("text/html")
    ):
        flow.response.stream = True
