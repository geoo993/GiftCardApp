//
//  ViewController.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Hero

public final class HomeViewController: UIViewController {

    @IBOutlet weak var giftcardsCollecionView: UICollectionView!
    
    enum UIConstant {
        static let cellIdentifier = "giftcardCell"
        static let margin: CGFloat = 16
        static let cardWidth: CGFloat = 343
        static let cardHeight: CGFloat = 188
    }
    
    //Mark: - Status bar
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Mark: - Set cell width and content inset
    var contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    var screenWidth : CGFloat = {
        return UIScreen.main.bounds.width
    }()
    
    lazy var titleView: UIImageView? = {
        guard let image = UIImage(named: "Wizgift") else { return nil }
        let imageView = UIImageView(image: image)
        
        let frame: CGRect
        if let navigationController = self.navigationController {
            let bannerWidth = navigationController.navigationBar.frame.size.width
            let bannerHeight = navigationController.navigationBar.frame.size.height
            
            let bannerX = bannerWidth / 2 - image.size.width / 2
            let bannerY = bannerHeight / 2 - image.size.height / 2
            frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        } else {
            let defaultSize = CGSize(width: 129, height: 63)
            let bannerX = defaultSize.width / 2 - image.size.width / 2
            let bannerY = defaultSize.height / 2 - image.size.height / 2
            frame = CGRect(x: bannerX, y: bannerY, width: defaultSize.width, height: defaultSize.height)
        }
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let viewModel = GiftCardViewModel()
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCollectionView()
        setupBinding()
        reloadData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
 
    func setup() {
        overrideUserInterfaceStyle = .light
        self.navigationItem.titleView = titleView

    }

    func setupCollectionView() {
        giftcardsCollecionView.dataSource = self
        giftcardsCollecionView.delegate = self
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(HomeViewController.onPullRefreshControl), for: .valueChanged)
        giftcardsCollecionView.addSubview(refreshControl)
        
    }
    
    func setupBinding() {
        
        viewModel
            .isRefreshing
            .asDriver()
            .drive(onNext: { [weak self] (isRefreshing) in
                guard isRefreshing == false else { return }
                self?.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
        
    }
    
    @objc private func onPullRefreshControl() {
        reloadData()
    }
    
    func reloadData() {
        viewModel.reload()
    }
    
}

// MARK: -

extension HomeViewController {
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        guard let destinationVC = segue.destination as? GiftCardViewController else { return }
        if let lastIndexpath = giftcardsCollecionView.indexPathsForSelectedItems?.last {
            let item = viewModel.cards.value[lastIndexpath.row]
            destinationVC.card = item
        }
    }
    
}

// MARK: -

extension HomeViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cards.value.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIConstant.cellIdentifier, for: indexPath) as? GiftCardCollectionViewCell else { return UICollectionViewCell() }
        let item = viewModel.cards.value[indexPath.row]
        cell.cardImageView.image = UIImage(named: item.logo.card)
//        cell.hero.id = "cardhero"
        //cell.cardImageView.hero.id = "cardimagehero"
        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = min(screenWidth - (UIConstant.margin * 2), UIConstant.cardWidth)
        let itemHeight: CGFloat = UIConstant.cardHeight
        return CGSize(width: itemWidth, height: itemHeight)
    }
}


class CollectionViewOverlappingLayout: UICollectionViewFlowLayout {

    var overlap: CGFloat = HomeViewController.UIConstant.cardHeight - 100
    var showFront = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .vertical
        self.minimumInteritemSpacing = 0
    }

    override var collectionViewContentSize: CGSize{
        let xSize = CGFloat(self.collectionView!.numberOfSections) * self.itemSize.width
        let ySize = CGFloat(self.collectionView!.numberOfItems(inSection: 0)) * self.itemSize.height

        var contentSize = CGSize(width: xSize, height: ySize)

        if self.collectionView!.bounds.size.width > contentSize.width {
            contentSize.width = self.collectionView!.bounds.size.width
        }

        if self.collectionView!.bounds.size.height > contentSize.height {
            contentSize.height = self.collectionView!.bounds.size.height
        }

        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        let attributesArray = super.layoutAttributesForElements(in: rect)
        let numberOfItems = self.collectionView!.numberOfItems(inSection: 0)

        for attributes in attributesArray! {
            let xPosition = attributes.center.x
            var yPosition = attributes.center.y
            
            if attributes.indexPath.row == 0 {
                attributes.zIndex = showFront ? 0 : Int(INT_MAX) // Put the first cell on top of the stack
            } else {
                yPosition -= self.overlap * CGFloat(attributes.indexPath.row)
                let zIndex = showFront ? attributes.indexPath.row : numberOfItems - attributes.indexPath.row
                attributes.zIndex = zIndex
            }

            attributes.center = CGPoint(x: xPosition, y: yPosition)
        }

        return attributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forCellWith: indexPath)
    }
}
