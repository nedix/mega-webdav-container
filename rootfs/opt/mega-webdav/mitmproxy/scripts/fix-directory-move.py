from mitmproxy import http

def requestheaders(flow: http.HTTPFlow):
    if flow.request.method != "MOVE":
        return

    if flow.request.headers["destination"][-1] != "/":
        return

    flow.request.headers["destination"] = flow.request.headers["destination"][0:-1]
