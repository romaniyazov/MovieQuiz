import Foundation

struct NetworkClient: NetworkRouting {

    private enum NetworkError: Error {
        case codeError
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 3.0

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }

            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
