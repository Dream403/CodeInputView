//
//  ViewController.swift
//  InputView
//
//  Created by snowlu on 2018/4/19.
//  Copyright © 2018年 LittleShrimp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        let inputView = CodeInputView.init(frame: CGRect(x: 0, y: 100, width:UIScreen.main.bounds.width, height: 50));
        
        inputView.showCursor  = true;
        inputView.length = 6;
        
        self.view.addSubview(inputView);
        
        inputView.canBecomeFirstResponder;
    
        
        print("\(inputView.text!)");
        
        inputView.becomeResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

