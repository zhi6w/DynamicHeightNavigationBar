//
//  FourthViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class FourthViewController: DynamicNavigationRootViewController {
    
    private let seg = UISegmentedControl()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension FourthViewController {
    
    private func setupInterface() {
        view.backgroundColor = .green
        title = "Fourth"

        setupNavBar()
        setupTableView()
    }
    
    private func setupNavBar() {
                                
        seg.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 31)
        
        seg.insertSegment(withTitle: "First", at: 0, animated: false)
        seg.insertSegment(withTitle: "Second", at: 1, animated: false)
        
        seg.selectedSegmentIndex = 1
        
        setNavigationBarContentView(seg)
        
        
        if #available(iOS 13.0, *) {
            let backToRootVCItem = UIBarButtonItem(image: UIImage(systemName: "backward.end.alt.fill"), style: .plain, target: self, action: #selector(backToRootViewController(_:)))
                        
            navigationItem.rightBarButtonItem = backToRootVCItem
        } else {
            let backToRootVCItem = UIBarButtonItem(title: "BackToRoot", style: .plain, target: self, action: #selector(backToRootViewController(_:)))
                        
            navigationItem.rightBarButtonItem = backToRootVCItem
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

extension FourthViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension FourthViewController {
    
    @objc private func backToRootViewController(_ item: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
        
}

































