//
//  detailsViewController.swift
//  pokedexApp
//
//  Created by Mattia Anghileri
//

import UIKit
import Network

class detailsViewController: UIViewController {
    
    @IBOutlet weak var moves: UITableView!
    @IBOutlet weak var imagePokemon: UIImageView!
    @IBOutlet weak var namePokemon: UILabel!
    var url:URL?
    var name: String?
    var movesName = [String]()
    var index: Int?
    var urlMoves: String?
    var loading = true
    let monitor = NWPathMonitor()
    
    override func viewDidLoad() {
        self.getImageMoves(i: urlMoves!);  //we take the images
        namePokemon.text? = (name?.uppercased())!
        delegate()
        monitorConnection()
        
    }
    
    func delegate()
    {
        moves.delegate = self
        moves.dataSource = self
    }
    
    func monitorConnection()
    {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                self.downloadImage(from: self.url!)
            } else {
                print("No connection.")
                DispatchQueue.main.async() { [weak self] in
                    self!.imagePokemon.image = UIImage(named: "no-wifi")  //we put a define image if there isn't connection
                }
            }
            
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.imagePokemon!.image = UIImage(data: data)
            }
        }
    }
    
    private func getImageMoves(i: String) {
        guard let url = URL(string: i) else {
            fatalError("URL guard stmt failed")
        }
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            //HANDLE DECODING HERE
            if let data = data {
                do{
                    let json = try JSONDecoder().decode(ImageMoves.self, from: data)
                    for i in json.moves{
                        self.movesName.append(i.move.name)
                    }
                }catch{
                    print("error")
                }
            }
            self.loading = false
            DispatchQueue.main.async {
                self.moves.reloadData()
            }
            
        }.resume()
    }
    
}

extension detailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension detailsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading{
            return 1
        }
        else
        {
            return (movesName.count)
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moves", for: indexPath)
        if loading{
            cell.textLabel?.text = "Loading ..."
        }
        else
        {
            let name = movesName[indexPath.row]
            cell.textLabel?.textAlignment = .center;
            cell.textLabel?.text = "-   " + name
        }
        return cell
    }
}
