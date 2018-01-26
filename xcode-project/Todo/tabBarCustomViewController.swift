//
//  tabBarCustomViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 25/9/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class tabBarCustomViewController: UITabBarController, UITabBarControllerDelegate{

    @IBOutlet weak var tabBarAClickar: UITabBar!
    var database: CBLDatabase!
    var taskList: CBLDocument!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let constantesView = self.viewControllers?[0]
        print("TONI -> TABBAR: ViewController \(constantesView)")
        
        if let tbc = tabBarController as? tabBarCustomViewController{
            let taskList = self.taskList
            print("TONI -> TABBAR: taskList \(taskList)")
        }
        
        self.title = "Exploración Física"
    }

    
    private func tabBarComprobation(tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("TONI -> TABBAR: Test")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // MARK: - Navigation

    /*
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "constantesSegue":
                if let constantesVitalesViewController = segue.destination as? ConstantesVitalesViewController {
                    constantesVitalesViewController.taskList = taskList
                    print("TONI -> Tabbar Segue: \(constantesVitalesViewController.taskList)")
                }
            
                
            default:
                break
            }
            
        }

 
    }
    */

}
