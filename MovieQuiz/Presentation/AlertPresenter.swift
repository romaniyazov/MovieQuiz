import UIKit

final class AlertPresenter {
    
    private weak var parent: UIViewController?
    
    init(for parent: UIViewController) {
        self.parent = parent
    }
    
    func present(alert model: AlertModel) {
        guard let parent else { return }
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        parent.present(alert, animated: true, completion: nil)
    }
}
