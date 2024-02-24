protocol APIClientProviding {
  // completion closure style
	func fetchData<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (Result<T, APIError>) -> Void)
  // publisher / combine
  func fetchData<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError>
  // Async 
  func fetchData<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}
