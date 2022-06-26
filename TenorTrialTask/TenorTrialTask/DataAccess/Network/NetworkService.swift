//
//  NetworkService.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import Foundation

protocol NetworkService {
    func fetch<T: Decodable>(type: T.Type, url: URL, completion: @escaping (Result<T, NetworkError>) -> Void)
}

final class DefaultNetworkService: NetworkService {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetch<T>(type: T.Type, url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        session.dataTask(with: url) { [weak self] (data, _, error) in
            guard let self = self else {
                return
            }
            if let error = error {
                completion(.failure(.networkFailure(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.dataNotFound))
                return
            }
            do {
                let decodedResponse = try self.decoder.decode(type, from: data)
                completion(.success(decodedResponse))
            } catch let error {
                completion(.failure(.decodingFailure(description: error.localizedDescription)))
            }
        }
        .resume()
    }
}

enum NetworkError: Error {
    case dataNotFound
    case decodingFailure(description: String)
    case networkFailure(Error)
}
