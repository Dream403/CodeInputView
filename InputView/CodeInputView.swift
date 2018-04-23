//
//  CodeInputView.swift
//  InputView
//
//  Created by snowlu on 2018/4/19.
//  Copyright © 2018年 LittleShrimp. All rights reserved.
//

import UIKit
import Foundation
@objc public protocol CodeInputViewDelegate : NSObjectProtocol{
    
  @objc  optional  func codeInput(_ codeInputView: CodeInputView)
}

open class CodeInputView: UIView ,UITextFieldDelegate{
  
   @objc   open weak var  delegate: CodeInputViewDelegate?
    
   @objc  open  var text:NSString?{
        get{
            return self.inputStr
        }
    }
    @objc  open var showCursor:Bool =  false {
        didSet {
            cursor.isHidden = !showCursor;
        }
    }
    
   @objc   open var codeKeyboardType:UIKeyboardType = UIKeyboardType.numberPad
    
   @objc   open var length:Int = 4 ;
    
    private  var inputStr:NSString? = ""{

        didSet {
            self.setNeedsDisplay();
        }
    }
    @objc open var cursorHieght: CGFloat = 20;
    
    @objc open var cursorWidth: CGFloat  = 2;
    
    @objc open var cursorColor: UIColor  = UIColor.black;
    
    @objc open var textColor: UIColor  = UIColor.black;
    
    @objc open var secureColor: UIColor  = UIColor.black;
    
    @objc open var secureTextEntry: Bool  = false;
    
    @objc open var font: UIFont  = UIFont.systemFont(ofSize: 14);
    
    @objc open var bottomSpace: CGFloat  = 10;
    
    @objc open var bottomLineMargin: CGFloat  = 10;
    
    @objc open var bottomLineHeight: CGFloat  = 2;
    
    @objc open var bottomLineColor: UIColor  = UIColor.black;
    
    private   lazy var cursor :UIImageView = {
        
      let cursor = UIImageView.init(frame:CGRect(x: 0, y: 0, width: cursorWidth, height: cursorHieght));
        
        cursor.backgroundColor  = UIColor.black;
        
        cursor.isHidden  = true;
        
        cursor.layer.masksToBounds  = true;
        
        cursor.layer.cornerRadius  = cursorWidth  * 0.5;
        
        cursor.backgroundColor = cursorColor;
        
        return cursor;
        
    }();
    private lazy var  textField:UITextField = { [unowned self] in
    
        let textField = UITextField.init();
        
        textField.keyboardType = codeKeyboardType;
        
        textField.isHidden = true;
        
        textField.delegate  = self;
        
        textField.returnKeyType = UIReturnKeyType.done;
        textField.backgroundColor = UIColor.red;
        textField.addTarget(self, action:#selector(textChanged), for:.editingChanged);
        
        return textField;
    }();
    
    private lazy var tap:UITapGestureRecognizer = {[unowned self]in
      
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))

        return tap;
        
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
        setupSubViews()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CodeInputView{
    
    open override var canBecomeFirstResponder: Bool{
        
        return  true ;
    }

    public func becomeResponder(){
        
        textField.becomeFirstResponder();
    }
    open override func draw(_ rect: CGRect) {
        super.draw(rect);
        drawBottomLineWithRect(rect: rect);
      
        drawCursorWithRect(rect: rect);
        
        guard self.secureTextEntry else {
            drawTextWithRect(rect: rect);
            return;
        }
        drawSecureTextWithRect(rect: rect);
    }
}

//textFieldDelegate
  extension  CodeInputView{
    
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField .resignFirstResponder();
        return  true;
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        guard self.showCursor else {return}
        guard self.inputStr!.length > self.length else {
            self.cursor.isHidden  = false;
            return;}
        self.cursor.isHidden  = true;
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard self.showCursor else {
            return;
        }
         self.cursor.isHidden = true;
    }

    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = NSString.init(string: textField.text!);
        
        let temp = text .replacingCharacters(in: range, with: string);
        
        self.inputStr = NSString.init(string: temp);
        
        guard temp.count <= self.length else {
            return false;
        }
        if self.showCursor {
        guard self.inputStr!.length < self.length else {
            self.cursor.isHidden = true;
            textField .resignFirstResponder();
                return true;
            }
            self.cursor.isHidden = false;
        }
        return true;
    }
}
// draw
private extension CodeInputView{
    

