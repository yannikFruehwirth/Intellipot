//
//  ContentView.swift
//  Prototyp_IntelliPot_v.0.9
//
//  Created by Yannik Fruehwirth on 10.10.23.
//

import SwiftUI
import Vision

struct ContentView: View {
    @StateObject var appState = AppState()
    
    @State private var isCameraPresented: Bool = false
    @State private var photoCount: Int = 0
    @State private var detectedWords1: [String] = []
    @State private var detectedWords2: [String] = []
    @State private var parsedCSVData: [[String]] = []
    @State private var currentPhotoSession: String = "machine"
    
    var detectedMachineNumber: String { appState.detectedWords1.first ?? "" }
    var detectedCableNumber: String { appState.detectedWords2.first ?? "" }
    var csvData: String = ""
    
    init() {
        print("reading csv (1) ...")
        if let filepath = Bundle.main.path(forResource: "intelliPotData", ofType: "csv") {
            do {
                let csvStringData = try String(contentsOfFile: filepath)
                self.parsedCSVData = parseCSV(csvStringData)
            } catch {
                print("Error loading csv data")
            }
        } else {
            print("test.csv not found")
        }
    }
    
    var body: some View {
        
        VStack{
            Spacer()
            
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack {
                    if appState.photoCount == 2 {
                        SummaryView(appState: appState, detectedWords1: detectedWords1, detectedWords2: detectedWords2, csvData: self.parsedCSVData)
                    } else {
                        Button(action: {
                            appState.isCameraPresented.toggle()

                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .foregroundColor(.black)
                        }
                    }
                }
                
            }.sheet(isPresented: $appState.isCameraPresented) {
                ImagePicker(completionHandler: { image in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString = formatter.string(from: Date())
                    let imageName = "\(dateString).jpg"
                    if let imageUrl = saveImage(image, name: imageName) {
                            print("Image saved at: \(imageUrl)")
                        }
                    processImageForText(image: image) { detectedWords in
                        if appState.photoCount == 0 {
                            detectedWords1 = detectedWords
                            appState.photoCount += 1
                            appState.isCameraPresented = false
                            storeDataInCsv(date: Date(), detectedWords: detectedWords, status: "machine")
                        } else if appState.photoCount == 1 {
                            detectedWords2 = detectedWords
                            appState.photoCount += 1
                            appState.isCameraPresented = false
                            storeDataInCsv(date: Date(), detectedWords: detectedWords, status: "cable")
                        }
                    }
                })
            }
            Text("IntelliPot V.1.0")
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
    }
    
    func processImageForText(image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let detectedWords: [String] = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                completion(detectedWords)
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform request: \(error)")
        }
    }
    
    func parseCSV(_ data: String) -> [[String]] {
        var result: [[String]] = []
        
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            result.append(columns)
        }
        
        return result
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func storeDataInCsv(date: Date, detectedWords: [String], status: String) {
        print(date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        print(dateString)
        let detectedWords = detectedWords
        
        let newEntry = "\(dateString), \(detectedWords), \(status)"
                
        let fileName = "evaluationData.csv"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        print("I will write: \(newEntry) - it is stored here: \(getDocumentsDirectory())")
        
        var output = newEntry
            if let currentContent = try? String(contentsOf: filePath) {
                output = currentContent + "\n" + newEntry
            }
            
            do {
                try output.write(to: filePath, atomically: true, encoding: .utf8)
            } catch {
                print("Error writing to CSV: \(error.localizedDescription)")
            }
        }
    
    func saveImage(_ image: UIImage, name: String) -> URL? {
        let directory = getDocumentsDirectory()
        let imageUrl = directory.appendingPathComponent(name)
        
        do {
            try image.jpegData(compressionQuality: 1.0)?.write(to: imageUrl, options: .atomic)
            return imageUrl
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
