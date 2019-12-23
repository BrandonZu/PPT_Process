//
//  NotebookTableViewController.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/12/19.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NotebookCell"

class NotebookTableViewController: UITableViewController {
    // Properties
    var notebookList = [Notebook]()
    
    var imageNeedClassify: [UIImage] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Add default notebook
        let image1 = UIImage(named: "PPT1")
        let image2 = UIImage(named: "PPT2")
        notebookList.append(Notebook(name: "未分类笔记", notes: [image1!, image2!]))
        
        // Load data
        
        
        // Add Notification Observer
        // Take A PPT
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNewPPT(notice:)), name: NSNotification.Name(rawValue: "NewPPT"), object: nil)
        
        // Course Actions
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNewCourse(notice:)), name: NSNotification.Name(rawValue: "NewCourse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveChangeCourse(notice:)), name: NSNotification.Name(rawValue: "ChangeCourse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDeleteCourse(notice:)), name: NSNotification.Name(rawValue: "DeleteCourse"), object: nil)
        
        // Wait for the answer
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCourseAnswer(notice:)), name: NSNotification.Name(rawValue: "CourseAnswer"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

//        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    // MARK: - Notification Observer Methods
    
    @objc func receiveNewPPT(notice: Notification) {
//        let current = Date()
        let current = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())
        guard let ppt = notice.object as? UIImage else {
            fatalError("Notification wrong: Receive wrong ppt")
        }
        self.imageNeedClassify.append(ppt)
        // Ask for Course
        let CourseRequest = Notification(name: Notification.Name(rawValue: "CourseRequest"), object: current, userInfo: ["info":"PPTRequest"])
        NotificationCenter.default.post(CourseRequest)
    }
    
    @objc func receiveNewCourse(notice: Notification) {
        guard let course = notice.object as? Course else {
            fatalError("Notification wrong: Insert course wrong")
        }
        notebookList.append(Notebook(name: course.name))
        // Reload the last row
        self.tableView.reloadData()
    }
    
    @objc func receiveChangeCourse(notice: Notification) {
        // course[0] is the old version, course[1] is the new version
        guard let course = notice.object as? [Course] else {
            fatalError("Notification wrong: Change course wrong")
        }
        var pos = 0
        for i in 0..<notebookList.count {
            if notebookList[i].name == course[0].name {
                notebookList[i].name = course[1].name
                pos = i
                break
            }
        }
        if pos == 0 {
            fatalError("Target notebook not found")
        }
        else {
            self.tableView.reloadData()
        }
    }
    
    @objc func receiveDeleteCourse(notice: Notification) {
        guard let course = notice.object as? Course else {
            fatalError("Notification wrong: Delete course wrong")
        }
        for i in 0..<notebookList.count {
            if notebookList[i].name == course.name {
                notebookList.remove(at: i)
                self.tableView.reloadData()
                return
            }
        }
        fatalError("Target notebook not found")
    }
    
    @objc func receiveCourseAnswer(notice: Notification) {
        if let answer = notice.object as? Course {
            // Find a course meets the requirement
            if imageNeedClassify.count == 0 {
                fatalError("No images needs to be classified!")
            }
            // Classify the oldest image
            for i in 1..<notebookList.count {
                if notebookList[i].name == answer.name {
                    notebookList[i].notes.append(imageNeedClassify[0])
                    imageNeedClassify.remove(at: 0)
                    break
                }
            }
        }
        else {
            // No course meet the requirement
            notebookList[0].notes.append(imageNeedClassify[0])
            imageNeedClassify.remove(at: 0)
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return notebookList.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotebookTableViewCell

        cell.name.text! = notebookList[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            notebookList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // Show details of the notebook
        if segue.identifier == "notebookDetail" {
            guard let detailViewController = segue.destination as? NoteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedNotebookCell = sender as? NotebookTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedNotebookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // Set the title of the detail view
            detailViewController.navigationBar.title = notebookList[indexPath.row].name
            // Set notes to show
            detailViewController.name = notebookList[indexPath.row].name
            detailViewController.noteList = notebookList[indexPath.row].notes
        }
    }
    

}
