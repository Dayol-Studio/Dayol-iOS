//
//  WeeklyCalendarView.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/02/01.
//

import UIKit
import RxSwift
import RxCocoa

private enum Design {
    enum IPadOrientation {
        case landscape
        case portrait
    }
    case ipad
    case iphone
    
    static var current: Design = { isPadDevice ? .ipad : iphone }()
    
    static func headerHeight(orientation: IPadOrientation) -> CGFloat {
        switch current {
        case .iphone:
            return 69
        case .ipad:
            if orientation == .portrait {
                return 125
            } else {
                return 81
            }
        }
    }
}

class WeeklyCalendarView: UIView {
    private let viewModel: WeeklyCalendarViewModel
    private let disposeBag = DisposeBag()
    private var dayModel: [WeeklyCalendarDataModel]?
    private var iPadOrientation: Design.IPadOrientation {
        if self.frame.size.width > self.frame.size.height {
            return .landscape
        } else {
            return .portrait
        }
    }
    
    private let headerView: MonthlyCalendarHeaderView = {
        let header = MonthlyCalendarHeaderView(month: .january)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        return header
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    init() {
        self.viewModel = WeeklyCalendarViewModel()
        super.init(frame: .zero)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionView()
    }
    
    private func initView() {
        addSubview(headerView)
        addSubview(collectionView)
        setConstraint()
        setupCollectionView()
        bind()
    }
    
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            collectionView.collectionViewLayout = layout
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeeklyCalendarViewCell.self, forCellWithReuseIdentifier: WeeklyCalendarViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leftAnchor.constraint(equalTo: leftAnchor),
            headerView.rightAnchor.constraint(equalTo: rightAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Design.headerHeight(orientation: iPadOrientation)),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func bind() {
        viewModel.dateModel(date: Date())
            .subscribe(onNext: {[weak self] models in
                guard let month = models[safe: 1]?.month else { return }
                self?.headerView.month = month
                self?.dayModel = models
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCollectionView() {
        collectionView.layoutIfNeeded()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - CollectionView Delegate

extension WeeklyCalendarView: UICollectionViewDelegate {
    
}

// MARK: - CollectionView DataSource

extension WeeklyCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayModel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dayModel?[safe: indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyCalendarViewCell.identifier, for: indexPath) as? WeeklyCalendarViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(model: model)
        if model.isFirst {
            cell.setFirstCell(true)
        }
        
        return cell
    }
}

// MARK: - CollectionView FlowLayout

extension WeeklyCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.height / 4)
    }
}
