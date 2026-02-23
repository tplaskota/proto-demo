#!/bin/bash
# Wrapper dla Python gRPC plugin (używany przez buf)
exec python3 -m grpc_tools.protoc --grpc_python_out "$@"
