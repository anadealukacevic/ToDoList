//
//  AddTaskViewController.swift
//  TODOList
//
//  Created by Anadea Lukačević on 18/01/2021.
//

import UIKit
import RxSwift
import SnapKit

class AddTaskViewController: UIViewController {
    
    private lazy var prioritySegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["High", "Medium", "Low"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private lazy var taskTitleTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let taskSubject = PublishSubject<Task>()
    var taskSubjectObservable: Observable<Task> {
        return taskSubject.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add task"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(prioritySegmentedControl)
        view.addSubview(taskTitleTextField)
    }
    
    private func makeConstraints() {
        prioritySegmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.equalTo(25)
            $0.trailing.equalTo(-25)
        }
        taskTitleTextField.snp.makeConstraints {
            $0.top.equalTo(prioritySegmentedControl.snp.bottom).offset(50)
            $0.leading.equalTo(25)
            $0.trailing.equalTo(-25)
        }
    }
    
    @objc fileprivate func save() {
        guard let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex),
              let title = self.taskTitleTextField.text else { return }
        let task = Task(title: title, priority: priority)
        taskSubject.onNext(task)

        self.navigationController?.popViewController(animated: true)
    }
}
