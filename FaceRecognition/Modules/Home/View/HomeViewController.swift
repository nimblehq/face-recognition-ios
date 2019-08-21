//
//  HomeViewController.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit

// sourcery: AutoMockable
protocol HomeViewInput: AnyObject {
    func configure()
}

// sourcery: AutoMockable
protocol HomeViewOutput: AnyObject {
    func viewDidLoad()
}

final class HomeViewController: UIViewController {

    let tableView = UITableView()
    var output: HomeViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        output?.viewDidLoad()
    }
}

// MARK: - HomeViewInput
extension HomeViewController: HomeViewInput {
    func configure() {
        setUpLayouts()
        setUpViews()
    }

    private func setUpLayouts() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setUpViews() {
        navigationItem.title = "Face Recognition"
        view.backgroundColor = .white
        setUpTableView()
    }

    private func setUpTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "Take picture for training model"
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {}
