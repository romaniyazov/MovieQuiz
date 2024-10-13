import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    private let statisticService: StatisticServiceProtocol = StatisticService()
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func resetGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        requestNextQuestion()
    }
    
    func noButtonPressed() {
        didAnswer(isYes: false)
    }
    
    func yesButtonPressed() {
        didAnswer(isYes: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideActivityIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(result: GameResult(correct: correctAnswers, total: questionsAmount, date: Date()))
            viewController?.show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultMessage(),
                buttonText: "Сыграть ещё раз"
            ))
        } else {
            switchToNextQuestion()
            requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.disableButtons()
        didAnswer(isCorrect: isCorrect)
        
        viewController?.highlightBorder(forCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            showNextQuestionOrResults()
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func requestNextQuestion() {
        viewController?.showActivityIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func resultMessage() -> String {
        var message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        """
        if let bestGame = statisticService.bestGame {
            message += """
            \nРекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        }
        return message
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
