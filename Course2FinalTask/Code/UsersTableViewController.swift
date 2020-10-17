//
//  UsersTableViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 22.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData
import MastodonKit

class UsersTableViewController: UIViewController {

    // MARK: - Outlets and properties
    
    @IBOutlet weak var usersTable: UITableView!
    var users:[Account] = []
    var hostUser: Account?
    let apiHandler = APIHandler()
    let newAPIHandler = NewAPIHandler()
    var retrievingCase: RetrievingCase?
    let cellPadding: CGFloat = 5
    
    enum RetrievingCase {
        case followers
        case following
        case likes(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = BackItem()
        backItem.title = "BACK"
        backItem.frame = backItem.buttonBounds ?? CGRect(x: 0, y: 0, width: 50, height: 50)
        backItem.buttonColor = UIColor(named: "background")
        backItem.textColor = UIColor(named: "label")
        backItem.isUserInteractionEnabled = true
        backItem.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        apiHandler.delegate = self
        usersTable.dataSource = self
        usersTable.delegate = self
        usersTable.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        guard let retrievingCase = retrievingCase else {
            return
        }
        newAPIHandler.getUsers(retrievingCase, withID: hostUser?.id, completionHandler: {result in
            self.users = result
            DispatchQueue.main.async {
                self.usersTable.reloadData()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection != nil {
            if previousTraitCollection!.userInterfaceStyle == .light {
                view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
            } else {
                view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
            }
        }
    }
    
    @objc func backTapped(_ sender: BackItem) {
        sender.showAnimation({
            self.navigationController?.popViewController(animated: true)
        })
    }
}

    // MARK: - UITableViewDataSource, UITableViewDelegate

extension UsersTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellPadding
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! UsersTableViewCell
        
        cell.user = users[indexPath.section]
        cell.fill()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
            cell?.transform = CGAffineTransform(translationX: 2, y: 2)
            cell?.layer.shadowOpacity = 0
        }, completion: {_ in
            UIView.animate(withDuration: 0.05, delay: 0, options: [], animations: {
                cell?.transform = CGAffineTransform(translationX: 0, y: 0)
                cell?.layer.shadowOpacity = 0.6
            }, completion: {_ in
                cell?.isUserInteractionEnabled = true
                tableView.deselectRow(at: indexPath, animated: true)
                let newVC = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
                newVC.user = MutableAccount(self.users[indexPath.section]) 
                self.navigationController?.pushViewController(newVC, animated: true)
            })
        })
        
    }
    
}
