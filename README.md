### Dataset

https://github.com/karolpiczak/ESC-50

### Reference

https://apple.github.io/turicreate/docs/userguide/sound_classifier/

### Code

```swift
import Foundation
import AVFoundation
import SoundAnalysis

final class AudioClassifier: NSObject {

    private let model: MLModel
    private let request: SNClassifySoundRequest
    private var results: [(String, Double)] = []
    private var completion: (String?) -> () = { _ in }

    init?(model: MLModel) {
        guard let request = try? SNClassifySoundRequest(mlModel: model) else { return nil }
        self.model = model
        self.request = request
    }

    func classify(audioFile: URL, completion: @escaping(String?) -> Void) {
        self.completion = completion
        guard let analyzer = try? SNAudioFileAnalyzer(url: audioFile),
              let _ = try? analyzer.add(self.request, withObserver: self) else {
            return
        }
        analyzer.analyze()
    }

}

extension AudioClassifier: SNResultsObserving {

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let results = result as? SNClassificationResult,
              let result = results.classifications.first
        else {
            print("No Result")
            return
        }

        print("Results: \(results)")

        #if DEBUG
        self.results.append((result.identifier, result.confidence))
        #else
        if result.confidence > 0.8 {
            // add the result to an array
            self.results.append((result.identifier, result.confidence))
        }
        #endif
    }

    func requestDidComplete(_ request: SNRequest) {
        self.results.sort {
            return $0.1 > $1.1
        } // sort by confidence level
        guard let result = self.results.first else { return }
        self.completion(result.0)
    }

}

```

```swift
    private var audioClassifier: AudioClassifier? {
        guard let model = try? SoundClassifier(configuration: MLModelConfiguration()).model else { return nil }
        return AudioClassifier(model: model)
    }

    self.audioClassifier?.classify(audioFile: self.audioFilePath, completion: { result in
                    guard let result = result else {
                        print("No Result")
                        return
                    }
                    self.classification = result
                })
```
