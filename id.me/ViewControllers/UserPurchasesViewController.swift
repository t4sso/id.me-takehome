//
//  UserPurchasesViewController.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import UIKit
import Combine

/// View controller responsible for displaying an list of the user's purchases
class UserPurchasesViewController: UITableViewController {
    
    static private let userPurchaseCellIdentifier = "PurchaseCell"
    static private let noSearchResultsView = "NoSearchResultsView"
    
    /// Reference to the the view model, to be configured by the caller.
    var viewModel: UserPurchasesViewModel
    
    private var dataSource: UITableViewDiffableDataSource<Int, Purchase>!
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: UserPurchasesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        clearsSelectionOnViewWillAppear = true
        tableView.contentInset.top = 20
        tableView.contentInset.bottom = 100
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension

        title = NSLocalizedString("Purchases", comment: "title describing a user's purchases")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(userDidTapInfoButton))
        
        // Configure the diffable data source and bind to the view model to receive actual data.
        configureDataSource()
        bindViewModel()
    }
    
    @objc private func userDidTapInfoButton() {
        let aboutPurchasesInfoViewController = AboutPurchasesInfoViewController()
        let navigationController = UINavigationController(rootViewController: aboutPurchasesInfoViewController)
        present(navigationController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PurchaseCell else { return }
        cell.showFullDetails = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //Expandable cell
            guard let cell = tableView.cellForRow(at: indexPath) as? PurchaseCell else { return }
            cell.toggleFullView()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
}

// MARK: - Data Source Configuration

extension UserPurchasesViewController {
    
    private func configureDataSource() {
        tableView.register(PurchaseCell.self, forCellReuseIdentifier: UserPurchasesViewController.userPurchaseCellIdentifier)
        // Set up diffable data source for preserving updates.
        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak viewModel] (tableView, indexPath, purchase) -> UITableViewCell? in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: UserPurchasesViewController.userPurchaseCellIdentifier,
                                                        for: indexPath) as? PurchaseCell,
                      let viewModel = viewModel else {
                          return UITableViewCell()
                      }
                cell.configure(forPurchase: purchase, viewModel: viewModel)
                return cell
            })
        dataSource.defaultRowAnimation = .fade
    }
}

// MARK: - View Model Data Binding

extension UserPurchasesViewController {
    
    private func bindViewModel() {
        
        viewModel.$purchases
            .receive(on: DispatchQueue.main)
            .sink { [weak self] purchases in
                self?.reloadData(purchases) }
            .store(in: &cancellables)
    }
    
    private func reloadData(_ purchases: [Purchase]?) {
        
        // Refresh the underlying table view showing the results...
        if let purchases = purchases, purchases.count > 0 {
            let sortedPurchases = purchases.sorted {
                $0.purchaseDate.dateFromISO8601String() < $1.purchaseDate.dateFromISO8601String()
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<Int, Purchase>()
            snapshot.appendSections([0])
            snapshot.appendItems(sortedPurchases)
            dataSource.apply(snapshot)
            tableView.backgroundView?.isHidden = true
        } else {
            dataSource.apply(NSDiffableDataSourceSnapshot<Int, Purchase>())
            tableView.backgroundView?.isHidden = false
        }
    }
}

