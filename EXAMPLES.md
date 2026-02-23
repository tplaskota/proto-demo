# Przykłady użycia wygenerowanego kodu

## Python

### Instalacja zależności

```bash
pip install grpcio grpcio-tools protobuf
```

### Przykład klienta

```python
#!/usr/bin/env python3
import grpc
from api.v1 import user_pb2, user_service_pb2_grpc
from google.protobuf.timestamp_pb2 import Timestamp
import time

def create_user_example():
    # Połączenie z serwerem
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = user_service_pb2_grpc.UserServiceStub(channel)
        
        # Tworzenie metadanych
        metadata = user_pb2.RequestMetadata(
            request_id="req-001",
            client_id="python-client",
            api_version="v1"
        )
        metadata.timestamp.GetCurrentTime()
        
        # Tworzenie użytkownika
        request = user_pb2.CreateUserRequest(
            metadata=metadata,
            username="alice",
            email="alice@example.com",
            first_name="Alice",
            last_name="Smith",
            password="secure_password_123"
        )
        
        response = stub.CreateUser(request)
        
        if response.status == user_pb2.RESPONSE_STATUS_SUCCESS:
            print(f"✅ Utworzono użytkownika: {response.user.id}")
            print(f"   Username: {response.user.username}")
            print(f"   Email: {response.user.email}")
        else:
            print(f"❌ Błąd: {response.error.message}")

if __name__ == "__main__":
    create_user_example()
```

## C++

### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.15)
project(proto_demo_cpp)

set(CMAKE_CXX_STANDARD 17)

find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/gen/cpp)

add_executable(client client.cpp)
target_link_libraries(client
    protobuf::libprotobuf
    gRPC::grpc++
)
```

### Przykład klienta (client.cpp)

```cpp
#include <grpcpp/grpcpp.h>
#include "api/v1/user.pb.h"
#include "api/v1/user_service.grpc.pb.h"
#include <iostream>
#include <memory>

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;
using api::v1::UserService;
using api::v1::CreateUserRequest;
using api::v1::CreateUserResponse;

class UserClient {
public:
    UserClient(std::shared_ptr<Channel> channel)
        : stub_(UserService::NewStub(channel)) {}

    void CreateUser(const std::string& username, const std::string& email) {
        CreateUserRequest request;
        
        auto* metadata = request.mutable_metadata();
        metadata->set_request_id("req-cpp-001");
        metadata->set_client_id("cpp-client");
        metadata->set_api_version("v1");
        
        request.set_username(username);
        request.set_email(email);
        request.set_first_name("John");
        request.set_last_name("Doe");
        request.set_password("secure_password");

        CreateUserResponse response;
        ClientContext context;

        Status status = stub_->CreateUser(&context, request, &response);

        if (status.ok()) {
            if (response.status() == api::v1::RESPONSE_STATUS_SUCCESS) {
                std::cout << "✅ User created: " << response.user().id() << std::endl;
                std::cout << "   Username: " << response.user().username() << std::endl;
            } else {
                std::cout << "❌ Error: " << response.error().message() << std::endl;
            }
        } else {
            std::cout << "❌ RPC failed: " << status.error_message() << std::endl;
        }
    }

private:
    std::unique_ptr<UserService::Stub> stub_;
};

int main() {
    UserClient client(
        grpc::CreateChannel("localhost:50051", grpc::InsecureChannelCredentials())
    );
    
    client.CreateUser("bob", "bob@example.com");
    
    return 0;
}
```

## Rust

### Cargo.toml

```toml
[package]
name = "proto_demo_rust"
version = "0.1.0"
edition = "2021"

[dependencies]
tonic = "0.10"
prost = "0.12"
tokio = { version = "1.0", features = ["macros", "rt-multi-thread"] }

[build-dependencies]
tonic-build = "0.10"
```

### Przykład klienta (main.rs)

```rust
use proto::api::v1::user_service_client::UserServiceClient;
use proto::api::v1::{CreateUserRequest, RequestMetadata};

pub mod proto {
    pub mod api {
        pub mod v1 {
            include!("../gen/rust/api.v1.rs");
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = UserServiceClient::connect("http://localhost:50051").await?;

    let request = tonic::Request::new(CreateUserRequest {
        metadata: Some(RequestMetadata {
            request_id: "req-rust-001".to_string(),
            client_id: "rust-client".to_string(),
            api_version: "v1".to_string(),
            timestamp: None,
        }),
        username: "charlie".to_string(),
        email: "charlie@example.com".to_string(),
        first_name: "Charlie".to_string(),
        last_name: "Brown".to_string(),
        password: "secure_password".to_string(),
    });

    let response = client.create_user(request).await?;
    let user_response = response.into_inner();

    println!("✅ User created: {:?}", user_response.user);

    Ok(())
}
```

## Uruchamianie przykładów

### Python
```bash
cd examples/python
python3 client.py
```

### C++
```bash
cd examples/cpp
mkdir build && cd build
cmake ..
make
./client
```

### Rust
```bash
cd examples/rust
cargo run
```
