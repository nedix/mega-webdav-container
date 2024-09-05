import re

from mitmproxy import http

def response(flow: http.HTTPFlow):
    if flow.request.method != "PROPFIND":
        return

    if flow.request.path[-1] != "/":
        return

    if not flow.response.content:
        return

    flow.response.content = re.sub(
        rb"<d:creationdate>(.*?)</d:creationdate><d:getlastmodified>Thu, 01 Jan 1970 00:00:00 GMT</d:getlastmodified>",
        rb"<d:creationdate>\1</d:creationdate><d:getlastmodified>\1</d:getlastmodified>",
        flow.response.content
    )
