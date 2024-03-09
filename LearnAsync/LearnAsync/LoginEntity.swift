//
//  LoginEntity.swift
//  LearnAsync
//
//  Created by Cong Le on 09/03/2024.
//

import Foundation

class LoginEntity {
	let loginClient: LoginProviding
	
	var overlayText: String = ""
	
	init(loginClient: LoginProviding) {
		self.loginClient = loginClient
	}
	
	func login(email: String, password: String) async {
		for await status in await loginClient.login(email: email, password: password) {
			switch status {
			case .notStarted:
				overlayText = "Login not started"
			case .inProgress:
				overlayText = "Login in progress"
			case .success:
				overlayText = "Login successful"
			case .failure:
				overlayText = "Login failed"
			}
			print(overlayText)
		}
	}
}
