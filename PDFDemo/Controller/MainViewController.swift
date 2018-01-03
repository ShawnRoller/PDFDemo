//
//  MainViewController.swift
//  PDFDemo
//
//  Created by Shawn Roller on 1/2/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//

import UIKit
import PDFKit

class MainViewController: UIViewController {

    private let pdfView = PDFView()
    private let thumbnailView = PDFThumbnailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
}

// MARK: - Private functions
extension MainViewController {
    
    private func setupViews() {
        self.thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.thumbnailView)
        
        // Set constraints for thumbnail view
        self.thumbnailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.thumbnailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.thumbnailView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.thumbnailView.heightAnchor.constraint(equalToConstant: Sizes.ThumbnailViewHeight).isActive = true
        self.thumbnailView.thumbnailSize = CGSize(width: Sizes.ThumbnailSize, height: Sizes.ThumbnailSize)
        
        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pdfView)
        
        // Set constraints for pdf view
        self.pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.pdfView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.pdfView.bottomAnchor.constraint(equalTo: self.thumbnailView.topAnchor).isActive = true
        
        self.thumbnailView.layoutMode = .horizontal
        self.thumbnailView.pdfView = self.pdfView
    }
    
}

// MARK: - Helper functions
extension MainViewController {
    
    private func getFilenameFromString(_ name: String) -> String {
        let filename = name.replacingOccurrences(of: " ", with: "-").lowercased()
        return filename
    }
    
}

// MARK: - Public functions
extension MainViewController {
    
    public func load(_ book: String) {
        guard let path = Bundle.main.url(forResource: getFilenameFromString(book), withExtension: "pdf") else { fatalError("Could not get PDF file.") }
        guard let document = PDFDocument(url: path) else { fatalError("Could not get PDFDocument")}
        self.pdfView.document = document
        self.pdfView.goToFirstPage(nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.title = book
        }
    }
    
}
