//
//  ZeroViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2020/7/29.
//  Copyright © 2020 Zhi Zhou. All rights reserved.
//

import UIKit

class ZeroViewController: UIViewController {
    
    private let tableView = UITableView()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension ZeroViewController {
    
    private func setupInterface() {
        
        title = "Zero"
        view.backgroundColor = .purple
        
        setupNavBar()
        setupTableView()
    }
    
    private func setupNavBar() {
        
        // 修复在 iOS 13 下，滑动返回取消后，navigationItem 中的 UIBarButtonItem 图标透明度变淡的问题。
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "play.fill")
            let pushButton = UIButton(type: .system)
            pushButton.setImage(image, for: .normal)
            pushButton.addTarget(self, action: #selector(push(_:)), for: .touchUpInside)
            
            let pushItem = UIBarButtonItem(customView: pushButton)
            
            navigationItem.rightBarButtonItem = pushItem
        } else {
            let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push(_:)))
            
            navigationItem.rightBarButtonItem = pushItem
        }
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

extension ZeroViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension ZeroViewController {
    
    @objc private func push(_ item: UIBarButtonItem) {
        let firstVC = FirstViewController()
        navigationController?.pushViewController(firstVC, animated: true)
    }
    
}
































