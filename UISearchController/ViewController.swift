//
//  ViewController.swift
//  KiloMoya
//
//  Created by Алия Тлеген on 10.08.2022.
//

import UIKit
import SnapKit
import Moya

class ViewController: UIViewController {

    // MARK: - Public Variables -
    
    var users = [User]()
    var filteredArray = [User]()
    var searchController: UISearchController!
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    let userProvider = MoyaProvider<UserService>()
    
    // MARK: - Private Variables -
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.separatorInset = .zero
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        return tableView
    }()

    // MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupNavigationItem()
        configureSearchController()
        userProvider.request(.readUsers) { (result) in
            switch result {
            case .success(let response):
//                let json = try! JSONSerialization.jsonObject(with: response.data, options: [])
//                print(json)
                let users = try! JSONDecoder().decode([User].self, from: response.data)
                self.users = users
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Setup -
    
    func setupViews() {
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "Users"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action:#selector(addUser)
        )
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredArray = users.filter { (item: User) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions -
    
    @objc func addUser() {
        let kilo = User(id: 55, name: "Kilo Loco")
        userProvider.request(.createUser(name: kilo.name)) { (result) in
            switch result {
            case .success(let response):
                let newUser = try! JSONDecoder().decode(User.self, from: response.data)
                self.users.insert(newUser, at: 0)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }
}

// MARK: - Extensions -

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredArray.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        if isFiltering {
            cell.nameLabel.text = "\(filteredArray[indexPath.row].name)"
        }
        else {
            cell.nameLabel.text = "\(users[indexPath.row].name)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        userProvider.request(.updateUser(id: user.id, name: "[Modified] " + user.name)) { result in
            switch result {
            case .success(let response):
                let modifiedUser = try! JSONDecoder().decode(User.self, from: response.data)
                self.users[indexPath.row] = modifiedUser
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        print(user)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let user = users[indexPath.row]
        
        userProvider.request(.deleteUser(id: user.id)) { (result) in
            switch result {
            case .success(let response):
                print("Delete: \(response)")
                self.users.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    public func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
}

