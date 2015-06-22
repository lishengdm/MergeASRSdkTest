//
//  DetailStatViewController.swift
//  MergeAsrSdkTest
//
//  Created by 李胜 on 15/6/7.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

import UIKit
import Charts

class DetailStatViewController: UIViewController, ChartViewDelegate {

    @IBOutlet var mLabelTitle: UITextField!
    @IBOutlet var mStatChart: LineChartView!
    
    var index: Int!
    var data: [Double]!
    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mStatChart.delegate = self

        mStatChart.data = generateChartData(self.data)
        mLabelTitle.text = type
    }

    func generateChartData(values: [Double]) -> LineChartData {
        
        var xVals: [String] = []
        var yVals: [ChartDataEntry] = []
        
        for (var i=0; i<values.count; i++) {
            var entry = ChartDataEntry(value: values[i], xIndex: i)
            yVals.append(entry)
            xVals.append(String(i))
        }
        
        var set1 = LineChartDataSet(yVals: yVals, label: type)
        set1.drawCubicEnabled = true;
        set1.cubicIntensity = 0.2;
        set1.drawCirclesEnabled = false;
        set1.lineWidth = 2.0;
        set1.circleRadius = 5.0;
        set1.highlightColor = UIColor(red: 244.0/255, green: 117.0/255, blue: 117.0/255, alpha: 1.0)
        set1.setColor(UIColor(red: 104.0/255, green: 241.0/255, blue: 175.0/255, alpha: 1.0))
        set1.fillColor = UIColor(red: 51.0/255, green: 181.0/255, blue: 229.0/255, alpha: 1.0)
        
        var data = LineChartData(xVals: xVals, dataSet: set1)

        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9.0))
        data.setDrawValues(false)

        return data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ChartViewDelegate
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
    }
    
    func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }

    func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        
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
