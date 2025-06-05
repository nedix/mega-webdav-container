import asyncio

from mitmproxy import http

async def requestheaders(flow: http.HTTPFlow):
    if (
        flow.request.method == "MOVE"
        and flow.request.headers["destination"][-1] == "/"
    ):
        flow.request.headers["destination"] = flow.request.headers["destination"][0:-1]
