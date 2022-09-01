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
//    var dataArray = [User]()
    var filteredArray = [User]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    
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
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search here..."
            searchController.searchBar.delegate = self
            searchController.searchResultsUpdater = self
            searchController.searchBar.sizeToFit()

            self.tableView.tableHeaderView = searchController.searchBar
        }

    
}

// MARK: - Extensions -

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if shouldShowSearchResults {
                return filteredArray.count
            }
            return users.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
//        let user = users[indexPath.row]
//        cell.configure(model: user)
        if shouldShowSearchResults {
            cell.nameLabel.text = "\(filteredArray[indexPath.row].name)"
        }
        else {
            cell.nameLabel.text = "\(users[indexPath.row].name)"
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70.0
//    }
    
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
    public func updateSearchResults(for searchController: UISearchController){
            let searchString = searchController.searchBar.text
//             Filter the data array and get only those countries that match the search text.
        filteredArray = users.filter({ (user: User) -> Bool in
            let nameText: NSString = user.name as NSString
                return (nameText.range(of: searchString!, options: .caseInsensitive).location) != NSNotFound
                })
            tableView.reloadData()
        }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }


    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
}

