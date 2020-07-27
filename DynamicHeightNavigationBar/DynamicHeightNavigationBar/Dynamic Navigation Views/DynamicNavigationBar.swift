//
//  DynamicNavigationBar.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationBar: UINavigationBar {
    
    public let effectView = UIVisualEffectView()
        
    open var effect: UIVisualEffect? {
        didSet {
            effectView.effect = effect
        }
    }
    
    public let contentView = UIView()
    
    /// NavgationBar 分割线
    private let separator = UIView()
        
    open var separatorColor: UIColor? {
        didSet {
            separator.backgroundColor = separatorColor
        }
    }
    
    open var isHiddenSeparator: Bool = false {
        didSet {
            separator.isHidden = isHiddenSeparator
        }
    }
    
    open var contentViewHeightLayoutConstraint: NSLayoutConstraint?
    
    private var effectViewTopLayoutConstraint: NSLayoutConstraint?
    

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupInterface()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupInterface()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
                
        sendSubviewToBack(effectView)
                
        effectViewTopLayoutConstraint?.constant = -UIApplication.shared.statusBarFrame.height
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        // 拦截：超出 navigationBar 视图范围内的子控件（contentView）点击事件
        
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subviewPoint = subview.convert(point, from: self)
            if let view = subview.hitTest(subviewPoint, with: event) {
                return view
            }
        }

        return nil
    }
    
}

extension DynamicNavigationBar {
    
    private func setupInterface() {
        setupContentView()
        setupSeparatorView()
        setupEffectView()
    }
    
    private func setupContentView() {

        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewHeightLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
            contentView.topAnchor.constraint(equalTo: self.bottomAnchor),
            contentViewHeightLayoutConstraint!
        ])
    }
        
    private func setupSeparatorView() {
        
        separator.backgroundColor = UIColor.shadowColor

        addSubview(separator)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            separator.leftAnchor.constraint(equalTo: self.leftAnchor),
            separator.rightAnchor.constraint(equalTo: self.rightAnchor),
            separator.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }
    
    private func setupEffectView() {
        
        if #available(iOS 13.0, *) {
            effectView.effect = UIBlurEffect(style: .systemMaterial)
        } else {
            effectView.effect = UIBlurEffect(style: .extraLight)
        }
        
        insertSubview(effectView, at: 0)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
                
        var constant: CGFloat = 0
        if #available(iOS 13.0, *) {
            constant = -(UIApplication.shared.statusBarManager?.statusBarFrame.height ?? 0)
        } else {
            constant = -UIApplication.shared.statusBarFrame.height
        }
        
        effectViewTopLayoutConstraint = NSLayoutConstraint(item: effectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: constant)
                
        NSLayoutConstraint.activate([
            effectView.leftAnchor.constraint(equalTo: self.leftAnchor),
            effectView.rightAnchor.constraint(equalTo: self.rightAnchor),
            effectViewTopLayoutConstraint!,
            effectView.bottomAnchor.constraint(equalTo: separator.topAnchor)
        ])
    }
    
}

extension DynamicNavigationBar {
    
    /// 设定 contentView 高度
    /// - 高度设定必须在 UIViewController 的 viewWillAppear(_ animated: Bool) 方法内执行。
    open func setContentViewHeight(_ height: CGFloat) {
        contentViewHeightLayoutConstraint?.constant = height
    }
    
    open func addContentSubview(_ view: UIView) {
        
        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            view.heightAnchor.constraint(equalToConstant: view.bounds.height)
        ])
    }
    
}

fileprivate extension UIColor {
    
    /// 分割线颜色
    static var shadowColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(white: 1, alpha: 0.15)
                } else {
                    return UIColor(white: 0, alpha: 0.3)
                }
            }
        } else {
            return UIColor(white: 0, alpha: 0.3)
        }
    }
    
}

fileprivate extension UIApplication {
    
    @available(iOS 13.0, *)
    var statusBarManager: UIStatusBarManager? {
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        
        return keyWindow?.windowScene?.statusBarManager
    }
    
}

