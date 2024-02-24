## Comparing the differences in API request styles for Swift / iOS

Implementation of various styles of API requests

```swift
protocol APIClientProviding {
/// closure with nilable model / error
func fetchData<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (T?, APIError?) -> Void)

/// closure with Swift Result type
func fetchData<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (Result<T, APIError>) -> Void)

/// combine publisher with Swift Result type
func fetchData<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError>

/// asyc with Swift Result type
func fetchData<T: Decodable>(endpoint: APIEndpoint) async -> Result<T, APIError>

/// asyc directly to the model
func fetchData<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}
```