    func drawTextWithRect(rect:CGRect) {
        
        let Margin  = bottomLineMargin * (CGFloat(length - 1));
        
        let width  = CGFloat(floorf(Float(rect.size.width - Margin)))/CGFloat(length);
        
        let lengthString = inputStr?.length;
        
        for i  in  0..<lengthString! {
            
            let str  =  inputStr!.character(at: i);
            
            let unicharString = UnicodeScalar.init(str.hashValue);

            let  cstring = NSString.init(string: (unicharString?.description)!);
            
            let  attributeDict: [NSAttributedStringKey : Any] = [
                .font: font,
                .foregroundColor: textColor,
                ];
            let size = cstring.size(withAttributes: attributeDict);

            let x = CGFloat(i) * (width + bottomLineMargin) + (width - size.width)/CGFloat(2.0) ;

            let y   = rect.size.height - bottomLineHeight - bottomSpace - size.height;

            let point = CGPoint.init(x:x , y:y );

            cstring .draw(at: point, withAttributes: attributeDict)
            
        }
        
    }
    
    
    func drawSecureTextWithRect(rect:CGRect) {
        
        let Margin  = bottomLineMargin * (CGFloat(length - 1));
        
        let width  = CGFloat(floorf(Float(rect.size.width - Margin)))/CGFloat(length);
        
        let lengthString = inputStr?.length;
        
        for i  in  0..<lengthString! {
            
            let context = UIGraphicsGetCurrentContext();
            
            let x = CGFloat(i) * (width + bottomLineMargin) + (width - 8)/CGFloat(2.0) ;
            
            let y   = rect.size.height - bottomLineHeight - self.bottomSpace - 8;
            
            let drawRect = CGRect.init(x: x, y: y, width: 8, height: 8)
            
            context?.addEllipse(in:drawRect);
            
            context?.setFillColor(secureColor.cgColor);
            
            context?.fillPath();
            
        }
        
    }
    
    func drawBottomLineWithRect(rect:CGRect) {
        
        let Margin  = bottomLineMargin * (CGFloat(length - 1));
        
        let width  = CGFloat(floorf(Float(rect.size.width - Margin)))/CGFloat(length);
        
        for i  in  0..<length {
            
            let context = UIGraphicsGetCurrentContext();
            
            let x = CGFloat(i) * (width + bottomLineMargin);
            
            let y   = rect.size.height - bottomLineHeight;
            
            let drawRect = CGRect.init(x: x, y: y, width: width, height: bottomLineHeight)
            
            context?.addRect(drawRect);
            
            context?.setFillColor(bottomLineColor.cgColor);
            
            context?.setLineJoin(CGLineJoin.round);
            
            context?.fillPath();
            
        }
        
    }
    
    func drawCursorWithRect(rect:CGRect){
        guard self.showCursor else {
            return;
        }
        guard (inputStr?.length)! < length else {
            return;
        }
        let Margin  = bottomLineMargin * (CGFloat(length - 1));
        
        let width  = CGFloat(floorf(Float(rect.size.width - Margin)))/CGFloat(length);
        
        let index  = (inputStr?.length)!;
        
        let centerX = CGFloat( index ) * (width + bottomLineMargin ) + width / 2.0 ;
        
        let  cstring = NSString.init(string: inputStr!);
        
        let  attributeDict: [NSAttributedStringKey : Any] = [
            .font: font,
            .foregroundColor: textColor,
            ];
        let size = cstring.size(withAttributes: attributeDict);

        let  centerY = rect.size.height -  bottomLineHeight - bottomSpace  - size.height/2.0;
        
        cursor.center = CGPoint.init(x: centerX, y: centerY);
    }
    
}

//私有方法 初始化

 private extension CodeInputView {
    
    func setupSubViews()  {
    
        self.addSubview(textField);
        self.addGestureRecognizer(tap);
        self.addSubview(cursor);
    
        self.backgroundColor = UIColor.white;
        
    }

    func cursorAnimation()  {
    
        let  cursorAni = CAKeyframeAnimation.init(keyPath: "opacity");
        
        cursorAni.values  = [1,0,0,1,1];
        
        cursorAni.keyTimes  = [0,0.3,0.6,0.9,1];
        
        cursorAni.duration  = 1 ;
        
        cursorAni.calculationMode  = kCAAnimationLinear;
        
        cursorAni.repeatCount  = MAXFLOAT;
        
        cursor.layer .add(cursorAni, forKey: "cursorAni");
        
    }
    @objc  func tapAction()  {
        textField .becomeFirstResponder();
    }
    
    @objc   func textChanged() {
        
        guard let delegate = self.delegate  else {return}
        
        delegate.codeInput!(self);
        
    }
}

