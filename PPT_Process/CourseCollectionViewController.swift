//
//  CourseCollectionViewController.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/12/19.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit

class CourseCollectionViewController: UICollectionViewController {
    
    // Properties
    private let reuseIdentifier = "CourseCell"
    private let columnNum: Int = 6
    private let rowNum: Int = 12
    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    // Store all the list
    var courseList: [[Course]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Add Gesture Recognizer
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapCollectionView(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        self.collectionView.addGestureRecognizer(singleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCollectionView(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        // TEST
        for _ in 1...(rowNum - 1) {
            var tmp = [Course]()
            for _ in 1...(columnNum - 1) {
                tmp.append(Course())
            }
            courseList.append(tmp)
        }
    }
    
    private func getCourseIndexPath( course : Course) -> [IndexPath] {
        var posList: [IndexPath] = [IndexPath]()
        for i in course.start...course.end {
            posList.append(IndexPath(item: i * columnNum + course.weekday, section: 0))
        }
        return posList
    }
    
    // MARK: - Actions
    
    @IBAction func AddCourseTouched(_ sender: UIBarButtonItem) {
        let inputCourse = UIAlertController(title: "添加课程",
                                            message: "请输入详细课程信息",
                                            preferredStyle: .alert)
        inputCourse.addTextField() { nameInput in
            nameInput.placeholder = "课程名"
        }
        inputCourse.addTextField() { dayInput in
            dayInput.placeholder = "输入课程在周几 e.g.周一"
        }
        inputCourse.addTextField() { startInput in
            startInput.placeholder = "输入课程第几节课开始(1-11) e.g. 8"
        }
        inputCourse.addTextField() { endInput in
            endInput.placeholder = "输入课程第几节课开始(1-11) e.g. 9"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确认", style: .default) { action in
            let tmpCourse: Course = Course()
            guard let name = inputCourse.textFields![0].text,
                let day = inputCourse.textFields![1].text,
                let startStr = inputCourse.textFields![2].text,
                let endStr = inputCourse.textFields![3].text else {
                    let Alert = UIAlertController(title: "错误", message: "输入错误", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
            }
            
            guard let start = Int(startStr), let end = Int(endStr) else {
                let Alert = UIAlertController(title: "输入错误", message: "课程开始、结束时间为整数", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                Alert.addAction(okAction)
                self.present(Alert, animated: true, completion: nil)
                return
            }
            
            if name != "" {
                tmpCourse.name = name
            }
            else {
                let Alert = UIAlertController(title: "课程名输入错误", message: "输入姓名不能为空！", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default) { action in
                    self.present(inputCourse, animated: true, completion: nil)
                }
                Alert.addAction(okAction)
                self.present(Alert, animated: true, completion: nil)
                return
            }
            
            if (day == "周一" || day == "周二" || day == "周三" || day == "周四" || day == "周五") {
                switch day {
                case "周一": tmpCourse.weekday = 1
                case "周二": tmpCourse.weekday = 2
                case "周三": tmpCourse.weekday = 3
                case "周四": tmpCourse.weekday = 4
                case "周五": tmpCourse.weekday = 5
                default:
                    tmpCourse.weekday = 0
                }
            }
            else {
                let Alert = UIAlertController(title: "课程日期输入错误", message: "必须输入周一到周五!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default) { action in
                    self.present(inputCourse, animated: true, completion: nil)
                }
                Alert.addAction(okAction)
                self.present(Alert, animated: true, completion: nil)
                return
            }
            
            if start >= 1 && start <= 11 {
                tmpCourse.start = start
            }
            else {
                let Alert = UIAlertController(title: "课程开始节数输入错误", message: "必须为整数且在1-11", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default) { action in
                    self.present(inputCourse, animated: true, completion: nil)
                }
                Alert.addAction(okAction)
                self.present(Alert, animated: true, completion: nil)
                return
            }
            
            if end >= tmpCourse.start && end <= 11 {
                tmpCourse.end = end
            }
            else {
                let Alert = UIAlertController(title: "课程结束节数输入错误", message: "必须为整数且在1-11", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default) { action in
                    self.present(inputCourse, animated: true, completion: nil)
                }
                Alert.addAction(okAction)
                self.present(Alert, animated: true, completion: nil)
                return
            }
            
//            print(tmpCourse)
            // Insert the course
            for i in tmpCourse.start...tmpCourse.end {
                if !self.courseList[i - 1][tmpCourse.weekday - 1].isEmpty() {
                    let Alert = UIAlertController(title: "插入课程错误", message: "目标位置已有课程", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
                }
            }
            
            // Insert successfully
//            print("Reload items!")
            for i in tmpCourse.start...tmpCourse.end {
                self.courseList[i - 1][tmpCourse.weekday - 1] = tmpCourse
            }
            self.collectionView.reloadItems(at: self.getCourseIndexPath(course: tmpCourse))
            
        }
        
        inputCourse.addAction(okAction)
        inputCourse.addAction(cancelAction)

        self.present(inputCourse, animated: true, completion: nil)
    }

    @objc func singleTapCollectionView(gesture: UITapGestureRecognizer) {
        let point: CGPoint = gesture.location(in: self.collectionView)
        let selectedIndexPath = self.collectionView.indexPathForItem(at: point)!
        let column = selectedIndexPath.item % columnNum
        let row = selectedIndexPath.item / columnNum
        if column == 0 || row == 0 {
            return
        }
        print("Tap at \((row, column))")
        // Select a cell
        if courseList[row - 1][column - 1].isEmpty() {
            return
        }
        else {
            let originalCourse = courseList[row - 1][column - 1]
            let detail = UIAlertController(title: originalCourse.name, message: nil, preferredStyle: .alert)
            detail.addTextField() { nameDetail in
                nameDetail.text = originalCourse.name
            }
            detail.addTextField() { weekdayDetail in
                weekdayDetail.text = originalCourse.getWeekday()
            }
            detail.addTextField() { startDetail in
                startDetail.text = String(originalCourse.start)
            }
            detail.addTextField() { endDetail in
                endDetail.text = String(originalCourse.end)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "保存", style: .default) { action in
                let tmpCourse: Course = Course()
                guard let name = detail.textFields![0].text,
                    let day = detail.textFields![1].text,
                    let startStr = detail.textFields![2].text,
                    let endStr = detail.textFields![3].text else {
                        let Alert = UIAlertController(title: "修改错误", message: "输入错误", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                        Alert.addAction(okAction)
                        self.present(Alert, animated: true, completion: nil)
                        return
                }
                
                guard let start = Int(startStr), let end = Int(endStr) else {
                    let Alert = UIAlertController(title: "修改课程失败", message: "课程开始、结束时间为整数", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
                }
                
                if name != "" {
                    tmpCourse.name = name
                }
                else {
                    let Alert = UIAlertController(title: "修改课程失败", message: "输入姓名不能为空！", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default) { action in
                        self.present(detail, animated: true, completion: nil)
                    }
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
                }
                
                if (day == "周一" || day == "周二" || day == "周三" || day == "周四" || day == "周五") {
                    switch day {
                    case "周一": tmpCourse.weekday = 1
                    case "周二": tmpCourse.weekday = 2
                    case "周三": tmpCourse.weekday = 3
                    case "周四": tmpCourse.weekday = 4
                    case "周五": tmpCourse.weekday = 5
                    default:
                        tmpCourse.weekday = 0
                    }
                }
                else {
                    let Alert = UIAlertController(title: "修改课程失败", message: "课程日期必须输入周一到周五!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default) { action in
                        self.present(detail, animated: true, completion: nil)
                    }
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
                }
                
                if start >= 1 && start <= 11 {
                    tmpCourse.start = start
                }
                else {
                    let Alert = UIAlertController(title: "修改课程失败", message: "课程开始时间必须为整数且在1-11", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default) { action in
                        self.present(detail, animated: true, completion: nil)
                    }
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
                }
                
                if end >= tmpCourse.start && end <= 11 {
                    tmpCourse.end = end
                }
                else {
                    let Alert = UIAlertController(title: "修改课程失败", message: "课程结束时间必须为整数且在1-11", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default) { action in
                        self.present(detail, animated: true, completion: nil)
                    }
                    Alert.addAction(okAction)
                    self.present(Alert, animated: true, completion: nil)
                    return
                }
                
    //            print(tmpCourse)
                // Insert the course
                for i in tmpCourse.start...tmpCourse.end {
                    if !self.courseList[i - 1][tmpCourse.weekday - 1].isEmpty() && self.courseList[i - 1][tmpCourse.weekday - 1].name != tmpCourse.name {
                        let Alert = UIAlertController(title: "修改课程失败", message: "目标位置已有课程", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                        Alert.addAction(okAction)
                        self.present(Alert, animated: true, completion: nil)
                        return
                    }
                }
                
                // Delete old course
                for i in originalCourse.start...originalCourse.end {
                    self.courseList[i - 1][originalCourse.weekday - 1] = Course()
                }
                // Update new course
                for i in tmpCourse.start...tmpCourse.end {
                    self.courseList[i - 1][tmpCourse.weekday - 1] = tmpCourse
                }
                var IndexList = self.getCourseIndexPath(course: tmpCourse) + self.getCourseIndexPath(course: originalCourse)
                print(IndexList)
                IndexList = Array(Set(IndexList))
                print(IndexList)
                
                self.collectionView.reloadItems(at: IndexList)
                
            }
            detail.addAction(okAction)
            detail.addAction(cancelAction)
            self.present(detail, animated: true, completion: nil)
        }
    }
    
    @objc func longPressCollectionView(gesture: UILongPressGestureRecognizer) {
        let point: CGPoint = gesture.location(in: self.collectionView)
        let selectedIndexPath = self.collectionView.indexPathForItem(at: point)!
        let column = selectedIndexPath.item % columnNum
        let row = selectedIndexPath.item / columnNum
        if column == 0 || row == 0 {
            return
        }
        if courseList[row - 1][column - 1].isEmpty() {
            return
        }
        else {
            let course = courseList[row - 1][column - 1]
            let deleteConfirm = UIAlertController(title: "是否要删除课程" + course.name, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "确认", style: .default) { action in
                // Delete course in courselist
                for i in course.start...course.end {
                    self.courseList[i - 1][course.weekday - 1] = Course()
                }
                self.collectionView.reloadItems(at: self.getCourseIndexPath(course: course))
                return
            }
            deleteConfirm.addAction(okAction)
            deleteConfirm.addAction(cancelAction)
            self.present(deleteConfirm, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Only support one syllabus
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 5 days, each day has 11 classes
        return Int(columnNum * rowNum)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CourseCollectionViewCell
        
        cell.content.numberOfLines = 5
        
        // Configure the look
        if indexPath.item == 0 {
            cell.content.text = "Syllabus"
        }
        else if indexPath.item < columnNum {
            // Display Monday...Friday
            cell.backgroundColor = .lightGray
            switch indexPath.item {
                case 1: cell.content.text = "周一"
                case 2: cell.content.text = "周二"
                case 3: cell.content.text = "周三"
                case 4: cell.content.text = "周四"
                case 5: cell.content.text = "周五"
            default:
                cell.content.text = "未知"
            }
        }
        else if indexPath.item % columnNum == 0 {
            cell.backgroundColor = .lightGray
            cell.content.text = String(indexPath.item / columnNum)
        }
        else {
            cell.backgroundColor = .white
            cell.content.text = courseList[indexPath.item / columnNum - 1][indexPath.item % columnNum - 1].name
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CourseCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * CGFloat(columnNum + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(columnNum)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


    
// MARK: - UICollectionViewDelegate
    /*
extension CourseCollectionViewCell: UICollectionViewDelegate {
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
}
    */


