//
//  DatabaseManager.swift
//  Sqlite FMDB Demo
//
//  Created by Adwait Barkale on 18/12/20.
//  Copyright © 2020 Adwait Barkale. All rights reserved.
//

import Foundation
import UIKit

class DatabaseManager : NSObject {
    
    static let shared: DatabaseManager = DatabaseManager()
    
    
    let databaseFileName = "myDatabase.sqlite"
    var pathToDatabase : String!
    var database : FMDatabase!
    
    let field_MovieID = "movieID"
    let field_MovieTitle = "title"
    let field_MovieCategory = "category"
    let field_MovieYear = "year"
    let field_MovieURL = "movieURL"
    let field_MovieCoverURL = "coverURL"
    let field_MovieWatched = "watched"
    let field_MovieLikes = "likes"
    
    override init()
    {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
    
    func createDatabase() -> Bool
    {
        var isCreated = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase)
        {
            //FMDatabase initializer creates Database file
            database = FMDatabase(path: pathToDatabase)
            
            if database != nil
            {
                if database.open(){
                    print("Database open Success")
                    let createMoviesTableQuery = "create table movies (\(field_MovieID) integer primary key autoincrement not null, \(field_MovieTitle) text not null, \(field_MovieCategory) text not null, \(field_MovieYear) integer not null, \(field_MovieURL) text, \(field_MovieCoverURL) text not null, \(field_MovieWatched) bool not null default 0, \(field_MovieLikes) integer not null)"
                    
                    do{
                        try database.executeUpdate(createMoviesTableQuery, values: nil)
                        isCreated = true
                    }catch let err{
                        print("Failed to create Movies Table - \(err.localizedDescription)")
                    }
                    database.close()
                    
                }else{
                    print("Failed to open the Database")
                }
                
            }
            
        }
        
        print("Database Path - \(pathToDatabase ?? "")")
        return isCreated
    }
    
    
    func openDatabase() -> Bool
    {
        //Check if Database if Nil
        if database == nil
        {
            //Check if File Exists at Database Path
            if FileManager.default.fileExists(atPath: pathToDatabase)
            {
                //If Exists Take Object into database
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        //Check if Database is not equal to nil
        if database != nil
        {
            //Check if Database Opens
            if database.open()
            {
                print("Database Path - \(pathToDatabase ?? "")")
                return true
            }
        }
        //If Database is not present return false and Create by calling createDatabase()
        return false
        
    }
    
    func insertMoviesData()
    {
        if database.open()
        {
            
            //Locate to movies.tsv file
            
            if let pathToMoviesFile = Bundle.main.path(forResource: "movies", ofType: ".tsv")
            {
                
                do{
                    
                    let moviesFileContent = try String(contentsOfFile: pathToMoviesFile)
                    //print(moviesFileContent)
                    let moviesData = moviesFileContent.components(separatedBy: "\r\n")
                    //print(moviesData)
                    
                    var query = ""
                    for movie in moviesData
                    {
                        let movieParts = movie.components(separatedBy: "\t")
                        
                        if movieParts.count == 5
                        {
                            let movieTitle = movieParts[0]
                            let movieCategory = movieParts[1]
                            let movieYear = movieParts[2]
                            let movieURL = movieParts[3]
                            let movieCoverURL = movieParts[4]
                            
                            query += "insert into movies (\(field_MovieID), \(field_MovieTitle), \(field_MovieCategory), \(field_MovieYear), \(field_MovieURL), \(field_MovieCoverURL), \(field_MovieWatched), \(field_MovieLikes)) values (null, '\(movieTitle)', '\(movieCategory)', \(movieYear), '\(movieURL)', '\(movieCoverURL)', 0, 0);"
        
                        }
                    }
                    
                    if !database.executeStatements(query)
                    {
                        print("Failed to insert initial data into the database.")
                        print(database.lastError(), database.lastErrorMessage())
                    }

                    
                    
                }catch let err{
                    print("Unable to get Movies File Content - \(err.localizedDescription)")
                }
            }
            database.close()
        }
    }
    
    func loadMovies() -> [MovieInfo]!
    {
        var movies: [MovieInfo]!
        
        if openDatabase()
        {
            let query = "select * from movies order by \(field_MovieYear) asc"
            
            do{
                let results = try database.executeQuery(query, values: nil)
                
                while results.next()
                {
                    let movie = MovieInfo(movieID: Int(results.int(forColumn: field_MovieID)), title: results.string(forColumn: field_MovieTitle), category: results.string(forColumn: field_MovieCategory), year: Int(results.int(forColumn: field_MovieYear)), movieURL: results.string(forColumn: field_MovieURL), coverURL: results.string(forColumn: field_MovieCoverURL), watched: results.bool(forColumn: field_MovieWatched), likes: Int(results.int(forColumn: field_MovieLikes)))
                    
                    if movies == nil
                    {
                        movies = [MovieInfo]()
                    }
                    movies.append(movie)
                }
                
            }catch let err
            {
                print(err.localizedDescription)
            }
            database.close()
        }

        return movies
    }
    
    func loadMovie(with Id: Int,completionHandler : (_ movieInfo : MovieInfo?) -> Void)
    {
        var movieInfo: MovieInfo!
        
        if openDatabase()
        {
            let query = "select * from movies where \(field_MovieID) = \(Id)"
            do {
                let results = try database.executeQuery(query, values: nil)
                
                if results.next(){
                    movieInfo = MovieInfo(movieID: Int(results.int(forColumn: "\(field_MovieID)")), title: results.string(forColumn: "\(field_MovieTitle)"), category: results.string(forColumn: "\(field_MovieCategory)"), year: Int(results.int(forColumn: "\(field_MovieYear)")), movieURL: results.string(forColumn: "\(field_MovieURL)"), coverURL: results.string(forColumn: "\(field_MovieCoverURL)"), watched: results.bool(forColumn: "\(field_MovieWatched)"), likes: Int(results.int(forColumn: "\(field_MovieLikes)")))
                    
                }else {
                    print("No Data Fetched")
                }
                
            } catch let err {
                print("Error - \(err.localizedDescription)")
            }
            database.close()
        }
        completionHandler(movieInfo)
    }
    
    func updateMovie(ID: Int,Watched: Bool,Likes: Int)
    {
        if openDatabase() // database.open()
        {
            let query = "Update movies set \(field_MovieWatched) = \(Watched), \(field_MovieLikes) = \(Likes) Where \(field_MovieID) = \(ID)"
            
            do{
                try database.executeUpdate(query, values: nil)
            }catch let err{
                print("Error Updating - \(err.localizedDescription)")
            }
            
            database.close()
        } else {
            print("Unable to open Database")
        }
    }
    
}
