//
//  KDFloatingMenu.swift
//  ChatApp
//
//  Created by 성준 on 2020/11/02.
//  Copyright © 2020 성준. All rights reserved.
//

import UIKit

class CellView: UIView , KDFloatingCell {
    var menuTitle: String!
    
    func cellConfiguration() {
        
    }
    
    func cellConfiguration(title: String) {
        
    }
}

protocol KDFloatingDelegate : class {
    func floatingMenu(_ floatingMenu:KDFloatingMenu, didSelectRowAt index:Int)
}

class KDFloatingMenu: UIView {
    
    var menu:[String]!
    var layerRadius:CGFloat = 0.0
    var menuSpacing:CGFloat = 0.0
    var menuBackgroundColor:UIColor = .blue
    var useAnimation:Bool = true
    
    weak var delegate:KDFloatingDelegate?
    
    private let menuButtonHeight:CGFloat = 40.0
    
    private let animationDuration:TimeInterval = 0.2
    private var viewFold:Bool = false
    private var currentMenuIndex:Int = 0
    
    private var menuVStackView:UIStackView!
    private var showTouchView:UIView!
    private var showLabel:UILabel!
    private var cell:[UIView]?
    
    
    var openFoldBounds:CGSize {
        return CGSize(width: self.bounds.width, height: self.menuButtonHeight * CGFloat(menu.count))
    }
    
    var originFrame:CGRect {
        return CGRect(origin: CGPoint(x: self.frame.origin.x, y: self.frame.origin.y + self.menuButtonHeight), size: CGSize(width: self.bounds.width, height: 0))
    }
    
    var openFrame:CGRect {
        return CGRect(origin: CGPoint(x: self.frame.origin.x, y: self.frame.origin.y + self.menuButtonHeight), size: openFoldBounds)
    }
    
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        backgroundColor = self.menuBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.clipsToBounds = false
        backgroundColor = self.menuBackgroundColor
    }
    
    convenience init(menus:[String]) {
        self.init()
        self.menu = menus
        configurationDefaultLayer()
    }
    
    convenience init(menus:[String], frame:CGRect) {
        self.init(frame: frame)
        self.menu = menus
        configurationDefaultLayer()
    }
    
    override func draw(_ rect: CGRect) {
        self.clipsToBounds = false
        configurationDefaultLayer()
    }
    
    // MARK: -
    func configurationDefaultLayer(){
        
        layer.cornerRadius = self.layerRadius
        backgroundColor = self.menuBackgroundColor
        
        if self.showTouchView != nil {
            self.showTouchView.removeFromSuperview()
            self.showTouchView = nil
        }
        
        self.showTouchView = UIView()
        self.showTouchView.backgroundColor = .red
        self.addSubViewAndFill(subView: showTouchView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(foldMenus))
        self.showTouchView.addGestureRecognizer(tap)
        
        self.showLabel = UILabel()
        self.showLabel.text = menu[currentMenuIndex]
        self.addSubViewAndFill(subView: showLabel)
    }
    
    @objc func foldMenus(){
        
        self.viewFold.toggle()
        if self.viewFold {
            open()
        } else {
            close()
        }
    }
    
    func open() {
        self.viewFold = true
        setupMenuStackView()
        
        self.menuVStackView.frame = originFrame
        self.layoutIfNeeded()
        UIView.animate(withDuration: animationDuration) { [weak self] in
            if let weakSelf = self {
                weakSelf.menuVStackView.frame = weakSelf.openFrame
                weakSelf.layoutIfNeeded()
            }
        }
    }
    
    func setupMenuStackView(){
        
        self.menuVStackView = UIStackView(frame: openFrame)
        self.menuVStackView.backgroundColor = .yellow
        self.menuVStackView.axis = .vertical
        self.menuVStackView.distribution = .fillEqually
        self.superview?.addSubview(self.menuVStackView)
        
        for (index, title) in menu.enumerated() {
            if index == currentMenuIndex {
                continue
            }
            
            let view = getStackItem(index: index) //CellView() // // UIView()
            view.tag = index
            view.isUserInteractionEnabled = true
            menuVStackView.addArrangedSubview(view)

            let v =  view as! KDFloatingCell
            v.cellConfiguration(title: title)
            
            let button = UIButton()
            button.tag = index
            button.titleLabel?.text = nil
            button.addTarget(self, action: #selector(onTapMenu(sender:)), for: .touchUpInside)
            view.addSubViewAndFill(subView: button)
        }
    }
    
    func getStackItem(index:Int) -> UIView{
        if cell != nil {
            return cell![index]
        }else{
            return CellView()
        }
    }
    
    func close(){
        
        self.viewFold = false
        if useAnimation {
            
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                if let weakSelf = self {
                    weakSelf.menuVStackView.frame = weakSelf.originFrame
                    weakSelf.layoutIfNeeded()
                }
            }) { (b) in
                
                DispatchQueue.main.async { [weak self] in
                    self?.menuVStackView.removeFromSuperview()
                    self?.configurationDefaultLayer()
                }
            }
            
        } else {
            self.menuVStackView.frame = originFrame
            self.menuVStackView.removeFromSuperview()
            self.configurationDefaultLayer()
        }
    }

    @objc func onTapMenu(sender:UIButton){

        currentMenuIndex = sender.tag
        self.close()
        self.configurationDefaultLayer()
        self.delegate?.floatingMenu(self, didSelectRowAt: currentMenuIndex)
    }
    
    func registerCell(cells:[UIView]){
        self.cell = cells
    }
}

extension UIView {
    
    func addSubViewAndFill(subView:UIView){
        self.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
