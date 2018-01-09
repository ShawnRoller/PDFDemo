//
//  MainViewController.swift
//  PDFDemo
//
//  Created by Shawn Roller on 1/2/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

class MainViewController: UIViewController {

    private let pdfView = PDFView()
    private let thumbnailView = PDFThumbnailView()
    private let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addBarButtonItems()
        addSegmentedControl()
    }
    
}

//MARK: - Tappers
extension MainViewController {
    
    @objc private func promptForSearch() {
        
        let alert = UIAlertController(title: "Search", message: "Enter text to search for.", preferredStyle: .alert)
        alert.addTextField()
        let action = UIAlertAction(title: "Search", style: .default) { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            guard let match = self.pdfView.document?.findString(text, fromSelection: self.pdfView.highlightedSelections?.first, withOptions: .caseInsensitive) else { return }
            self.pdfView.go(to: match)
            self.pdfView.highlightedSelections = [match]
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func shareSelection(sender: UIBarButtonItem) {
        guard let selection = self.pdfView.currentSelection?.attributedString else {
            let alert = UIAlertController(title: "Attention!", message: "Select some text to share.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let vc = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func changeViewMode(segmentedControl: UISegmentedControl) {
        let hidden = segmentedControl.selectedSegmentIndex == 0
        self.pdfView.isHidden = !hidden
        self.textView.isHidden = hidden
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
        self.pdfView.autoScales = true
        self.pdfView.delegate = self
        
        // Setup the textview
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.textView)
        
        // Constrain the textview to fill the view
        self.textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.textView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.textView.isEditable = false
        self.textView.isHidden = true
        self.textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }
    
    private func addBarButtonItems() {
        let back = UIBarButtonItem(barButtonSystemItem: .rewind, target: self.pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        let forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self.pdfView, action: #selector(PDFView.goToNextPage(_:)))
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MainViewController.promptForSearch))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(MainViewController.shareSelection(sender:)))
        self.navigationItem.leftBarButtonItems = [back, forward, search, share]
    }
    
    private func addSegmentedControl() {
        let viewMode = UISegmentedControl(items: ["PDF", "Text"])
        viewMode.addTarget(self, action: #selector(MainViewController.changeViewMode(segmentedControl:)), for: .valueChanged)
        viewMode.selectedSegmentIndex = 0
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewMode)
        self.navigationItem.rightBarButtonItem?.width = 150
    }
    
    private func loadText() {
        guard let pageCount = self.pdfView.document?.pageCount else { return }
        let documentContent = NSMutableAttributedString()
        
        for i in 1 ..< pageCount {
            guard let page = self.pdfView.document?.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            let spacer = NSAttributedString(string: "\n\n")
            documentContent.append(spacer)
            documentContent.append(pageContent)
        }
        textView.attributedText = documentContent
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
        self.loadText()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.title = book
        }
    }
    
}

// MARK: - PDFViewDelegate
extension MainViewController: PDFViewDelegate {
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
}
