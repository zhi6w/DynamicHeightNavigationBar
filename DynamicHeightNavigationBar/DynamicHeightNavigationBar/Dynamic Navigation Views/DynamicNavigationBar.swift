//
//  DynamicNavigationBar.swift
//  DynamicHeightNavigationBar
//
//  Created by Zhi Zhou on 2019/8/26.
//  Copyright © 2019 Zhi Zhou. All rights reserved.
//

import UIKit

open class DynamicNavigationBar: UINavigationBar {
    
    /// 导航栏自定义内容视图的显示模式
    public enum ContentViewDistributionMode: Int, CaseIterable {
        
        /// 继续添加新的视图
        case new = 0
        
        /// 覆盖老的视图
        case replace = 1
    }
    
    /// 导航栏自定义内容视图的布局约束对齐模式
    public enum ContentViewAlignment: Int, CaseIterable {
        
        /// 填充
        case fill = 0
        
        /// 居中
        case center = 1
    }
    
    public let effectView = UIVisualEffectView()
        
    open var effect: UIVisualEffect? {
        didSet {
            effectView.effect = effect
        }
    }
    
    public let contentView = UIView()
    
    /// NavgationBar 阴影分割线
    private let backgroundShadowView = DynamicBarBackgroundShadowView()
        
    open var shadowColor: UIColor? {
        didSet {
            backgroundShadowView.backgroundColor = shadowColor
        }
    }
    
    open var isHiddenBackgroundShadowView: Bool = false {
        didSet {
            backgroundShadowView.isHidden = isHiddenBackgroundShadowView
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
                
        var constant: CGFloat = 0
        if #available(iOS 13.0, *) {
            constant = -(UIApplication.shared.statusBarManager?.statusBarFrame.height ?? 0)
        } else {
            constant = -UIApplication.shared.statusBarFrame.height
        }
        
        effectViewTopLayoutConstraint?.constant = constant
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
        setupBackgroundShadowView()
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
        
    private func setupBackgroundShadowView() {
        
        addSubview(backgroundShadowView)
        
        backgroundShadowView.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            backgroundShadowView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundShadowView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundShadowView.topAnchor.constraint(equalTo: contentView.bottomAnchor)
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
                        
        effectViewTopLayoutConstraint = NSLayoutConstraint(item: effectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
                
        NSLayoutConstraint.activate([
            effectView.leftAnchor.constraint(equalTo: self.leftAnchor),
            effectView.rightAnchor.constraint(equalTo: self.rightAnchor),
            effectViewTopLayoutConstraint!,
            effectView.bottomAnchor.constraint(equalTo: backgroundShadowView.topAnchor)
        ])
    }
    
}

extension DynamicNavigationBar {
    
    /// 设定 contentView 高度
    /// - 高度设定必须在 UIViewController 的 viewWillAppear(_ animated: Bool) 方法内执行。
    public func setContentViewHeight(_ height: CGFloat) {
        contentViewHeightLayoutConstraint?.constant = height
    }
    
    public func addContentSubview(_ view: UIView) {
        
        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.heightAnchor.constraint(equalToConstant: view.bounds.height)
        ])
    }

}

fileprivate extension UIColor {
    
    /// 灰色阴影
    static var chromeShadowColor: UIColor {
        
        guard let systemChromeShadowColor = UIColor.value(forKey: "_systemChromeShadowColor") as? UIColor
        else {
            if #available(iOS 13.0, *) {
                return UIColor(dynamicProvider: { $0.userInterfaceStyle == .dark ? .init(white: 1, alpha: 0.15) : .init(white: 0, alpha: 0.3) })
            } else {
                return .init(white: 0, alpha: 0.3)
            }
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        systemChromeShadowColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

fileprivate extension UIApplication {
    
    @available(iOS 13.0, *)
    var statusBarManager: UIStatusBarManager? {
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        
        return keyWindow?.windowScene?.statusBarManager
    }
    
}

