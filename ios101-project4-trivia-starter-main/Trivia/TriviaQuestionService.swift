//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Vasanth Banumurthy on 10/13/23.
//

import Foundation


class TriviaQuestionService 
{
 
    static func fetchTriviaQuestions(completion: @escaping (Result<[TriviaQuestion], Error>) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=10&category=11&difficulty=easy&type=multiple"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle possible error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Handle missing data
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2)))
                return
            }
            
            // Decode JSON
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(APIResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    
    
    
}
