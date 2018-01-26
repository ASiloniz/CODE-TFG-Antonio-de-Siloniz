//
//  ExploraMenuViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 22/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class ExploraMenuViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    
    @IBAction func button1OnClick(_ sender: AnyObject) {
        button1.backgroundColor = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
