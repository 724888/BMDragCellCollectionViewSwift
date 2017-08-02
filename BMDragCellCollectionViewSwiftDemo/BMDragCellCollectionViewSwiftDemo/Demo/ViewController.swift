//
//  ViewController.swift
//  BMDragCellCollectionViewDemo-Swift
//
//  Created by ___liangdahong on 2017/8/1.
//  Copyright © 2017年 ___liangdahong. All rights reserved.
//

import UIKit

let kScreen_width  = UIScreen.main.bounds.size.width
let kScreen_height = UIScreen.main.bounds.size.height
let kCellWithReuseIdentifier = "kCellWithReuseIdentifier"
let klineCount = 3

class ViewController: UIViewController {
    @IBOutlet weak var dragCellCollectionView: BMDragCellCollectionView!

    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing      = 20
        layout.minimumInteritemSpacing = 20
        let width = (kScreen_width - (0.5 * CGFloat(klineCount))) / CGFloat(klineCount)
        layout.itemSize = CGSize.init(width: width, height: width)
        layout.scrollDirection = .vertical;
        layout.headerReferenceSize = CGSize.init(width: kScreen_width, height: 10)
        layout.footerReferenceSize = CGSize.init(width: kScreen_width, height: 0)
        return layout
    }()

    lazy var dataArray: [String] = {
        var array = Array<Any>()
        var arc = arc4random_uniform(20) + 20
        for index in 0...arc {
            array.append("数据--\(index)")
        }
        return array as! [String]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dragCellCollectionView.dragDelegate = self
        dragCellCollectionView.dragDataSource = self
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        setUI()
    }
    
    private func setUI() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.dragCellCollectionView.collectionViewLayout = self.layout
        self.dragCellCollectionView.backgroundColor = UIColor.gray
        self.dragCellCollectionView.register(UINib.init(nibName: "BMHomeCell", bundle: nil), forCellWithReuseIdentifier: kCellWithReuseIdentifier)
    }
}

extension ViewController : BMDragCellCollectionViewDelegate {
    func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, newDataArray: Array<Any>) -> Void {
        self.dataArray = newDataArray as! [String]
    }
}

extension ViewController : BMDragCellCollectionViewDataSource {
    
    func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView) -> Array<Any> {
        return dataArray
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count;
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellWithReuseIdentifier, for: indexPath) as! BMHomeCell
        cell.label.text = dataArray[indexPath.item]
        return cell
    }
}
