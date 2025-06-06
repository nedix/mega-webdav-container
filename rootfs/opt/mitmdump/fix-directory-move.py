import asyncio

from mitmproxy import http

async def requestheaders(flow: http.HTTPFlow):
    if (
        flow.request.method == "MOVE"
        and flow.request.headers.get("Destination")[-1] == "/"
    ):
        flow.request.headers["Destination"] = flow.request.headers.get("Destination")[0:-1]
