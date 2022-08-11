//
//  ViewController.swift
//  Project5
//
//  Created by Rishi Chhabra on 11/08/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(play))
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func play() {
        startGame()
    }

    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word",for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak ac,weak self] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
        
    }
    
    func submit(_ answer : String) {
        let lowerAnswer = answer.lowercased()
        
        var errorTitle = ""
        var errorMessage = ""
        
        if(isPossible(word: lowerAnswer))
        {
            if( isOriginal(word: lowerAnswer))
            {
                if(isReal(word: lowerAnswer))
                {
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else {
                    errorTitle = "Not a word"
                    errorMessage = "Enter valid Word"
                }
            } else {
                errorTitle = "Not Original"
                errorMessage = "Enter Words which are not used"
            }
        } else {
            errorTitle = "Cannot be generated from \(lowerAnswer)"
            errorMessage = "Enter Word that can be generated from \(lowerAnswer)"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    func isPossible(word : String) -> Bool {
        guard var temp = title?.lowercased() else { return false}
        
        for letter in word  {
            if let position  = temp.firstIndex(of: letter) {
                temp.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
        
    }
    
    func isOriginal(word : String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word : String) -> Bool {
        if(word == title?.lowercased()){ return false }
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelled.location == NSNotFound
        
    }
}

