import SwiftUI
import Foundation

struct SummaryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var appState: AppState
    var detectedWords1: [String]
    var detectedWords2: [String]
    var csvData: [[String]]
    //var detectedMachineNumber: String
    
    
    
    //var detectedMachineNumber: String? {
    //    detectedWords1.first { $0.hasPrefix("+") || $0.hasPrefix("=") } ?? "no valid number recognized"
    //}
    
    //var detectedCableNumber: String? {
    //    detectedWords2.first { $0.hasPrefix("+") || $0.hasPrefix("=") } ?? "no valid number recognized"
    //}
    
    var detectedMachineNumber : String? {
        process(strings: detectedWords1)
    }
    
    var detectedCableNumber : String? {
        process(strings: detectedWords2)
    }
    
    
    @State private var data: [[String]] = []
    @State private var matchInDatabase : Bool = false
    
    //var relevantDataFromH: String? {
    //for row in csvData {
    //if let columnIndex = data.first?.firstIndex(of: "E"), row[columnIndex] == detectedMachineNumber {
    //return row[data.first?.firstIndex(of: "H") ?? 0]
    //}
    //}
    //return nil
    //}
    
    //assign the right values to the variables

    var body: some View {
        NavigationView {
            VStack {
                //Text("Summary Cable Check")
                    //.font(.largeTitle)
                    //.foregroundColor(.white)
                    //.padding()
                Spacer()
                VStack {
                    Text("Detected Machine Number:")
                        .foregroundColor(.gray)
                    Text(String(detectedMachineNumber!).lowercased())
                        .foregroundColor(.white)
                }
                .padding()
                
                VStack {
                    Text("Detected Cable Number:")
                        .foregroundColor(.gray)
                    Text(String(detectedCableNumber!).lowercased())
                        .foregroundColor(.white)
                }
                .padding()
                Spacer()
                //let machineNumberInCSV = csvData[1][4]
                
                //if matchInDatabase == true{
                if checkIfEqual(detectedMachineNumber: detectedMachineNumber ?? "no valid number", detectedCableNumber: detectedCableNumber ?? "no valid number") == true {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .frame(width: 200, height: 200)  // Adjust the size as needed
                        .foregroundColor(.green)
                    Text("Correct Connection")
                        .foregroundColor(.green)
                        .padding()
                    
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.red)
                    // Adjust the size as needed
                    Text("Incorrect Connection")
                        .foregroundColor(.red)
                        .padding()
                }
                Spacer()
                
                if appState.amountOfConnectionsInDb > 1{
                    HStack{
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .frame(width: 25, height: 25)  // Adjust the size as needed
                            .foregroundColor(.yellow)
                        Text("ATTENTION: \(String(appState.amountOfConnectionsInDb)) connection required!")
                            .foregroundColor(.yellow)
                            .padding()
                    }
                }
                
            }
            .navigationBarTitle("Summary", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    // Logic to "exit" or dismiss this view
                    appState.isCameraPresented = false
                    appState.photoCount = 0
                    appState.detectedWords1 = []
                    appState.detectedWords2 = []
                    appState.currentPhotoSession = "machine"
                appState.amountOfConnectionsInDb = 0
                            
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.blue)
                }
            )
            .onAppear {

                print("machine number:", detectedMachineNumber, detectedWords1.first)
                print("cable number:", detectedCableNumber, detectedWords2)
                checkConnection(detectedMachineNumber: String(detectedMachineNumber!), detectedCableNumber: String(detectedCableNumber!))
                //print("test.csv: ", csvData)
                //print("Value [1] csv: ", csvData[1][1]) // Again, assuming row 0 is headers and column 4 is column E
                //print(detectedMachineNumber == csvData[1][1] ? "Machine number matches with the first entry of column E" : "Machine number does not match with the first entry of column E")
            }
            .background(Color.black)
            .cornerRadius(10)
            .padding()
            Spacer()
        }
    }
    
    
    func parseCSV(filename: String) -> [[String]]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("CSV file not found!")
            return nil
        }
        
        do {
            print("reading csv ... ")
            let csvString = try String(contentsOfFile: path)
            var rows: [[String]] = []
            
            let lines: [String] = csvString.components(separatedBy: "\n")
            for line in lines {
                let columns = line.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                rows.append(columns)
            }
            print("reading csv completed")
            
            return rows
            
        } catch let error as NSError {
            print("Failed to read the CSV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    func process(strings: [String]) -> String {
        for str in strings {
            if str.hasPrefix("=") || str.hasPrefix("+") {
                var manipulatedStr = str.lowercased()
                manipulatedStr = manipulatedStr.replacingOccurrences(of: ".", with: "")
                manipulatedStr = manipulatedStr.replacingOccurrences(of: " ", with: "")
                manipulatedStr = manipulatedStr.replacingOccurrences(of: "=", with: "")
                manipulatedStr = manipulatedStr.replacingOccurrences(of: "+", with: "")
                manipulatedStr = manipulatedStr.replacingOccurrences(of: "O", with: "0")
                return manipulatedStr
            }
        }
        return "no valid number" // Return this message if no matching string is found
    }
    
    func checkIfEqual(detectedMachineNumber: String, detectedCableNumber: String) -> Bool {
        // check if detected Number machine & detected Number cable are equal
        print("func checkIfEqual called ...")
        var connectionIsEqual = false
        
        print("detectedMachineNumber: \(detectedMachineNumber)")
        print("detectedCableNumber: \(detectedMachineNumber)")
        
        print("connectionIsEqual: \(detectedMachineNumber.lowercased() == detectedMachineNumber.lowercased())")
        
        if detectedMachineNumber == detectedCableNumber {
            connectionIsEqual = true
        }
        
        print("func checkIfEqual done")
        
        
        return connectionIsEqual
    }
    
    func checkConnection(detectedMachineNumber: String, detectedCableNumber: String) {
        // check if
        
        print(checkIfEqual(detectedMachineNumber: detectedMachineNumber ?? "no valid number", detectedCableNumber: detectedCableNumber ?? "no valid number"))
        print("func checkConnection called")
        if let data = parseCSV(filename: "intelliPotData") {
            self.data = data
            
            // Printing the headers
            //let headers = data[0]
            //print("Headers: \(headers)")
            
            // Printing the data rows
            for rowIndex in 1..<data.count {
                let row = data[rowIndex]
                //print("Row \(rowIndex): \(row)")
                let columnE = row[1].lowercased()
                let columnH = row[2].lowercased()
                if rowIndex == 393 {
                    
                    //print("checking row \(rowIndex), value column E: \(columnE), value column H: \(row[2].lowercased())")
                    //print("detectedCableNumber: \(detectedCableNumber.lowercased()), columnH: \(row[2].lowercased()), equal?: \(String(detectedCableNumber).lowercased() == String(row[2]).lowercased())")
                    //print(String(detectedCableNumber).lowercased(), type(of:String(detectedCableNumber).lowercased()))
                    //print(String(row[2]).lowercased(), type(of:String(row[2]).lowercased()))
                }
                //print("checking row \(rowIndex), value column E: \(columnE), value column H: \(row[2].lowercased())")
                //print("detectedCableNumber: \(detectedCableNumber.lowercased()), columnH: \(row[2].lowercased()), equal?: \(detectedCableNumber.lowercased() == row[2])")
                if columnE == detectedMachineNumber.lowercased() && columnH == detectedCableNumber.lowercased(){
                    print("")
                    print("ITS A MATCH")
                    print("detectedMachineNumber: \(detectedMachineNumber.lowercased()), Value Column E \(columnE)")
                    print("detectedCableNumber: \(detectedCableNumber.lowercased()), Value Column H \(columnH)")
                    print("Row: \(row)")
                    print("")
                    matchInDatabase = true
                    appState.amountOfConnectionsInDb += 1
                }
                else if columnE == detectedMachineNumber.lowercased(){
                    appState.amountOfConnectionsInDb += 1
                }
                //print("Row \(rowIndex) Column E: \(columnE)")
                //print(columnE == detectedMachineNumber)
            }
        }
        
    }
}
