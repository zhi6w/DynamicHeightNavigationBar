//
//  SecondViewController.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

class SecondViewController: DynamicNavigationRootViewController {
    
    private let toolbar = UIToolbar()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupInterface()
    }

}

extension SecondViewController {
    
    private func setupInterface() {
        view.backgroundColor = .yellow
        title = "Second"
        
        setupNavBar()
        setupNavgationContentView()
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
            
            navigationItem.rightBarButtonItem = pushItem
        } else {
            let pushItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(push))
            
            navigationItem.rightBarButtonItem = pushItem
        }
    }
    
    private func setupNavgationContentView() {

        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 30)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        navigationContentView = toolbar
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

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    
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


extension SecondViewController {
    
    @objc private func push() {
        
        let thirdVC = ThirdViewController()
        
        navigationController?.pushViewController(thirdVC, animated: true)
    }
    
}

extension SecondViewController {
    
    private func loadData() {
        
        let weekTitles = Calendar.current.shortWeekdaySymbols
        
        let items = weekTitles.enumerated().compactMap { (value) -> [UIBarButtonItem]? in
            let button = UIButton()
            
            if #available(iOS 13.0, *) {
                // 当用户使用大字体时，长按会弹出放大展示。
                button.showsLargeContentViewer = true
            }
            
            button.setTitle(value.element, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            
            let item = UIBarButtonItem(customView: button)
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            if value.offset == weekTitles.endIndex - 1 {
                return [flexibleSpace, item, flexibleSpace]
            } else {
                return [flexibleSpace, item]
            }
        }

        toolbar.items = items.joined().compactMap({ return $0 })
    }
    
}

































