import asyncio
import re

from mitmproxy import http

async def requestheaders(flow: http.HTTPFlow):
    filename = flow.request.path.split("/")[-1]

    if (
        flow.request.method == "GET"
        and (filename == ".DS_Store" or filename.startswith("._"))
    ):
        flow.response = http.Response.make(
            404,
            "Not Found",
            {"Content-Type": "text/plain"}
        )
        return

    if (
        flow.request.method == "PUT"
        and (filename == ".DS_Store" or filename.startswith("._"))
    ):
        flow.response = http.Response.make(
            202,
            "Accepted",
            {"Content-Type": "text/plain"}
        )
        return

def response(flow: http.HTTPFlow):
    if (
        flow.request.method == "GET"
        and str(flow.response.headers.get("Content-Type")).startswith("text/html")
        and flow.response.content
    ):
        flow.response.content = re.sub(
            rb'<tr\b[^>]*>(?:(?!</tr>).)*?href="[^"]*/(\._[^"/]*|\.DS_Store)"(?:(?!</tr>).)*?</tr>',
            rb'',
            flow.response.content,
            flags=re.DOTALL
        )
        return

    if (
        flow.request.method == "PROPFIND"
        and str(flow.response.headers.get("Content-Type")).startswith("application/xml")
        and flow.response.content
    ):
        flow.response.content = re.sub(
            rb'<d:response\b[^>]*>(?:(?!</d:response>).)*?<d:href>[^<]*?(/(\._[^/]*)|/\.DS_Store)(?:[^<]*?)</d:href>(?:(?!</d:response>).)*?</d:response>',
            rb'',
            flow.response.content,
            flags=re.DOTALL,
        )
        return
