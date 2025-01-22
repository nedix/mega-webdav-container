#!/usr/bin/env python

import mitmproxy.proxy.server

from mitmproxy.tools.main import mitmdump
from sys import argv

mitmproxy.proxy.server.TCP_TIMEOUT = 60 * 60 * 24

mitmdump(args=argv[1::])
