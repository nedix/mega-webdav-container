import asyncio

from mitmproxy import http

async def responseheaders(flow: http.HTTPFlow):
    if flow.request.method == "GET":
        flow.response.stream = True
