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

        // Set weather image
        if let image = UIImage(systemName: weatherDetail.imageName)?.withRenderingMode(.alwaysTemplate) {
            cell.imageView?.image = image
            cell.imageView?.tintColor = .yellow // Customize tint color as needed
        }

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none

        return cell
    }
}


