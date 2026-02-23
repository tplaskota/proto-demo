# JSON Transport Examples

Wszystkie biblioteki wspierają JSON jako transport. Poniżej przykłady dla każdego języka.

## Python - JSON Transport

### Instalacja

```bash
pip install proto-demo
# lub z artifactory
pip install proto-demo --index-url https://artifactory.example.com/artifactory/api/pypi/pypi-local/simple
```

### JSON Serialization

```python
from proto_demo.api.v1 import user_pb2, common_pb2
from google.protobuf import json_format
import grpc

# Tworzenie request
request = user_pb2.CreateUserRequest(
    metadata=common_pb2.RequestMetadata(
        request_id="req-001",
        client_id="python-client",
        api_version="v1"
    ),
    username="alice",
    email="alice@example.com",
    first_name="Alice",
    last_name="Smith"
)

# Serializacja do JSON
json_str = json_format.MessageToJson(
    request,
    preserving_proto_field_name=True,
    including_default_value_fields=False
)
print(json_str)

# Deserializacja z JSON
request_from_json = json_format.Parse(
    json_str,
    user_pb2.CreateUserRequest()
)

# HTTP transport z JSON
import requests

response = requests.post(
    "https://api.example.com/v1/users",
    headers={"Content-Type": "application/json"},
    data=json_str
)

# Parse response
response_msg = json_format.Parse(
    response.text,
    user_pb2.CreateUserResponse()
)
```

---

## Rust - JSON Transport (Serde)

### Cargo.toml

```toml
[dependencies]
proto-demo = { version = "1.0.0", registry = "company" }
serde_json = "1.0"
reqwest = { version = "0.11", features = ["json"] }
```

### JSON Serialization

```rust
use proto_demo::api::v1::{CreateUserRequest, RequestMetadata};
use proto_demo::{to_json, from_json};
use serde_json;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Tworzenie request (serde derive jest już dodane przez buf)
    let request = CreateUserRequest {
        metadata: Some(RequestMetadata {
            request_id: "req-001".to_string(),
            client_id: "rust-client".to_string(),
            api_version: "v1".to_string(),
            timestamp: None,
        }),
        username: "alice".to_string(),
        email: "alice@example.com".to_string(),
        first_name: "Alice".to_string(),
        last_name: "Smith".to_string(),
        password: "secret".to_string(),
    };

    // Serializacja do JSON (helper function)
    let json_str = to_json(&request)?;
    println!("JSON: {}", json_str);

    // Lub bezpośrednio przez serde_json
    let json_value = serde_json::to_value(&request)?;
    let json_pretty = serde_json::to_string_pretty(&request)?;

    // Deserializacja z JSON
    let request_from_json: CreateUserRequest = from_json(&json_str)?;

    // HTTP transport z JSON
    let client = reqwest::Client::new();
    let response = client
        .post("https://api.example.com/v1/users")
        .json(&request)  // automatyczna serializacja
        .send()
        .await?;

    let response_json = response.json::<CreateUserResponse>().await?;

    Ok(())
}
```

---

## C++ - JSON Transport (nlohmann/json)

### CMakeLists.txt

```cmake
find_package(proto_demo_cpp REQUIRED)
find_package(nlohmann_json REQUIRED)
find_package(CURL REQUIRED)

target_link_libraries(my_app
    proto_demo::proto_demo_cpp
    nlohmann_json::nlohmann_json
    CURL::libcurl
)
```

### JSON Serialization

```cpp
#include "api/v1/user.pb.h"
#include "api/v1/common.pb.h"
#include <nlohmann/json.hpp>
#include <curl/curl.h>
#include <iostream>
#include <string>

int main() {
    // Tworzenie request
    api::v1::CreateUserRequest request;
    
    auto* metadata = request.mutable_metadata();
    metadata->set_request_id("req-001");
    metadata->set_client_id("cpp-client");
    metadata->set_api_version("v1");
    
    request.set_username("alice");
    request.set_email("alice@example.com");
    request.set_first_name("Alice");
    request.set_last_name("Smith");

    // Serializacja do JSON (przez nlohmann/json)
    nlohmann::json j;
    
    // Ręczna konwersja (lub użyj generated helpers)
    j["metadata"]["request_id"] = request.metadata().request_id();
    j["metadata"]["client_id"] = request.metadata().client_id();
    j["metadata"]["api_version"] = request.metadata().api_version();
    j["username"] = request.username();
    j["email"] = request.email();
    j["first_name"] = request.first_name();
    j["last_name"] = request.last_name();
    
    std::string json_str = j.dump(2);  // pretty print
    std::cout << "JSON: " << json_str << std::endl;

    // HTTP transport z JSON (libcurl)
    CURL* curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.example.com/v1/users");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        
        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        CURLcode res = curl_easy_perform(curl);
        
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }

    // Deserializacja z JSON
    auto j2 = nlohmann::json::parse(json_str);
    
    api::v1::CreateUserRequest request2;
    request2.mutable_metadata()->set_request_id(j2["metadata"]["request_id"]);
    request2.set_username(j2["username"]);
    // ...

    return 0;
}
```

### Alternatywnie: Protobuf JSON Utilities

```cpp
#include <google/protobuf/util/json_util.h>

// Serializacja do JSON (protobuf utils)
std::string json_str;
google::protobuf::util::MessageToJsonString(request, &json_str);

// Deserializacja z JSON
api::v1::CreateUserRequest request2;
google::protobuf::util::JsonStringToMessage(json_str, &request2);
```

---

## REST API Example (wszystkie języki)

### Python Flask Server

```python
from flask import Flask, request, jsonify
from proto_demo.api.v1 import user_pb2
from google.protobuf import json_format

app = Flask(__name__)

@app.route('/v1/users', methods=['POST'])
def create_user():
    # Parse JSON request
    req = json_format.Parse(
        request.get_data(as_text=True),
        user_pb2.CreateUserRequest()
    )
    
    # Process...
    user = user_pb2.User(
        id="user-123",
        username=req.username,
        email=req.email
    )
    
    # Return JSON response
    response = user_pb2.CreateUserResponse(
        status=user_pb2.RESPONSE_STATUS_SUCCESS,
        user=user
    )
    
    return json_format.MessageToJson(response), 200

if __name__ == '__main__':
    app.run()
```

### Rust Axum Server

```rust
use axum::{Json, Router, routing::post};
use proto_demo::api::v1::{CreateUserRequest, CreateUserResponse, User, ResponseStatus};

async fn create_user(
    Json(req): Json<CreateUserRequest>
) -> Json<CreateUserResponse> {
    // Process...
    let user = User {
        id: "user-123".to_string(),
        username: req.username,
        email: req.email,
        ..Default::default()
    };
    
    Json(CreateUserResponse {
        status: ResponseStatus::Success as i32,
        user: Some(user),
        ..Default::default()
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/v1/users", post(create_user));
    
    axum::Server::bind(&"0.0.0.0:3000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

---

## Podsumowanie

| Język | JSON Library | Sposób |
|-------|-------------|--------|
| **Python** | `google.protobuf.json_format` | Wbudowane w protobuf |
| **Rust** | `serde_json` | Derive annotations (automatyczne) |
| **C++** | `nlohmann/json` lub `protobuf/util` | Manual/helpers |

**Wszystkie używają proto3, który doskonale wspiera JSON mapping!** 🎯
