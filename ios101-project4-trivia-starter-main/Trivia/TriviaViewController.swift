

import UIKit

import SwiftSoup

extension String {
    func decodingHTMLEntities() -> String {
        return (try? SwiftSoup.parse(self).text()) ?? self
    }
}

extension UIColor {
    static let vintageGreen = UIColor(red: 0.73, green: 0.88, blue: 0.70, alpha: 1.00) // Light Olive Green
    static let vintageRed = UIColor(red: 0.96, green: 0.52, blue: 0.47, alpha: 1.00)   // Light Coral Red
}



class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //addGradient()
    questionContainerView.layer.cornerRadius = 8.0
      
      setupTriviaGame()
    // TODO: FETCH TRIVIA QUESTIONS HERE
      
//      TriviaQuestionService.fetchTriviaQuestions { [weak self] result in
//              DispatchQueue.main.async {
//                  switch result {
//                  case .success(let questions):
//                      self?.questions = questions
//                      self?.updateQuestion(withQuestionIndex: 0)
//                  case .failure(let error):
//                      self?.handle(error: error)
//                  }
//              }
//          }
  }
    
    private func setupTriviaGame() {
        TriviaQuestionService.fetchTriviaQuestions { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    self?.questions = questions
                    self?.updateQuestion(withQuestionIndex: 0)
                case .failure(let error):
                    self?.handle(error: error)
                }
            }
        }
    }
    
    
    private func handle(error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [unowned self] _ in
            //self.viewDidLoad()
            self.setupTriviaGame()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

  
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        //currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        let question = questions[questionIndex]
        
        
        DispatchQueue.main.async {
            self.currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(self.questions.count)"
            self.questionLabel.text = question.question.decodingHTMLEntities()
            self.categoryLabel.text = question.category
            let answers = ([question.correct_answer] + question.incorrect_answers).shuffled()
            if answers.count > 0 {
                self.answerButton0.setTitle(answers[0].decodingHTMLEntities(), for: .normal)
            }
            if answers.count > 1 {
                self.answerButton1.setTitle(answers[1].decodingHTMLEntities(), for: .normal)
                self.answerButton1.isHidden = false
            }
            if answers.count > 2 {
                self.answerButton2.setTitle(answers[2].decodingHTMLEntities(), for: .normal)
                self.answerButton2.isHidden = false
            }
            if answers.count > 3 {
                self.answerButton3.setTitle(answers[3].decodingHTMLEntities(), for: .normal)
                self.answerButton3.isHidden = false
            }
        }
    }
  
    private func updateToNextQuestion(answer: String, sender: UIButton) {
        
        let originalButtonColor = sender.backgroundColor
        
        if isCorrectAnswer(answer) {
            numCorrectQuestions += 1
            sender.backgroundColor = UIColor.vintageGreen
        }else{
            sender.backgroundColor = UIColor.vintageRed
        }
    
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.backgroundColor = originalButtonColor // or another default color
            self.currQuestionIndex += 1
            guard self.currQuestionIndex < self.questions.count else {
                self.showFinalScore()
                return
            }
            self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
        }
    }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correct_answer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
//      currQuestionIndex = 0
//      numCorrectQuestions = 0
//      updateQuestion(withQuestionIndex: currQuestionIndex)
        self.fetchNewQuestions()
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
    
    private func fetchNewQuestions() {
        TriviaQuestionService.fetchTriviaQuestions { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let newQuestions):
                self.questions = newQuestions
                self.currQuestionIndex = 0
                self.numCorrectQuestions = 0
                self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
            case .failure(let error):
                print("Error fetching new questions: \(error)")
                // Handle the error accordingly
            }
        }

    }

  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.19, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.17, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "", sender: sender)
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "", sender: sender)
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "", sender: sender)
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "", sender: sender)
  }
}

