import Foundation

public class AsyncAPIClient {
	
	public init() {}
		
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
	
	public func fetchData<T: Decodable>(endpoint: APIEndpoint) async -> Result<T, APIError> {
		do {
			let url = endpoint.url
			let (data, response) = try await URLSession.shared.data(from: url)
			
			guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
				return .failure(APIError.networkError(NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: nil)))
			}
			do {
				let decodedData = try JSONDecoder().decode(T.self, from: data)
				return .success(decodedData)
			} catch {
				return .failure(APIError.decodingError)
			}
		} catch {
			return .failure(APIError.networkError(error))
		}
	}
}

