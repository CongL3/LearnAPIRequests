import Foundation
import Combine
public enum APIError: Error {
	case invalidURL
	case noData
	case decodingError
	case networkError(Error)
}

public enum APIEndpoint {
	case pokemon(name: String)
	
	public var baseURL: URL {
		return URL(string: "https://pokeapi.co/api/v2")!
	}
	
	public var path: String {
		switch self {
		case .pokemon(let name):
			return "/pokemon/\(name.lowercased())"
		}
	}
	
	public var url: URL {
		return baseURL.appendingPathComponent(path)
	}
}

public class APIClient {
	public init() {}
	
	/// _Traditional_ fetch with Result type
	public func fetchData<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (Result<T, APIError>) -> Void) {
		let url = endpoint.url
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(APIError.networkError(error)))
				return
			}
			
			guard let data = data else {
				completion(.failure(APIError.noData))
				return
			}
			
			do {
				let decodedData = try JSONDecoder().decode(T.self, from: data)
				completion(.success(decodedData))
			} catch {
				completion(.failure(APIError.decodingError))
			}
		}.resume()
	}
	
	/// Combine fetch
	public func fetchData<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
		let url = endpoint.url
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.tryMap { data, response in
				guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
					throw APIError.networkError(NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: nil))
				}
				
				return data
			}
			.mapError { error in
				if let apiError = error as? APIError {
					return apiError
				} else {
					return APIError.networkError(error)
				}
			}
			.decode(type: T.self, decoder: JSONDecoder())
			.mapError { _ in APIError.decodingError }
			.eraseToAnyPublisher()
	}
	
	/// Async fetch to get model directly
	public func fetchData<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
		let url = endpoint.url
		do {
			let (data, response) = try await URLSession.shared.data(from: url)
			
			guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
				throw APIError.networkError(NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: nil))
			}
			do {
				let decodedData = try JSONDecoder().decode(T.self, from: data)
				return decodedData
			} catch {
				throw APIError.decodingError
			}
		} catch {
			throw APIError.networkError(error)
		}
	}
	
}

