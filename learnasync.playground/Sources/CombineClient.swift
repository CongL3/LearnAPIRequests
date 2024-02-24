import Foundation
import Combine

public class CombineAPIClient {
	public init() {}
	
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
}
