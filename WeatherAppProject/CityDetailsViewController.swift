//
//  CityDetailsViewController.swift
//  WeatherAppProject
//
//  Created by Sovit Thapa on 2024-07-15.
//

import UIKit

class CityDetailsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var allWeatherDetails: [(details: [String], imageName: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.title = "Cities"
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWeatherDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)

        let weatherDetail = allWeatherDetails[indexPath.row]
        cell.textLabel?.text = weatherDetail.details.joined(separator: "\n")
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.backgroundColor = UIColor(red: 115/255, green: 206/255, blue: 224/255, alpha: 1.0)  // Light blue color
        cell.selectionStyle = .none

        // Set weather image with a custom size and yellow tint
        if let image = UIImage(systemName: weatherDetail.imageName)?.withRenderingMode(.alwaysTemplate) {
            let imageSize = CGSize(width: 60, height: 64)  // Adjust size as needed
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            UIColor.yellow.setFill()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            cell.imageView?.image = scaledImage
            cell.imageView?.tintColor = .yellow  // Set the tint color here
        }

        return cell
    }

}

