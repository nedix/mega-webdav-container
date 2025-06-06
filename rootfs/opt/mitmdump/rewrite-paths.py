import asyncio
import re

from mitmproxy import http

mega_endpoint = ""
mega_base_path = mega_endpoint.removeprefix("http://127.0.0.1:10000")

async def requestheaders(flow: http.HTTPFlow):
    flow.request.path = f"{mega_base_path}{flow.request.path}"

    if flow.request.method == "MOVE":
        flow.request.headers["Destination"] = re.sub(
            fr'http://(.*?):(.*?)/(.*?)'.encode(),
            fr'http://127.0.0.1:10000{mega_base_path}/\3'.encode(),
            str.encode(flow.request.headers.get("Destination"))
        )
        return

async def response(flow: http.HTTPFlow):
    if (
        flow.request.method == "GET"
        and str(flow.response.headers.get("Content-Type")).startswith("text/html")
    ):
        flow.response.content = re.sub(
            fr'<a href="Cloud Drive/(.*?)">'.encode(),
            fr'<a href="/\1">'.encode(),
            flow.response.content
        )
        return

    if flow.request.method == "PROPFIND":
        flow.response.content = re.sub(
            fr'<d:href>http://(.*?):(.*?){mega_base_path}/(.*?)</d:href>'.encode(),
            fr'<d:href>http://127.0.0.1:10000/\3</d:href>'.encode(),
            flow.response.content
        )
        return
