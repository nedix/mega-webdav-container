import base64
import crypt

from mitmproxy import http

password_hash = ""
username = ""

async def requestheaders(flow: http.HTTPFlow):
    if not password_hash or not username:
        return

    if "authorization" not in flow.request.headers:
        flow.response = http.Response.make(
            401,
            "Unauthorized",
            {"WWW-Authenticate": 'Basic realm="mega-webdav"'}
        )
        return

    try:
        authorization_base64 = flow.request.headers["authorization"].removeprefix("Basic ")
        authorization_base64_bytes = authorization_base64.encode("utf-8")
        authorization_base64_padded = authorization_base64_bytes + b'=' * (- len(authorization_base64_bytes) % 4)
        authorization_base64_decoded = base64.b64decode(authorization_base64_padded).decode("utf-8")

        request_username, request_password = authorization_base64_decoded.split(":")

        request_password_hash = crypt.crypt(request_password, password_hash)

        if request_username != username or request_password_hash != password_hash:
            flow.response = http.Response.make(
                403,
                "Forbidden",
                {"Content-Type": "text/plain"}
            )
            return

    except Exception as e:
        flow.response = http.Response.make(
            400,
            f"Bad Request: {str(e)}".encode(),
            {"Content-Type": "text/plain"}
        )
