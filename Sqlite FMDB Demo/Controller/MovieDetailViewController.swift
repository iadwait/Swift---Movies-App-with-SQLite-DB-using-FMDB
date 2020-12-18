//
//  MovieDetailViewController.swift
//  Sqlite FMDB Demo
//
//  Created by Adwait Barkale on 18/12/20.
//  Copyright © 2020 Adwait Barkale. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    var movieID : Int!
    var movieInfo : MovieInfo!
    var noOfLikes = Int()
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblMovieName: UILabel!
    @IBOutlet var lblMovieCategory: UILabel!
    @IBOutlet var lblMovieYear: UILabel!
    @IBOutlet var isWatchedSwitch: UISwitch!
    @IBOutlet var likeStepper: UIStepper!
    @IBOutlet var lblLikes: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likeStepper.minimumValue = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let id = movieID
        {
            DatabaseManager.shared.loadMovie(with: id) { (movie) in
                
                if movie != nil
                {
                    self.movieInfo = movie!
                    self.setupUI()
                }
                
            }
        }
        
    }
    
    func setupUI()
    {
        lblMovieName.text = movieInfo.title
        lblMovieCategory.text = movieInfo.category
        lblMovieYear.text = String(movieInfo.year)
        lblLikes.text = String(movieInfo.likes)
        noOfLikes = movieInfo.likes
        self.likeStepper.value = Double(movieInfo.likes)
        self.isWatchedSwitch.isOn = movieInfo.watched
        
        
        if let url = URL(string: movieInfo.coverURL)
        {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let imgData = data{
                    DispatchQueue.main.async {
                        self.imgView.image = UIImage(data: imgData)
                    }
                }
            }.resume()
        }
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(btnSaveTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @IBAction func likesStepperTapped(_ sender: UIStepper) {
        //print(sender.value)
        self.noOfLikes = Int(sender.value)
        self.lblLikes.text = "\(noOfLikes)"
        print(noOfLikes)
    }

    @objc func btnSaveTapped()
    {
        //print("Save Tapped")
        let isWatched = self.isWatchedSwitch.isOn
        DatabaseManager.shared.updateMovie(ID: movieInfo.movieID, Watched: isWatched, Likes: noOfLikes)
        self.navigationController?.popViewController(animated: true)
    }

}
