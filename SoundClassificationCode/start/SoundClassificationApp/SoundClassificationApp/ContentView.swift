//
//  ContentView.swift
//  SoundClassificationApp
//
//  Created by Mohammad Azam on 3/18/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import AVFoundation
import SoundAnalysis
import CoreML

struct ContentView: View {
    
    private var audioRecorder = AudioRecorder()
    @State private var recording: Bool = false
    @State private var allowed: Bool = false
    @State private var classification: String = ""
    
    private var audioClassifier: AudioClassifier? {
        guard let model = try? SoundClassifier(configuration: MLModelConfiguration()).model else { return nil }
        return AudioClassifier(model: model)
    }
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return (paths.first!)
    }
    
    private var audioFilePath: URL {
        print(self.documentsDirectory.appendingPathComponent("recordedAudio.m4a"))
        return self.documentsDirectory.appendingPathComponent("recordedAudio.m4a")
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text(self.classification)
                .font(.custom("Arial", size: 100))
            
            Spacer()
            
            Button(self.recording ? "Stop Recording" : "Start Recording") {
                
                self.recording = !self.recording
                if self.recording {
                    self.audioRecorder.startRecording(fileURL: self.audioFilePath)
                    
                } else {
                    self.audioRecorder.stopRecording()
                }
                
            }
            .padding()
            .foregroundColor(Color.white)
            .background(self.recording ? Color.red : Color.green)
            .cornerRadius(10)
            
            Spacer()
            
            
            Button("Classify") {
                
                self.audioClassifier?.classify(audioFile: self.audioFilePath, completion: { result in
                    guard let result = result else {
                        print("No Result")
                        return
                    }
                    self.classification = result
                })
                
            }
            .padding()
            .foregroundColor(Color.white)
            .background(Color.gray)
            .cornerRadius(10)
        }
        
        .onAppear {
            self.audioRecorder.requestPermission { (allowed) in
                DispatchQueue.main.async {
                    print(allowed)
                    self.allowed = allowed
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
