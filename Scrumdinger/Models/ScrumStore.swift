//
//  ScrumStore.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/7/1.
//

import Foundation
import SwiftUI

class ScrumStore: ObservableObject {
    
    @Published var scrums: [DailyScrum] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("scrums.data")
    }
    
    static func load() async throws -> [DailyScrum] {
        try await withCheckedThrowingContinuation({ continution in
            load { result in
                switch result {
                case .failure(let error):
                    continution.resume(throwing: error)
                case .success(let scrums):
                    continution.resume(returning: scrums)
                }
            }
        })
    }
    
    static func load(completion: @escaping (Result<[DailyScrum], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let dailyScrums = try JSONDecoder().decode([DailyScrum].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(dailyScrums))
                }
            } catch  {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    static func save(scrums: [DailyScrum]) async throws -> Int {
        try await withCheckedThrowingContinuation({ continuation in
            save(scrums: scrums) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let scrumsSaved):
                    continuation.resume(returning: scrumsSaved)
                }
            }
        })
    }
    
    
    static func save(scrums: [DailyScrum], completion: @escaping(Result<Int, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(scrums)
            let ourFile = try fileURL()
            try data.write(to: ourFile)
            DispatchQueue.main.async {
                completion(.success(scrums.count))
            }
        } catch  {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
}
