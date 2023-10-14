



//struct TriviaQuestion {
//  let category: String
//  let question: String
//  let correctAnswer: String
//  let incorrectAnswers: [String]
//}
import Foundation

struct APIResponse: Decodable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Decodable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

