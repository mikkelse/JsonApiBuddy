# JsonApiBuddy

A simple and lightweight http client for JSON APIs.

## Simple use case example:

1. Define a request by conforming to the **Request** protocol.
2. Initialise an instance of **HttpClient** with a given base url.
3. Ask the http client to **perform** the request

The example below uses Swift Concurrency, but the http client also support a completion based API. Swift Concurrency is supported from iOS 13 using continuations under the hood. 

### Define the request

```swift
    /// Define a request to retrieve users.
    struct GetUsersRequest: Request {

        /// Setup  the expected response object. In this case an array of users.
        typealias ResponseObject = [User]

        /// Setup the path for the request. Path components will be appended the base url of the http client.
        let pathComponents = ["users"]

        /// Define request specific models.
        struct User: JsonDecodable {
            let id: Int
            let firstName: String
            let lastName: String
            let email: String
        }
    } 
```

### Setup the http client and perform the request

```swift
        /// Setup base url for and initialize the http client.
        let baseUrl = URL(string: "https://some.api.com")!
        let client = HttpClient(baseUrl: baseUrl)

        /// Ask the http client to perform a specific request.
        let request = GetUsersRequest()
        let users = try await client.perform(request: request)
```
