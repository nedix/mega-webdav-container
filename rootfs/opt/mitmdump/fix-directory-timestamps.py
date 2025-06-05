import asyncio
import re

from mitmproxy import http

async def response(flow: http.HTTPFlow):
    if (
        flow.request.method == "PROPFIND"
        and flow.request.path[-1] == "/"
        and flow.response.content
    ):
        flow.response.content = re.sub(
            rb"<d:creationdate>(.*?)</d:creationdate><d:getlastmodified>Thu, 01 Jan 1970 00:00:00 GMT</d:getlastmodified>",
            rb"<d:creationdate>\1</d:creationdate><d:getlastmodified>\1</d:getlastmodified>",
            flow.response.content
        )
        return
