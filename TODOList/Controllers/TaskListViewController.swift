//
//  TaskListViewController.swift
//  TODOList
//
//  Created by Anadea Lukačević on 18/01/2021.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TaskListViewController: UIViewController {
    
    private lazy var prioritySegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "High", "Medium", "Low"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return sc
    }()
    
    private lazy var taskListTableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    let disposeBag = DisposeBag()
    private var tasks = BehaviorRelay<[Task]>(value: [])
    private var filteredTasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Task List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add, style: .plain, target: self, action: #selector(didTap))
        view.backgroundColor = .white
        addSubviews()
        makeConstraints()
    }
    
    deinit {
        taskListTableView.dataSource = nil
        taskListTableView.delegate = nil
    }
    
    private func addSubviews() {
        view.addSubview(prioritySegmentedControl)
        view.addSubview(taskListTableView)
    }
    
    private func makeConstraints() {
        prioritySegmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalTo(15)
            $0.trailing.equalTo(-15)
        }
        taskListTableView.snp.makeConstraints {
            $0.top.equalTo(prioritySegmentedControl.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalTo(0)
        }
    }
    
    @objc fileprivate func handleSegmentChange() {
        let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex - 1)
        filterTasks(by: priority)
    }
    
    @objc private func didTap() {
        let vc = AddTaskViewController()
        navigationController?.pushViewController(vc, animated: true)
        vc
            .taskSubjectObservable
            .subscribe(onNext: { [unowned self] task in
                let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex - 1)
                var existingTasks = self.tasks.value
                existingTasks.append(task)
                self.tasks.accept(existingTasks)
                self.filterTasks(by: priority)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateTableView() {
        DispatchQueue.main.async {
            self.taskListTableView.reloadData()
        }
    }
    
    private func filterTasks(by priority: Priority?) {
        if priority == nil {
            self.filteredTasks = self.tasks.value
            self.updateTableView()
        } else {
            self.tasks
                .map { tasks in
                return tasks.filter { $0.priority == priority! }
                }
                .subscribe(onNext: { [weak self] tasks in
                    self?.filteredTasks = tasks
                    self?.updateTableView()
                })
                .disposed(by: disposeBag)
        }
    }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.filteredTasks[indexPath.row].title
        return cell
    }
}
