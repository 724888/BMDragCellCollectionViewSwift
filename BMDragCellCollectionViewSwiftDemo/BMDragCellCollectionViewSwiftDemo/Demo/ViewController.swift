//
//  ViewController.swift
//  BMDragCellCollectionViewDemo-Swift
//
//  Copyright © 2017年 https://github.com/asiosldh/BMDragCellCollectionViewSwift/ All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import UIKit

let kScreen_width  = UIScreen.main.bounds.size.width
let kScreen_height = UIScreen.main.bounds.size.height
let kCellWithReuseIdentifier = "kCellWithReuseIdentifier"
let klineCount = 5

class ViewController: UIViewController {
    @IBOutlet weak var dragCellCollectionView: BMDragCellCollectionView!

    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing      = 3
        layout.minimumInteritemSpacing = 3
        let width = (kScreen_width - (0.5 * CGFloat(klineCount))) / CGFloat(klineCount)
        layout.itemSize = CGSize.init(width: width, height: width)
        layout.scrollDirection = .vertical;
        layout.headerReferenceSize = CGSize.init(width: kScreen_width, height: 10)
        layout.footerReferenceSize = CGSize.init(width: kScreen_width, height: 0)
        return layout
    }()

    lazy var dataArray: [[BMHoneModel]] = {
        var array = [[BMHoneModel]]()
        var arc = arc4random_uniform(10) + 2
        for index in 0...arc {
            var arr1 = [BMHoneModel]()
            var arc1 = arc4random_uniform(30) + 10
            for index1 in 0...arc1 {
                let w = Double(arc4random_uniform(100)) + 30.0
                let obj = BMHoneModel()
                obj.icon = String(format:"%03d.png", index1)
                obj.size = CGSize.init(width: w, height: w)
                arr1.append(obj)
            }
            array.append(arr1)
        }
        return array
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
        self.dataArray = newDataArray as! [[BMHoneModel]]
    }

    func dragCellCollectionViewShouldBeginMove(_ dragCellCollectionView: BMDragCellCollectionView, indexPath: IndexPath) -> Bool {
        if indexPath.item == 0 {
            let alert = UIAlertController.init(title: "温馨提示", message: "这个是不可以移动的哦", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.dataArray[indexPath.section][indexPath.item].size
    }
}

extension ViewController : BMDragCellCollectionViewDataSource {
    
    func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView) -> Array<Any> {
        return dataArray
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray[section].count;
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellWithReuseIdentifier, for: indexPath) as! BMHomeCell
        let obj = self.dataArray[indexPath.section][indexPath.item]
        var image = UIImage.init(named: obj.icon)
        if image == nil {
            image = UIImage.init(named: "001.png")
        }
        cell.iconImageView.image = image
        return cell
    }
}

