//
//  DetailResultViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/7.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

class DetailResultViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!
    var pageTitles: [String]!
    var pageValues: [[Double]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initPageViewController()
    }
    
    func initPageViewController() {
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail_stat_page_view_controller") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        var startVC = self.pageViewAtIndex(0)
        var viewControllers = [startVC]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 20, self.view.frame.width, self.view.frame.height-40)
        
        println(self.view.frame)
        
        self.addChildViewController(self.pageViewController)
        println(self.pageViewController.view.frame)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)      
    }
    
    func pageViewAtIndex(index: Int) -> DetailStatViewController{
        if (self.pageTitles.count == 0 || index >= self.pageTitles.count) {
            return DetailStatViewController()
        }
        
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("detail_result_view_controller") as! DetailStatViewController
        
//        vc.mLabelTitle.text = pageTitles[index]
        vc.index = index
        vc.type = pageTitles[index]
        vc.data = pageValues[index]
        
        return vc
    }
    
    // MARK - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! DetailStatViewController
        var index = vc.index as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        return self.pageViewAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! DetailStatViewController
        var index = vc.index as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return self.pageViewAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
