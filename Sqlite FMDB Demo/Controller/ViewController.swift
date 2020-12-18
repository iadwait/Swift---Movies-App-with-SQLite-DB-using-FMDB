//
//  ViewController.swift
//  Sqlite FMDB Demo
//
//  Created by Adwait Barkale on 18/12/20.
//  Copyright © 2020 Adwait Barkale. All rights reserved.
//

import UIKit

struct MovieInfo {
    var movieID: Int!
    var title: String!
    var category: String!
    var year: Int!
    var movieURL: String!
    var coverURL: String!
    var watched: Bool!
    var likes: Int!
}

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
    @IBOutlet var tableView: UITableView!
    
    let db = DatabaseManager.shared
    var moviesData : [MovieInfo] = []
    var isDataFetched = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureTableView()
        
        var openDB = db.openDatabase()
        
        if !openDB
        {
            print("Database not Opened")
             openDB = db.createDatabase()
        }
        
        if openDB
        {
            print("Database Created and Opened Success")
        }
        
        //db.insertMoviesData()
        
        moviesData = db.loadMovies()
        if moviesData.count > 0
        {
            isDataFetched = true
            tableView.reloadData()
        }
        
    }

    func configureTableView()
    {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDataFetched == false
        {
                return 0
        }
        return moviesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesViewCell", for: indexPath) as! MoviesViewCell
        
        if isDataFetched == true{
            let currentMovie = moviesData[indexPath.row]
            
            cell.lblName.text = currentMovie.title
            
            if let url = URL(string: currentMovie.coverURL)
            {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    if let imgData = data
                    {
                        DispatchQueue.main.async {
                            cell.imgView.image = UIImage(data: imgData)
                        }
                    }
                    
                }.resume()
            }
            cell.imgView.contentMode = .scaleAspectFit
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let nextVC = storyboard?.instantiateViewController(identifier: "MovieDetailViewController") as! MovieDetailViewController
        nextVC.movieID = moviesData[indexPath.row].movieID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 119
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete
        {
            if DatabaseManager.shared.deleteMovie(ID: moviesData[indexPath.row].movieID)
            {
                moviesData.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
        
    }
    
}

