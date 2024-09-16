import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let userDefaults = UserDefaults.standard

    var gamesCount: Int {
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }

    var bestGame: GameResult? {
        if let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
           let game = try? JSONDecoder().decode(GameResult.self, from: data) {
            return game
        }
        return nil
    }

    var totalAccuracy: Double {
        let totalCorrect = userDefaults.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = userDefaults.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalQuestions) * 100
    }

    func store(result: GameResult) {
        let currentGamesCount = gamesCount
        userDefaults.set(currentGamesCount + 1, forKey: Keys.gamesCount.rawValue)

        let totalCorrect = userDefaults.integer(forKey: Keys.totalCorrect.rawValue) + result.correct
        let totalQuestions = userDefaults.integer(forKey: Keys.totalQuestions.rawValue) + result.total
        userDefaults.set(totalCorrect, forKey: Keys.totalCorrect.rawValue)
        userDefaults.set(totalQuestions, forKey: Keys.totalQuestions.rawValue)

        if let bestGame {
            if result.isBetterThan(bestGame) {
                saveBestGame(result)
            }
        } else {
            saveBestGame(result)
        }
    }

    private func saveBestGame(_ game: GameResult) {
        if let encoded = try? JSONEncoder().encode(game) {
            userDefaults.set(encoded, forKey: Keys.bestGame.rawValue)
        }
    }
}

private enum Keys: String {
    case gamesCount
    case bestGame
    case totalCorrect
    case totalQuestions
}
