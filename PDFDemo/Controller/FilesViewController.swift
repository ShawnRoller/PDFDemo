//
//  FilesViewController.swift
//  PDFDemo
//
//  Created by Shawn Roller on 1/2/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {

    private var books: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Custom title
        self.title = "Books"
        
        // Hardcode the data for
        self.books = Model.Books
    }
    
}

// MARK: - UITableViewDatasource
extension FilesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Names.CellID, for: indexPath)
        cell.textLabel?.text = self.books[indexPath.row]
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension FilesViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navController = self.splitViewController?.viewControllers[1] as? UINavigationController else { fatalError("Could not get Navigation Controller") }
        guard let mainVC = navController.viewControllers.first as? MainViewController else { fatalError("Could not get MainVC") }
        mainVC.load(self.books[indexPath.row])
    }
    
}
