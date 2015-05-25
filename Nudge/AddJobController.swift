//
//  AddJobController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 30.04.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

class AddJobController: BaseController, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "AddJobCell"

    @IBOutlet weak var table: UITableView!

    let structure: [AddJobItem] = [
        AddJobItem(type: AddJobbCellType.Field, image: "first", placeholder: "Job Title"),
        AddJobItem(type: AddJobbCellType.BigText, image: "first", placeholder: "Job Description (keep it brief)"),
        AddJobItem(type: AddJobbCellType.Field, image: "first", placeholder: "Add Skills Tags"),
        AddJobItem(type: AddJobbCellType.Field, image: "first", placeholder: "Salary Details"),
        AddJobItem(type: AddJobbCellType.Field, image: "first", placeholder: "Employer"),
        AddJobItem(type: AddJobbCellType.Field, image: "first", placeholder: "Tag Location"),
        AddJobItem(type: AddJobbCellType.Field, image: "first", placeholder: "Job Status")
    ];

    override func viewDidLoad() {
        super.viewDidLoad()

        table.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)

        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard:")
        view.addGestureRecognizer(tap)
    }

    func DismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.resignFirstResponder()
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure.count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddJobCell
        let data = structure[indexPath.row]

        cell.setup(data.type, image: data.image, placeholder: data.placeholder)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let placeholder = structure[indexPath.section][indexPath.row].placeholder
//
//        performSegueWithIdentifier(placeholder, sender: self)
    }
}
