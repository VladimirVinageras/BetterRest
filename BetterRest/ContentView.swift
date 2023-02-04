//
//  ContentView.swift
//  BetterRest
//
//  Created by Vladimir Vinageras on 24.09.2022.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTittle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
           Form{
               VStack(alignment: .leading, spacing:  0){
               
               Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please, enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .padding()
                    .labelsHidden()
               }
               
               VStack (alignment: .leading, spacing:  0)
               {
                Text("Desired amount of sleep")
                    .font(.headline)
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...12, step: 0.25)
                   
               }
               
               VStack(alignment: .leading, spacing:  0){
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20 )
               }
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate", action: calculateBedtime)
                }
            .alert(alertTittle, isPresented:   $showingAlert){
                Button("OK"){}
            }message: {
             Text(alertMessage)
            }
            }
        }
        
        
        func calculateBedtime(){
            do{
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                
                let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                
                let prediction = try model.prediction(wake: convertDateToSeconds(component), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                
                let sleepTime = wakeUp - prediction.actualSleep
                
                alertTittle = "Your ideal bedtime is... "
                alertMessage = sleepTime.formatted(date: .omitted, time: Date.FormatStyle.TimeStyle.shortened)
                
            }
            catch{
                alertTittle = "Error"
                alertMessage = "Sorry, there was a problem calculating your bedtime."
            }
            showingAlert = true
    }
    
    func convertDateToSeconds(_ For: DateComponents) -> Double {
        let hour = (For.hour ?? 0) * 3600
        let minute = (For.hour ?? 0) * 60
        
        return Double(hour + minute)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
