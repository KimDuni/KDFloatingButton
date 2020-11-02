//
//  KDFloatingCell.swift
//  ChatApp
//
//  Created by 성준 on 2020/11/02.
//  Copyright © 2020 성준. All rights reserved.
//

protocol KDFloatingCell: class {
    
    var menuTitle:String! {get set}
    func cellConfiguration()
    func cellConfiguration(title:String)
}
