#!/bin/bash
# Wrapper dla Python protobuf plugin (używany przez buf)
exec python3 -m grpc_tools.protoc --python_out "$@"
