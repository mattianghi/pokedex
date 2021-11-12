//
//  ViewController.swift
//  pokedexApp
//
//  Created by Mattia Anghileri
//

import UIKit

// MARK: - Pokemon
struct Pokemon: Decodable {
    let results: [Result]
}

// MARK: - Result
struct Result: Decodable{
    let name: String
    let url: String
}

struct ImageMoves: Decodable{
    let moves: [Move]
}

struct Species: Decodable {
    let name: String
    let url: String
}

struct Move: Decodable {
    let move: Species
}


class ViewController: UIViewController {
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    var test: Pokemon?
    var loading = true
    var imageView : UIImageView?
    var url: URL?
    var movesName = [String]()
    var searchArray = [String]()
    var name: String = ""
    var index: Int = -1
    var urlMoves: String = ""
    var searching = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPokemon()
        delegate()
        refreshController()
        imageView  = UIImageView(frame:CGRect(x: 10, y: 50, width: 100, height: 300));
        self.view.addSubview(imageView!)
        
    }
    
    func delegate()
    {
        tableView.delegate = self
        tableView.dataSource = self
        search.delegate = self
    }
    
    func refreshController()
    {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func getPokemon() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            fatalError("URL guard stmt failed")
        }
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            //HANDLE DECODING
            if let data = data {
                do{
                    let json = try JSONDecoder().decode(Pokemon.self, from: data)
                    self.test = json
                }catch{
                    print("error")
                }
            }
            self.loading = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
    
    //prepare for the next storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "details" {
            let vc = segue.destination as? detailsViewController
            vc?.url = url
            vc?.index = index
            vc?.name = name
            vc?.urlMoves = urlMoves
        }
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        index = indexPath.row
        var image: Int?
        
        if searching{
            
            let varname = searchArray[indexPath.row]
            var numb = 0
            for i in self.test?.results ?? []
            {
                numb+=1
                if i.name == varname
                {
                    image = numb
                    urlMoves = i.url
                    name = varname
                }
            }
        }
        else
        {
            image = indexPath.row + 1
            urlMoves = (self.test?.results[indexPath.row].url)!
            name = (test?.results[indexPath.row].name)!
        }
        
        url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(image!).png")!
        
        self.performSegue(withIdentifier: "details", sender: self)
        
        
    }
}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading{
            return 1
        }
        if searching{
            return searchArray.count
        }
        else
        {
            return (test?.results.count)!
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if loading{
            cell.textLabel?.text = "Loading ..."
        }
        if searching{
            cell.textLabel?.text = searchArray[indexPath.row]
        }
        else
        {
            let name = test?.results[indexPath.row].name
            cell.textLabel?.text = name
        }
        return cell
    }
    
}

extension ViewController: UISearchBarDelegate
{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {  //work
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // print(searchText)
        searchArray.removeAll()
        
        for i in test?.results ?? []
        {
            print(i.name)
            if i.name.hasPrefix(searchText.lowercased())
            {
                searchArray.append(i.name)
            }
        }
        
        searching = true
        tableView.reloadData()
    }
}

