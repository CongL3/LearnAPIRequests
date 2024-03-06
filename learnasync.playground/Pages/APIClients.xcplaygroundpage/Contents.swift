import Foundation
import Combine

let apiClient = APIClient()

apiClient.fetchData(endpoint: .pokemon(name: "ditto")) { (result: Result<Pokemon, APIError>) in
	switch result {
	case .success(let pokemon):
		print("Name: \(pokemon.name)")
		print("ID: \(pokemon.id)")
		print("Image URL: \(pokemon.sprites.frontDefault)")
	case .failure(let error):
		print("Error: \(error)")
	}
}

let cancellable = apiClient.fetchData(endpoint: .pokemon(name: "ditto"))
	.sink(receiveCompletion: { completion in
		if case let .failure(error) = completion {
			print("Error: \(error)")
		}
	}, receiveValue: { (pokemon: Pokemon) in
		print("Name: \(pokemon.name)")
		print("ID: \(pokemon.id)")
		print("Image URL: \(pokemon.sprites.frontDefault)")
	})

let result: Result<Pokemon, APIError> = await apiClient.fetchData(endpoint: .pokemon(name: "ditto"))
switch result {
case .success(let pokemon):
	print("Name: \(pokemon.name)")
	print("ID: \(pokemon.id)")
	print("Image URL: \(pokemon.sprites.frontDefault)")
case .failure(let error):
	print(".failure: \(error)")
}

do {
	let ditto: Pokemon = try await apiClient.fetchData(endpoint: .pokemon(name: "ditto"))
	print("Name: \(ditto.name)")
	print("ID: \(ditto.id)")
	print("Image URL: \(ditto.sprites.frontDefault)")
} catch {
	print("Error: \(error)")
}

