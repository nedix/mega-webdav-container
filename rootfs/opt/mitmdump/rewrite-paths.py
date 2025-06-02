import asyncio
import re

from mitmproxy import http

mega_endpoint = ""
mega_base_path = mega_endpoint.removeprefix("http://127.0.0.1:10000")

async def requestheaders(flow: http.HTTPFlow):
    flow.request.path = f"{mega_base_path}{flow.request.path}"

    if flow.request.method != "MOVE":
        return

    flow.request.headers["destination"] = re.sub(
        rb"http://(.*?):(.*?)/(.*?)",
        fr"http://127.0.0.1:10000{mega_base_path}/\3".encode(),
        str.encode(flow.request.headers["destination"])
    )

async def response(flow: http.HTTPFlow):
    if flow.request.method != "PROPFIND":
        return

    flow.response.content = re.sub(
        fr"<d:href>http://(.*?):(.*?){mega_base_path}/(.*?)</d:href>".encode(),
        rb"<d:href>http://127.0.0.1:10000/\3</d:href>",
        flow.response.content
    )
