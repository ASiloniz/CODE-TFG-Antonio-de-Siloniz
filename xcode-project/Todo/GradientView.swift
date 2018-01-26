//
//  CitiesTableViewController.swift
//  El Vuelo del Grajo
//
//  Created by Santiago Pavón on 7/12/14.
//  Copyright (c) 2014 UPM. All rights reserved.
//


@IBDesignable class GradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.white
    @IBInspectable var secondColor: UIColor = UIColor.black
    

    /*
    func hexStringToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )

    
    }
    */
    
    func viewGradiente(rect: CGRect) -> CAGradientLayer {
        //http://uicolor.xyz/#/hex-to-ui
        
        let gradientLayer = CAGradientLayer()
        
        let firstColor = UIColor(red:0.76, green:0.22, blue:0.39, alpha:1.0)
        let secondColor = UIColor(red:0.11, green:0.15, blue:0.44, alpha:1.0)
        
        //gradientLayer.colors = [UIColor.blue.cgColor, UIColor.lightGray.cgColor]
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.frame = rect
        /*
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        */
        
        //gradientLayer.frame = cell.bounds
        
        //gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        
        
        //cell.sendSubview(toBack: gradientLayer)
        //cell.layer.addSublayer(gradientLayer)
        
        
        //cell.layer.addSublayer(gradientLayer)
        
        //cell.layer.zPosition = 0
        
        
        
        /* TONI -> Pone la mitad de la celda amarilla y la otra mitad roja
         
         cell.backgroundColor = UIColor.clear
         
         if cell.backgroundView == nil {
         
         let leftView = UIView()
         let rightView = UIView()
         rightView.backgroundColor = UIColor.red
         leftView.backgroundColor = UIColor.yellow
         cell.backgroundView = UIView()
         cell.backgroundView?.addSubview(leftView)
         cell.backgroundView?.addSubview(rightView)
         leftView.translatesAutoresizingMaskIntoConstraints = false;
         rightView.translatesAutoresizingMaskIntoConstraints = false;
         
         let viewDict = ["leftView":leftView, "rightView":rightView]
         
         cell.backgroundView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[leftView]-0-|", options: [], metrics: nil, views: viewDict))
         cell.backgroundView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[rightView]-0-|", options: [], metrics: nil, views: viewDict))
         
         cell.backgroundView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[leftView]-0-[rightView(==leftView)]-0-|", options: [], metrics: nil, views: viewDict))
         
         }
         */
        
        return gradientLayer
    }

}



