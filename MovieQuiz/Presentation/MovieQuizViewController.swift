import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!

    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        alertPresenter = AlertPresenter(for: self)

        presenter = MovieQuizPresenter(viewController: self)

        activityIndicator.hidesWhenStopped = true
        showActivityIndicator()
    }
    
    func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func highlightBorder(forCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = forCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let action = { [weak self] in
            guard let self else { return }
            self.presenter.resetGame()
        }
        let alert = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: action)
        alertPresenter?.present(alert: alert)
    }
    
    func showNetworkError(_ description: String) {
        hideActivityIndicator()
        
        let alert = AlertModel(
            title: "Не получилось загрузить вопросы",
            message: description,
            buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self else { return }
                
                presenter.resetGame()
                
                self.showActivityIndicator()
                self.presenter.resetGame()
            }

        alertPresenter?.present(alert: alert)
    }
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    @IBAction private func noButtonPressed(_ sender: Any) {
        presenter.noButtonPressed()
    }
    
    @IBAction private func yesButtonPressed(_ sender: Any) {
        presenter.yesButtonPressed()
    }
}
