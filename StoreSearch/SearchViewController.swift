//
//  ViewController.swift
//  StoreSearch
//
//  Created by zijie vv on 13/04/2019.
//  Copyright © 2019 zijie vv. All rights reserved.
//

import UIKit


struct TableView {
    struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
}

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
//    var searchResults = [SearchResult]()
//    var hasSearched = false
//    var isLoading = false
//    var dataTask: URLSessionDataTask?
    var landscapeVC: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
    private let search = Search()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = NSLocalizedString("Search", comment: "split view master button")
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell,
                            bundle: nil)
        tableView.register(
            cellNib,
            forCellReuseIdentifier:TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell,
                        bundle: nil)
        tableView.register(
            cellNib,
            forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(
            cellNib,
            forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
    }
    
    // MARK:- Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
//        print("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
    
    // MARK:- Landscape
    override func willTransition(
    to newCollection: UITraitCollection,
    with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        
        if ((rect.width == 736 || rect.width == 896) && rect.height == 414)
        || (rect.width == 414 && (rect.height == 736 || rect.height == 896)) {
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
            switch newCollection.verticalSizeClass {
            case .compact:
                showLandscape(with: coordinator)
            case .regular, .unspecified:
                hideLandscape(with: coordinator)
            @unknown default:
                break
            }
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(
            withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC {
//            controller.searchResults = search.searchResults
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate(
                alongsideTransition: { _ in
                    controller.view.alpha = 1
                    self.searchBar.resignFirstResponder()
                    
                    if self.presentedViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                },
                completion: { _ in
                    controller.didMove(toParent: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(
                alongsideTransition: { _ in
                    controller.view.alpha = 0
                    
                    if self.presentedViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                },
                completion: { _ in
                    controller.view.removeFromSuperview()
                    controller.removeFromParent()
                    self.landscapeVC = nil
            })
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
    
    
    // MARK: Error handling
    func showNetworkError() {
        let title = NSLocalizedString("Whoops", comment: "Error alert: title")
        let message = NSLocalizedString("There was an error accessing the iTunes Store. Please try again.", comment: "Error alert: message")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Search.Category(
        rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(
                for: searchBar.text!,
                category: category,
                completion: { success in
                    if !success {
                        self.showNetworkError()
                    }
                    
                    self.tableView.reloadData()
                    self.landscapeVC?.searchResultsReceived()
            })
            
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: Extending search bar to status area
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
            
        case .loading:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.loadingCell,
                for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
            
        case .noResults:
            return tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.searchResultCell,
                for: indexPath)
                as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            
            return cell
        }
//        if search.isLoading {
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: TableView.CellIdentifiers.loadingCell,
//                for: indexPath)
//
//            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
//            spinner.startAnimating()
//
//            return cell
//        } else if search.searchResults.count == 0 {
//            return tableView.dequeueReusableCell(
//                withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
//                for: indexPath)
//        } else {
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: TableView.CellIdentifiers.searchResultCell,
//                for: indexPath)
//                as! SearchResultCell
//
//            let searchResult = search.searchResults[indexPath.row]
//            cell.configure(for: searchResult)
//
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass
        == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            
            if splitViewController!.displayMode != .allVisible {
                hideMasterPane()
            }
        }
//        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
    
    // MARK:- For iPad view
    private func hideMasterPane() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.splitViewController!.preferredDisplayMode = .primaryHidden
            },
            completion: { _ in
                self.splitViewController!.preferredDisplayMode = .automatic
        })
    }
    
}
/*
func performSearch() {
    // Tells the UISearchBar that it should no longer listen for keyboard input
    // Keyboard will hide itself until the search bar is tapped again.
    if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()
        
        hasSearched = true
        searchResults = []
        
        let url = iTunesURL(searchText: searchBar.text!,
                            category: segmentedControl.selectedSegmentIndex)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            if let error = error as NSError?, error.code == -999 {
                //                    print("Failure! \(error.localizedDescription)")
                return  // Search was cancelled
            } else if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
                //                    print("Success! \(data!)")
                if let data = data {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    
                    return
                }
            } else {
                print("Failure! \(response!)")
            }
            
            DispatchQueue.main.async {
                self.hasSearched = false
                self.isLoading = false
                self.tableView.reloadData()
                self.showNetworkError()
            }
        })
        
        dataTask?.resume()
    }
}
*/
