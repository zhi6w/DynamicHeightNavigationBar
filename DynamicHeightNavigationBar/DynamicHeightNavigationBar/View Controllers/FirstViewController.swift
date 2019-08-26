//
//  FirstViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class FirstViewController: DynamicNavigationRootViewController {
    
    private let datePicker = UIDatePicker()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension FirstViewController {
    
    private func setupInterface() {
        view.backgroundColor = .orange
        title = "First"
        
        setupNavBar()
        setupTableView()
        print("--------")
    }
    
    private func setupNavBar() {
        
        let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push))
                
        navigationItem.rightBarButtonItem = pushItem
        
        navigationContentView = datePicker
    }
    
    private func setupTableView() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
}

extension FirstViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension FirstViewController {
    
    @objc private func push() {
        
        let secondVC = SecondViewController()
        
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
}

































