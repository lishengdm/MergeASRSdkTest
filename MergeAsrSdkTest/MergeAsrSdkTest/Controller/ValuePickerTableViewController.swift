//
//  ValuePickerTableViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/2/5.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit

enum SettingType {
    case SettingTypeDomain
    case SettingTypeSampleRate
    case SettingTypeNumber
}

var KEY_TEST_DOMAIN: String = "test_domain"
var KEY_TEST_SAMPLE_RATE: String = "test_sample_rate"
var KEY_TEST_NUMBER: String = "test_number"

let TEST_SAMPLE_RATE_VALUE_ARRAY: [Int] = [8000, 16000, 0]
let TEST_SAMPLE_RATE_NAME_ARRAY: [String] = ["8k", "16k", "8k && 16k"]
let TEST_DOMAIN_VALUE_ARRAY: [Int] = [20000, 10005, 0]
let TEST_DOMAIN_DETAIL_ARRAY: [String] = ["输入法", "搜索", "垂类"]
let TEST_DOMAIN_NAME_ARRAY: [String] = ["input, 测试集最大1000", "search,测试集最大100", "domain,测试集最大182，只采样率只能选择16k"]

class ValuePickerTableViewController: UITableViewController, UITextFieldDelegate {
    
    // constants definition
    let TABLE_SECTION_NUMBER = 1
    
    enum CellType {
        case Picker
        case Editor
    }
    
    let SETTING_CELL_DIC:[SettingType: CellType] = [.SettingTypeNumber: .Editor, .SettingTypeSampleRate: .Picker, .SettingTypeDomain: .Picker];
    
    var currentSettingType: SettingType = SettingType.SettingTypeDomain
    var currentValueArray: [Int]?
    var currentNameArray: [String]?
    var lastSelectCellIndexPath: NSIndexPath? = nil
    var currentCell: UITableViewCell!
    
    override func viewDidLoad() {}
    
    func setSettingType(type: SettingType) {
        currentSettingType = type
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getCellType(settingType: SettingType) -> CellType {
        return SETTING_CELL_DIC[settingType]!
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return TABLE_SECTION_NUMBER
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var rowCount: Int
        switch currentSettingType {
        case .SettingTypeDomain:
            rowCount = TEST_DOMAIN_VALUE_ARRAY.count
        case .SettingTypeNumber:
            rowCount = 1
        case .SettingTypeSampleRate:
            rowCount = TEST_SAMPLE_RATE_VALUE_ARRAY.count
        default:
            break
        }
        return rowCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch currentSettingType {
        case .SettingTypeDomain:
            cell = tableView.dequeueReusableCellWithIdentifier("cell_value_picker", forIndexPath: indexPath) as UITableViewCell
            currentNameArray = TEST_DOMAIN_NAME_ARRAY
            currentValueArray = TEST_DOMAIN_VALUE_ARRAY
            cell.textLabel?.text = currentNameArray![indexPath.row]
        case .SettingTypeSampleRate:
            cell = tableView.dequeueReusableCellWithIdentifier("cell_value_picker", forIndexPath: indexPath) as UITableViewCell
            currentNameArray = TEST_SAMPLE_RATE_NAME_ARRAY
            currentValueArray = TEST_SAMPLE_RATE_VALUE_ARRAY
            cell.textLabel?.text = currentNameArray![indexPath.row]
        case .SettingTypeNumber:
            var tcell: SingleEditorTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell_value_editor", forIndexPath: indexPath) as SingleEditorTableViewCell
            tcell.textViewTestNumber.delegate = self
            cell = tcell
        default:
            // not gonna be here
            break
        }
        
        currentCell = cell;
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch getCellType(currentSettingType) {
        case .Editor:
            break
        case .Picker:
            // get current cell
            var currentCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            if lastSelectCellIndexPath != nil {
                // if click a none type cell, the previous checked item shoule be unchecked
                if currentCell.accessoryType == UITableViewCellAccessoryType.None {
                    var lastCell: UITableViewCell = tableView.cellForRowAtIndexPath(lastSelectCellIndexPath!)!
                    lastCell.accessoryType = UITableViewCellAccessoryType.None
                    currentCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
                // no matter what, we should update the value of lastSelectCellIndexPath
                lastSelectCellIndexPath = indexPath
            } else {
                // lastSelectCellIndexPath is null, means user first click one cell
                lastSelectCellIndexPath = indexPath
                currentCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
            // get userDefault
            var userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            // set value to userDefault
            switch currentSettingType {
            case .SettingTypeDomain:
                userDefault.setInteger(TEST_DOMAIN_VALUE_ARRAY[indexPath.row], forKey:KEY_TEST_DOMAIN)
            case .SettingTypeSampleRate:
                userDefault.setInteger(TEST_SAMPLE_RATE_VALUE_ARRAY[indexPath.row], forKey:KEY_TEST_SAMPLE_RATE)
            default:
                break
            }
        default:
            break
        }
    }

    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard(currentSettingType, withCell: currentCell)
        return false
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        dismissKeyboard(currentSettingType, withCell: currentCell)
    }
    
    func dismissKeyboard(settingType: SettingType, withCell: UITableViewCell) {
        if getCellType(settingType) == CellType.Editor {
            if let cell = withCell as? SingleEditorTableViewCell {
                cell.textViewTestNumber.resignFirstResponder()
                var userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                if let number = cell.textViewTestNumber.text.toInt() {
                    userDefault.setInteger(number, forKey: KEY_TEST_NUMBER)
                } else {
                    userDefault.setInteger(0, forKey: KEY_TEST_NUMBER)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
