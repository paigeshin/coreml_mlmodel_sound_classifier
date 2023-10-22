//
//  AudioClassifier.swift
//  SoundClassificationApp
//
//  Created by paige shin on 10/22/23.
//  Copyright © 2023 Mohammad Azam. All rights reserved.
//

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
