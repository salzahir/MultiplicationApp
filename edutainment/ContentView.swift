//
//  ContentView.swift
//  edutainment
//
//  Created by Salman Z on 12/20/24.
//

import SwiftUI

struct Question {
    var id = UUID() // Unique identifier for each question
    var questionText: String
    var correctAnswer: Int
}

// View for setting up Game
struct GameSetupView: View {
    
    @Binding var maxMultiplier: Int
    @Binding var choice: Int
    var questionChoices: [Int]
    
    var body: some View {
        VStack{
            Section("Practice Choices"){
                Stepper("Max Multiplier is \(maxMultiplier)", value: $maxMultiplier, in: 2...12)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .shadow(radius: 5)
                             
                Picker("Choose Number of Questions", selection: $choice) {
                    ForEach(questionChoices, id: \.self){ number in
                        Text("\(number)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
                .background(Color.yellow)
                .cornerRadius(10)
                .shadow(radius: 5)
                
            }
            .padding()
        }
    }
}

struct ScoreTitle: View {
    @Binding var highScore: Int
    @Binding var questions: Int
    @Binding var index: Int
    @Binding var correctAnswers: Int
    @Binding var skips: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("Current High Score is \(highScore)")
            Text("Current Score is \(correctAnswers) / \(questions)")
            Text("Skips left: \(skips)")
            Text("\(questions - index) questions left")
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }
}

// Enscapulated MainView logic
struct MainGameView: View {
    
    @Binding var userInput: String
    @Binding var index: Int
    @Binding var totalQuestions: Int
    @Binding var highScore: Int
    @Binding var correctAnswers: Int
    @Binding var questionsArr: [Question]
    @Binding var gameState: GameState
    @Binding var skips: Int
    var processAnswer: (Bool) -> Void
    var playAgain: () -> Void
    
    var body: some View {
        VStack{
            if index < totalQuestions && gameState == .inProgress {
                
                ScoreTitle(
                    highScore: $highScore,
                    questions: $totalQuestions,
                    index: $index,
                    correctAnswers: $correctAnswers,
                    skips: $skips
                )
                .padding()
                
                Text("Question \(index+1)")
                Text("\(questionsArr[index].questionText)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                // Answer Input
                HStack{
                    TextField("What is your answer?", text: $userInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                
                // Buttons
                HStack{
                    Button("Check Answer"){
                        processAnswer(false)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Button("Skip") {
                        processAnswer(true)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Button("Restart"){
                        playAgain()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                  
                }
            }
            
        }
    }
}

enum GameState {
    case notStarted
    case inProgress
    case finished
}

struct ContentView: View {
    @State var maxMultiplier = 2
    @State var questionChoices = [5, 10, 15, 20, 25, 30]
    @State var choice = 5
    @State var totalQuestions = 0
    @State var correctAnswers = 0
    @State var index = 0
    @State var questionsArr: [Question] = []
    @State var userInput = ""
    @State var showAlert = false
    @State var alertMessage = ""
    @State var highScore = 0
    @State var skips = 3
    @State var gameState: GameState = .notStarted
    @State var isGameOver: Bool = false

    var body: some View {
        NavigationStack {
            ZStack{
                RadialGradient(stops: [
                    .init(color: Color(red: 1.0, green: 0.85, blue: 0.1), location: 0.0),  // Bright Yellow
                    .init(color: Color(red: 0.53, green: 0.81, blue: 0.98), location: 0.5), // Sky Blue
                    .init(color: Color(red: 0.6, green: 0.8, blue: 0.6), location: 0.8)   // Soft Green
                ], center: .top, startRadius: 200, endRadius: 400)
                .ignoresSafeArea()
                
                VStack(spacing: 10){
                    
                    VStack(spacing: 10){
                        
                        VStack(spacing: 10){
                            
                            // Presettings and Views presented before game started
                            if index == 0 && gameState == .notStarted{
                                Text("Welcome to SwiftQuiz!")
                                    .font(.title)
                                    .foregroundColor(Color.white)
                                GameSetupView(maxMultiplier: $maxMultiplier, choice: $choice, questionChoices: questionChoices)
                                
                                Button("Play"){
                                    startGame()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                            }
                        }
                        
                        MainGameView(
                            userInput: $userInput,
                            index: $index,
                            totalQuestions: $totalQuestions,
                            highScore: $highScore,
                            correctAnswers: $correctAnswers,
                            questionsArr: $questionsArr,
                            gameState: $gameState,
                            skips: $skips,
                            processAnswer: processAnswer,
                            playAgain: playAgain
                        )
                        
                        Spacer()
                        

                        .alert(alertMessage, isPresented: $showAlert) {
                            Button("OK", role: .cancel){}
                        }
                    
                        .alert("Game Over", isPresented: $isGameOver) {
                            Button("Play Again"){
                                playAgain()
                            }
                            
                            Button("Cancel", role: .cancel){}
                        } message: {
                            Text("You got \(correctAnswers)/\(totalQuestions)")
                        }
                        
                    }
                }
                
                // Changes isGameOver boolean for alerts based on the gameState
                .onChange(of: gameState) {
                    isGameOver = gameState == .finished
                }

                .navigationTitle("Edutainment")
            }
        }
    }
    

    func generateQuestions(pracNumbers: Int, lengthQuestions: Int) -> [Question] {
        
        var questions: [Question] = []
        
        for _ in 0..<lengthQuestions {
            let choice1 = Int.random(in: 1...pracNumbers)
            let choice2 = Int.random(in: 1...pracNumbers)
            
            // Generate the question text
            let questionText = "What is \(choice1) x \(choice2)?"
            let correctAnswer = choice1 * choice2
            
            questions.append(Question(questionText: questionText, correctAnswer: correctAnswer))
            
        }
        
        return questions
    }
    
    func startGame(){
        questionsArr = generateQuestions(pracNumbers: maxMultiplier, lengthQuestions: choice)
        questionsArr.shuffle()
        gameState = .inProgress
        totalQuestions = questionsArr.count
        index = 0
    }
    
    // Helper when user decides to try to skip a question
    func skipQuestion() {
        
        if skips > 0 {
            index += 1
            
            if index == totalQuestions{
                gameState = .finished
                alertMessage = "Last Question skipped game over"
                return
            }
            
            alertMessage = "Question Skipped Successfully No Point"
            showAlert = true
            skips -= 1
        
        }
        
        else{
            alertMessage = "Question can't be skipped"
            showAlert = true
        }
        
    }
    
    private func validInput() -> String? {
        
        // Empty String Guard
        guard !userInput.isEmpty else {
            return "Empty input, please enter a number."
        }
        
        // Valid Number Check
        guard let _ = Int(userInput) else{
            return "Invalid Input please enter a valid number"
        }
        
        return nil
        
    }
    
    func checkAnswer(){
        
        // Increment by 1 for correct answer
        let userAnswer = Int(userInput)
        if userAnswer == questionsArr[index].correctAnswer{
            correctAnswers += 1
            alertMessage = "Correct +1 Point"
        }
        
        // Decrement by 1 for incorrect answer
        else{
            
            // Decrement only above 0 no negative points
            if correctAnswers > 0 {
                correctAnswers -= 1
                alertMessage = "Incorrect -1 Point"
            }
            
            // No negative points
            else{
                alertMessage = "Incorrect No Point"
            }
            
        }
    }
    
    
    func processAnswer(isSkipping: Bool = false){
        
        if isSkipping{
            skipQuestion()
            return
        }
        
        if let errorMessage = validInput(){
            alertMessage = errorMessage
            showAlert = true
            return
        }
        
        // Checks answer
        checkAnswer()
        
        // Proceed to next question
        index += 1
        
        // End of the Game
        if index == totalQuestions{
            gameState = .finished
            return
        }
        
        // shows alert at the end
        showAlert = true
        
        // Resets input field
        userInput = ""
    }
    
    func playAgain() {
        
        // Sets High Score after Game is Over
        if correctAnswers > highScore {
            highScore = correctAnswers
        }
        
        // Reset Game Logic Resets Everything back to default values
        totalQuestions = 0
        correctAnswers = 0
        index = 0
        gameState = .notStarted
        questionsArr = []
        userInput = ""
        skips = 3
    }
    
}

#Preview {
    ContentView()
}
