import Foundation

public class BaseAPIClient {
	public init() {}
	
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
}
