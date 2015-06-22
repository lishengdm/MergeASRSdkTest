//
//  SettingTableViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/5.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    // ui ref
    @IBOutlet var CellTestSampleRate: UITableViewCell!
    @IBOutlet var CellTestDomain: UITableViewCell!
    @IBOutlet var CellTestNumber: UITableViewCell!
    
    // constants defination
    let TEST_CONFIG_TYPE_NUMBER: Int = 1
    let TEST_CONFIG_ITEM_NUMBER: Int = 3
    let INDEX_CONTROLLER_DIC: [Int: DestControllertType] = [0: .TypeValueEdit, 1: .TypeValuePicker, 2: .TypeValuePicker]
    
    // segue destinationViewController type define
    enum DestControllertType {
        case TypeValuePicker
        case TypeValueEdit
    }
    
    // property define
    var mCurrentDestControllerType: DestControllertType = .TypeValueEdit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        setDetails()
    }
    
    func setDetails() {
        var userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let number = userDefault.valueForKey(KEY_TEST_NUMBER) as? Int {
            CellTestNumber.detailTextLabel?.text = String(number)
        }
        
        if let domain = userDefault.valueForKey(KEY_TEST_DOMAIN) as? Int {
            CellTestDomain.detailTextLabel?.text = TEST_DOMAIN_DETAIL_ARRAY[find(TEST_DOMAIN_VALUE_ARRAY, domain)!]
        }
        
        if let sample_rate = userDefault.valueForKey(KEY_TEST_SAMPLE_RATE) as? Int {
            CellTestSampleRate.detailTextLabel?.text = TEST_SAMPLE_RATE_NAME_ARRAY[find(TEST_SAMPLE_RATE_VALUE_ARRAY, sample_rate)!]
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var valuePickerController: ValuePickerTableViewController = segue.destinationViewController as! ValuePickerTableViewController
        var settingType: SettingType?
        switch(segue.identifier!) {
        case "test_domain":
            settingType = .SettingTypeDomain
        case "test_sample_rate":
            settingType = .SettingTypeSampleRate
        case "test_number":
            settingType = .SettingTypeNumber
        default:
            // do nothing
            break
        }
        valuePickerController.setSettingType(settingType!)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return TEST_CONFIG_TYPE_NUMBER
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return TEST_CONFIG_ITEM_NUMBER
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("test_list_item", forIndexPath: indexPath) as UITableViewCell
//
//        cell.detailTextLabel?.text = "hahah"
//        return cell
//    }
    
}
