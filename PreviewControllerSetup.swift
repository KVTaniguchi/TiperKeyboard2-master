//
//  PreviewControllerSetup.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 7/4/16.
//  Copyright © 2016 Kevin Taniguchi. All rights reserved.
//

import Foundation

extension PreviewViewController {
    func setUpUIElements() {
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height - (self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height))
        scrollView.delegate = self
        view.addSubview(scrollView)
        containerView.frame = scrollView.bounds
        scrollView.addSubview(containerView)
        
        layout.minimumInteritemSpacing = 2.0
        layout.minimumLineSpacing = 2.0
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        guard let cv = collectionView else { return }
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.clear
        cv.contentInset = UIEdgeInsets(top: 0, left: 1.5, bottom: 0, right: 0)
        cv.register(PreviewCell.self, forCellWithReuseIdentifier: "buttonCell")
        cv.delegate = self
        cv.dataSource = self
        cv.contentSize = CGSize(width: view.frame.width - 30, height: 260)
        containerView.addSubview(cv)
        
        defaultTextLabel.text = "Add keys by pressing the + Button in the upper right corner."
        defaultTextLabel.isHidden = count > 1
        instructionalLabel.text = "Tap a key to see what it will type for you.  Press, hold, & drag to move it.  Press + to add more keys."
        
        _ = [defaultTextLabel, instructionalLabel].map { label -> UILabel in
            label.numberOfLines = 0
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            label.preferredMaxLayoutWidth = self.view.frame.width
            label.lineBreakMode = .byWordWrapping
            label.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(label)
            return label
        }
        
        NSLayoutConstraint.activate([NSLayoutConstraint(item: defaultTextLabel, attribute: .centerX, relatedBy: .equal, toItem:containerView, attribute: .centerX, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: defaultTextLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 120)])
        
        _ = [textFieldOne, textFieldTwo, textFieldThree].map { textField -> UITextField in
            textField.backgroundColor = UIColor.darkGray
            textField.textColor = UIColor.white
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.delegate = self
            textField.autocorrectionType = .no
            textField.borderStyle = UITextBorderStyle.roundedRect
            textField.isUserInteractionEnabled = false
            textField.textAlignment = .center
            textField.returnKeyType = UIReturnKeyType.done
            self.containerView.addSubview(textField)
            return textField
        }
        
        _ = [textFieldTwo, textFieldOne, deleteKeysButton].map{$0.alpha = 0}
        _ = [textFieldTwo, textFieldOne, deleteKeysButton].map{$0.isHidden = true}
        _ = [editKeysButton, deleteKeysButton, questionButton].map { button -> UIButton in
            button.layer.cornerRadius = 5
            button.setTitleColor(self.view.tintColor, for: UIControlState())
            button.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(button)
            return button
        }
        
        editKeysButton.setTitle("Edit Keys", for: UIControlState())
        editKeysButton.addTarget(self, action: #selector(PreviewViewController.editButtonPressed), for: .touchUpInside)
        deleteKeysButton.setTitle("Delete", for: UIControlState())
        deleteKeysButton.addTarget(self, action: #selector(PreviewViewController.deleteButtonPressed), for: .touchUpInside)
        questionButton.setTitle("?", for: UIControlState())
        questionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        questionButton.addTarget(self, action: #selector(PreviewViewController.questionButtonPressed), for: .touchUpInside)
        
        deleteButton.setTitle("del", for: UIControlState())
        deleteButton.backgroundColor = UIColor.black
        nextKBButton.backgroundColor = UIColor.lightGray
        nextKBButton.setImage(UIImage(named: "keyboard-75"), for: UIControlState())
        _ = [deleteButton, nextKBButton].map{ button -> UIButton in
            button.layer.cornerRadius = 5
            button.translatesAutoresizingMaskIntoConstraints = false
            button.clipsToBounds = true
            self.containerView.addSubview(button)
            return button
        }

    }
    
    func setUpLayout() {
        let metrics = ["cvH":UIScreen.main.bounds.height < 600 ? 200 : 260, "padding":UIScreen.main.bounds.height < 600 ? 20 : 50]
        let views = ["tfThree":textFieldThree,"tfTwo":textFieldTwo, "tfOne":textFieldOne, "edit":editKeysButton, "cv":collectionView!, "instrLab":instructionalLabel, "delete":deleteKeysButton, "question":questionButton, "nextKB":nextKBButton, "del":deleteButton]
        
        expandedVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv(240)]-padding-[tfOne(44)]-[tfTwo(44)]-[instrLab]-[edit]-[question]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views:views)
        expandedHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[question(100)]-(>=1)-[delete(100)]-|", options: .alignAllCenterY, metrics: metrics, views: views)
        compactVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv(240)]-padding-[tfThree(44)]-padding-[instrLab]-15-[edit]-30-[question]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: metrics, views:views)
        NSLayoutConstraint.activate(compactVConstraints)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[instrLab]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views:views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views:views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[edit(160)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: editKeysButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: nextKBButton, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1.0, constant: 1)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: nextKBButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 40)])
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[del(40)][nextKB(40)]-15-|", options: [.alignAllCenterY, NSLayoutFormatOptions.alignAllTop, NSLayoutFormatOptions.alignAllBottom], metrics: nil, views: views))
        
        _ = [textFieldThree, textFieldTwo, textFieldOne].map{NSLayoutConstraint.activate([NSLayoutConstraint(item: $0, attribute: .left, relatedBy: .equal, toItem: self.instructionalLabel, attribute: .left, multiplier: 1.0, constant: 0)])}
        _ = [textFieldThree, textFieldTwo, textFieldOne].map{NSLayoutConstraint.activate([NSLayoutConstraint(item: $0, attribute: .right, relatedBy: .equal, toItem: self.instructionalLabel, attribute: .right, multiplier: 1.0, constant: 0)])}
    }
}
