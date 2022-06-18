//
//  DataService.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import Foundation

protocol DataService {
    func fetch<T: Decodable>(type: T.Type, url: URL, completion: @escaping (Result<T, Error>) -> Void)
}

final class DefaultDataService: DataService {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetch<T>(type: T.Type, url: URL, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        session.dataTask(with: url) { [weak self] (data, _, error) in
            guard let self = self else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(DefaultError.network))
                return
            }
            do {
                let decodedResponse = try self.decoder.decode(type, from: data)
                completion(.success(decodedResponse))
            } catch let error {
                completion(.failure(error))
            }
        }
        .resume()
    }
}

enum DefaultError: Error {
    case network
}
