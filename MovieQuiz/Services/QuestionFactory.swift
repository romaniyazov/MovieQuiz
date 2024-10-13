import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(image: "The Godfather",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Dark Knight",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Kill Bill",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Avengers",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Deadpool",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "The Green Knight",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: true),
//        QuizQuestion(image: "Old",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "Tesla",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false),
//        QuizQuestion(image: "Vivarium",
//                     text: "Рейтинг этого фильма больше чем 6?",
//                     correctAnswer: false)
//    ]
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Could not load image by url: \(movie.imageURL)")
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            let rating = Float(movie.rating) ?? 0

            let question = QuizQuestion(
                image: imageData,
                text: "Рейтинг этого фильма больше 7?",
                correctAnswer: rating > 7)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let newMovies):
                    self.movies.append(contentsOf: newMovies.items)
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}

enum QuestionError: LocalizedError {
    case loadImageError
    
    public var failureReason: String? {
        switch self {
        case .loadImageError:
            "Failed to load image"
        }
    }
}
