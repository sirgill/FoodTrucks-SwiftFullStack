//
//  DataService.swift
//  FoodTruckClient
//
//  Created by Surinder Singh Gill on 4/5/17.
//  Copyright © 2017 Surinder Singh Gill. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DataServiceDelegate: class {
    func trucksLoaded()
    func reviewsLoaded()
    func avgRatingUpdated()
}

class DataService {
    static let instance = DataService()
    
    weak var delegate: DataServiceDelegate?
    var foodTrucks = [FoodTruck]()
    var reviews = [FoodTruckReview]()
    var avgRating: Int = 0
    
    // GET all trucks ** Alamofire and SwiftyJSON
    func getAllFoodTrucks(completion: @escaping callback) {
        let url = GET_ALL_FT_URL
        
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseData { response in
                guard response.result.error == nil else {
                    print("Alamofire Request failed: \(response.result.error)")
                    completion(false)
                    return
                }
                guard let data = response.data, let statusCode = response.response?.statusCode else {
                    print("An error occurred obtaining data")
                    completion(false)
                    return
                }
                print("Alamofire request succeeded: HTTP \(statusCode)")
                self.foodTrucks = FoodTruck.parseFoodTruckJSONData(data: data)
                self.delegate?.trucksLoaded()
                completion(true)
        }
    }
    
       
    // GET all reviews for a specific food truck
    func getAllReviews(_ truck: FoodTruck, completion: @escaping callback) {
        Alamofire.request("\(GET_ALL_FT_REVIEWS)/\(truck.docId)", method: .get)
            .validate(statusCode: 200..<300)
            .responseData { response in
                if (response.result.error == nil) {
                    print("Alamofire request succeeded: HTTP \(response.response?.statusCode)")
                    if let data = response.data {
                        self.reviews = FoodTruckReview.parseReviewJSONData(data: data)
                        self.delegate?.reviewsLoaded()
                        completion(true)
                    }
                } else {
                    debugPrint("Alamofire request failed: \(response.result.error)")
                    completion(false)
                }
        }
    }
    
    // POST add a new food truck
    func addNewFoodTruck(_ name: String, foodtype: String, avgcost: Double, latitude: Double, longitude: Double, completion: @escaping callback) {
        
        let url = POST_ADD_NEW_TRUCK
        
        // Add headers
        let headers = [
            "Content-Type":"application/json; charset=utf-8",
            ]
        
        // Construct json body
        let body: [String: Any] = [
            "name": name,
            "foodtype": foodtype,
            "avgcost": avgcost,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        // Request
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<299)
            .responseJSON { response in
                if (response.result.error == nil) {
                    guard let statusCode = response.response?.statusCode else {
                        print("An error occurred")
                        completion(false)
                        return
                    }
                    print("Alamofire request succeeded: HTTP \(statusCode)")
                    
                    completion(true)
                } else {
                    print("HTTP request failed: \(response.result.error)")
                    completion(false)
                }
        }
    }
    
    // POST add a new Food Truck Review
    func addNewReview(_ foodTruckId: String, title: String, text: String, rating: Int, completion: @escaping callback) {
        let url = "\(POST_ADD_NEW_REVIEW)/\(foodTruckId)"
        
        // Add Headers
        let headers = [
            "Content-Type":"application/json; charset=utf-8",
            ]
        
        // json body
        let body: [String: Any] = [
            "truckid": foodTruckId,
            "reviewtitle": title,
            "reviewtext": text,
            "foodtruck": foodTruckId,
            "starrating": rating
        ]
        
        // Request
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    guard let statusCode = response.response?.statusCode else {
                        print("An error occurred")
                        completion(false)
                        return
                    }
                    print("Alamofire request successful: HTTP \(statusCode)")
                    completion(true)
                } else {
                    print("HTTP Request failed: \(response.result.error)")
                    completion(false)
                }
        }
    }
    
    // Get avg star rating for a specific truck
    func getAverageStarRatingForTruck(_ truck: FoodTruck, completion: @escaping callback) {
        
        let url = "\(GET_FT_STAR_RATING)/\(truck.docId)"
        
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = JSON(response.result.value!)
                    if let avgRating = json["avgrating"].int {
                        self.avgRating = avgRating
                        self.delegate?.avgRatingUpdated()
                        completion(true)
                    }
                } else {
                    self.avgRating = 0
                    self.delegate?.avgRatingUpdated()
                    completion(false)
                }
        }
    }
}














