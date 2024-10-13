import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightBorder(forCorrect: Bool)
    
    func showActivityIndicator()
    func hideActivityIndicator()
    
    func disableButtons()
    
    func showNetworkError(_: String)
}
