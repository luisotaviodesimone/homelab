#!/usr/bin/env python3
import crypt
import json
import sys

input = json.load(sys.stdin)
password = input["password"]
hashed = crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512))
print(json.dumps({"hash": hashed}))
