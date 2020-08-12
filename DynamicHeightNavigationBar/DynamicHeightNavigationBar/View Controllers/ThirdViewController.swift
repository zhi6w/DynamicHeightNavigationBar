//
//  ThirdViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class ThirdViewController: DynamicNavigationRootViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }
    
}

extension ThirdViewController {
    
    private func setupInterface() {
        
        view.backgroundColor = .cyan
        title = "Third"
                
        setupNavBar()
        setupTableView()
    }
    
    private func setupNavBar() {
        
        // 修复在 iOS 13 下，滑动返回取消后，navigationItem 中的 UIBarButtonItem 图标透明度变淡的问题。
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "play.fill")
            let pushButton = UIButton(type: .system)
            pushButton.setImage(image, for: .normal)
            pushButton.addTarget(self, action: #selector(push), for: .touchUpInside)
            
            let pushItem = UIBarButtonItem(customView: pushButton)
                        
            let replaceVCsItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle.fill"), style: .plain, target: self, action: #selector(replaceViewControllers(_:)))
            
            navigationItem.rightBarButtonItems = [pushItem, replaceVCsItem]
            
        } else {
            let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push))
            let replaceVCsItem = UIBarButtonItem(title: "Replace", style: .plain, target: self, action: #selector(replaceViewControllers(_:)))
            
            navigationItem.rightBarButtonItems = [pushItem, replaceVCsItem]
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

extension ThirdViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension ThirdViewController {
    
    @objc private func push() {
        
        let fourthVC = FourthViewController()
        
        navigationController?.pushViewController(fourthVC, animated: true)
    }
    
    @objc private func replaceViewControllers(_ item: UIBarButtonItem) {
                
        let vcs = [FourthViewController(), DynamicNavigationRootViewController(), ThirdViewController()]
        navigationController?.setViewControllers(vcs, animated: true)
        
//        let vc = navigationController?.viewControllers[1] ?? UIViewController()
//        navigationController?.popToViewController(vc, animated: true)
    }
    
}



































