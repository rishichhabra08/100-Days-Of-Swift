//
//  ViewController.swift
//  Project7
//
//  Created by Rishi Chhabra on 11/08/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var urlString : String;
        if navigationController?.tabBarItem.tag == 0{
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
    
//            if let data = try? Data(contentsOf: url) {
//                parse(data)
//            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    self.parse(data)
                } else {
                    self.showError()
                }
                
            }.resume()
        } else {
            showError()
        }
        
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading, please check your connection and try again!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
    
    func parse(_ data: Data){

        let decoder = JSONDecoder()
        
        if let data = try? decoder.decode(Petitions.self, from: data) {
            petitions = data.results
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        
        cell.textLabel?.text = petitions[indexPath.row].title
        cell.detailTextLabel?.text = petitions[indexPath.row].body
        return cell
    }


}

