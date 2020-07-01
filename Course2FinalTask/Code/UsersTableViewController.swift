//
//  UsersTableViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 22.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class UsersTableViewController: UIViewController {

    // MARK: - Outlets and properties
    
    @IBOutlet weak var usersTable: UITableView!
    var data:[User] = []
    var hostUser: String?
    var indexForRow: IndexPath?
    let apiHandler = APIHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiHandler.delegate = self
        usersTable.dataSource = self
        usersTable.delegate = self
        usersTable.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    func renewData() {
        if self.navigationItem.title == "Followers" {
            apiHandler.get(.followers, withID: hostUser, completionHandler: {users in
                guard let newUsers = users as? [User] else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                self.data = newUsers
                DispatchQueue.main.async {
                    self.usersTable.reloadData()
                }
                
            })
        } else {
            apiHandler.get(.following, withID: hostUser, completionHandler: {users in
                guard let newUsers = users as? [User] else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                self.data = newUsers
                DispatchQueue.main.async {
                    self.usersTable.reloadData()
                }
            })
        }
    }
}

    // MARK: - UITableViewDataSource, UITableViewDelegate

extension UsersTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! UsersTableViewCell
        cell.textLabel?.text = data[indexPath.item].fullName
        if cell.imageView == nil {
            print("nil at \(indexPath)")
        }
        cell.imageView?.kf.setImage(with: URL(string: data[indexPath.item].avatar)!, placeholder: UIImage(systemName: "pencil"))
        cell.userId = data[indexPath.item].id
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.navigationItem.title == "Likes" {
            tableView.deselectRow(at: indexPath, animated: true)
            navigationController?.popViewController(animated: true)
        }
        let user = data[indexPath.item]
        let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        newVC.usernameTitle.title = user.username
        self.indexForRow = indexPath
        (self.tabBarController?.viewControllers?[2] as! UINavigationController).pushViewController(newVC, animated: true)
        newVC.user = user
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?[2]
    }
}
