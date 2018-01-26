//
//  InformePageViewController.swift
//  Todo
//
//  Created by Siloniz buenito on 1/10/17.
//  Copyright © 2017 Couchbase. All rights reserved.
//

import UIKit

class InformePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{

    var database: CBLDatabase!
    var taskList: CBLDocument!
    
    //weak var informePageDelegate: InformePageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        self.delegate = self
        
        self.title = "Informe Completo"
       
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        
        self.view.backgroundColor = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)
        
        
        let childViewController=storyboard?.instantiateViewController(withIdentifier: "FirstPageViewController") as! FirstPageViewController
            print("TONI -> Paso taskList a FirstPage")
        childViewController.taskList = self.taskList
        
        /*
        if let cid = challengeId{
            print("TONI -> Paso taskList a FirstPage")
            childViewController.challengeId=cid
        }
        */
        // Do any additional setup after loading the view.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // Returns the view controller before the given view controller.
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newPagedViewController(order: "First"),
                self.newPagedViewController(order: "Second"),
                self.newPagedViewController(order: "Third")]
    }()
    
    private func newPagedViewController(order: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(order)PageViewController")
    }
    
    
    //Métodos para poner los puntos al viewController
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        print("TONI -> PageView nº de paginas: \(orderedViewControllers.count)")
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        print("TONI -> PageView entro en el método: presentationIndexForPageViewController")
        guard let firstViewController = viewControllers?.first
        else {
            return 0
        }
        guard let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController)
        else {
            return 0
        }
        
        return firstViewControllerIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIPageViewControllerDataSource
    
    /*
    extension TutorialPageViewController: UIPageViewControllerDataSource {
        
        func pageViewController(pageViewController: UIPageViewController,
                                viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            return nil
        }
        
        func pageViewController(pageViewController: UIPageViewController,
                                viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            return nil
        }
        
    }
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
