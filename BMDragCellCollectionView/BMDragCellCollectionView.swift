
//
//  BMDragCellCollectionView.swift
//  BMDragCellCollectionViewDemo-Swift
//
//  Created by ___liangdahong on 2017/8/1.
//  Copyright © 2017年 ___liangdahong. All rights reserved.
//

import UIKit

enum BMDragCellCollectionViewScrollDirection {
    case none, left, right, up, down
}

protocol BMDragCellCollectionViewDelegate : UICollectionViewDelegateFlowLayout {

    @available(iOS 6.0, *)
    func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, newDataArray: Array<Any>) -> Void
}

protocol BMDragCellCollectionViewDataSource : UICollectionViewDataSource {
    @available(iOS 6.0, *)
    func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView) -> Array<Any>
}

class BMDragCellCollectionView: UICollectionView {
    weak open var dragDelegate: BMDragCellCollectionViewDelegate? {
        get {
            return super.delegate as? BMDragCellCollectionViewDelegate
        } set {
            super.delegate = newValue
        }
    }
    
    weak open var dragDataSource: BMDragCellCollectionViewDataSource? {
        get {
            return super.dataSource as? BMDragCellCollectionViewDataSource
        } set {
            super.dataSource = newValue
        }
    }
    
    private var snapedView: UIView?
    private var oldIndexPath: IndexPath?
    private var currentIndexPath: IndexPath?
    private var oldPoint: CGPoint?
    private var lastPoint: CGPoint?
    private var isEndDrag = false

    lazy private var longGesture: UILongPressGestureRecognizer = {
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handlelongGesture(_:)))
        longGesture.minimumPressDuration = 0.5
        return longGesture
    }()
    
    private var edgeTimer : CADisplayLink?

    override func awakeFromNib() {
        super.awakeFromNib()
        initConfiguration()
        
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.initConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initConfiguration() -> Void {
        self.addGestureRecognizer(self.longGesture)
    }

    func edgeScroll() -> Void {
        let scrollDirection = self.setScrollDirection()
        switch scrollDirection {
        case .left:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x - 4, y: self.contentOffset.y), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)! - 4, y: (snapedView?.center.y)!)
            lastPoint?.x -= 4;
        case .right:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x - 4, y: self.contentOffset.y), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)! - 4, y: (snapedView?.center.y)!)
            lastPoint?.x += 4
        case .up:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x, y: self.contentOffset.y - 4), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)!, y: (snapedView?.center.y)! - 4)
            lastPoint?.y -= 4;
        case .down:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x, y: self.contentOffset.y + 4), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)!, y: (snapedView?.center.y)! + 4)
            lastPoint?.y += 4;
            break
        default: break
        }
        if (scrollDirection == .none) {
            return
        }

        // 如果Cell 拖拽到了边沿时
        // 截图视图位置移动
        UIView.animate(withDuration: 0.1) {
            self.snapedView?.center = self.lastPoint!
        }
        
        // 获取应该交换的Cell的位置
        let idnex1 = self.getChangedIndexPath()
        if ((idnex1 == nil)) {
            return
        }

        currentIndexPath = idnex1;
        self.oldPoint = self.cellForItem(at: currentIndexPath!)?.center

        // 移动 会调用willMoveToIndexPath方法更新数据源
        self.moveItem(at: self.oldIndexPath!, to: self.currentIndexPath!)
        
        self.oldIndexPath = currentIndexPath
        // 为了防止在缓存池取出的Cell已隐藏,
        // 以后可以优化
        self.reloadItems(at: [oldIndexPath!])
    }
    
    func setScrollDirection() -> BMDragCellCollectionViewScrollDirection {
        if self.bounds.size.height + self.contentOffset.y - (snapedView?.center.y)! < (snapedView?.bounds.size.height)! / 2 && self.bounds.size.height + self.contentOffset.y < self.contentSize.height {
            return .down;
        }
        if ((snapedView?.center.y)! - self.contentOffset.y < (snapedView?.bounds.size.height)! / 2 && self.contentOffset.y > 0) {
            return .up;
        }
        if (self.bounds.size.width + self.contentOffset.x - (snapedView?.center.x)! < (snapedView?.bounds.size.width)! / 2 && self.bounds.size.width + self.contentOffset.x < self.contentSize.width) {
            return .right;
        }
        if ((snapedView?.center.x)! - self.contentOffset.x < (snapedView?.bounds.size.width)! / 2 && self.contentOffset.x > 0) {
            return .left;
        }
        return .none;
    }

    @objc private func handlelongGesture(_ longGesture: UILongPressGestureRecognizer) -> Void {
        let point = longGesture.location(in: self)
        let indexPath = self.indexPathForItem(at: point);
        switch longGesture.state {
        case .began:
            print("began index\(String(describing: indexPath?.description)))")
            // 手势开始
            // 判断手势落点位置是否在Item上
            if (indexPath == nil) {
                self.longGesture.isEnabled = false
                Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { (time) in
                    self.longGesture.isEnabled = true
                })
                break;
            }
            oldIndexPath = indexPath!
            
            self.isEndDrag = false;
            
            // 取出正在长按的cell
            let cell = self.cellForItem(at: oldIndexPath!)
            self.oldPoint = cell?.center;
            
            // 使用系统截图功能，得到cell的快照view
            snapedView = cell?.snapshotView(afterScreenUpdates: false)
            
            // 设置frame
            snapedView?.frame = (cell?.frame)!;

            // 添加到 collectionView 不然无法显示
            self.addSubview(snapedView!)

            //截图后隐藏当前cell
            cell?.isHidden = true;

            // 获取当前触摸的中心点
            let currentPoint = point;

            // 动画放大和移动到触摸点下面
            UIView.animate(withDuration: 0.25, animations: {
                self.snapedView?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                self.snapedView?.center = CGPoint.init(x: currentPoint.x, y: currentPoint.y)
                self.snapedView?.alpha = 1.0;
            })

            // 开启collectionView的边缘自动滚动检测
            setEdgeTimer()
            break
        case .changed:
            // 当前手指位置
            lastPoint = point;

            // 截图视图位置移动
            UIView.animate(withDuration: 0.25, animations: {
                self.snapedView?.center = self.lastPoint!;
            })

            // 获取应该交换的cell
            let idnex1 = self.getChangedIndexPath()

            // 没有取到或者距离隐藏的最近时就返回
            if (idnex1 == nil) {
                break;
            }

            currentIndexPath = idnex1;
            oldPoint = self.cellForItem(at: currentIndexPath!)?.center

            // 操作数据
            self.updateSourceData()

            // 移动 会调用willMoveToIndexPath方法更新数据源
            self.moveItem(at: oldIndexPath!, to: currentIndexPath!)
            // 设置移动后的起始indexPath
            oldIndexPath = currentIndexPath
            
            self.reloadItems(at: [oldIndexPath!])
            break
        default:
            self.isEndDrag = true;
            if self.oldIndexPath == nil {
                return
            }
            let cell = self.cellForItem(at: oldIndexPath!)
            self.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.25, animations: {
                if cell == nil {
                    self.snapedView?.center = self.oldPoint!;
                } else {
                    self.snapedView?.center = (cell?.center)!;
                }
                self.snapedView?.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                self.snapedView?.alpha = 1.0;
            }, completion: { (an) in
                self.snapedView?.removeFromSuperview()
                cell?.isHidden = false
                self.isUserInteractionEnabled = true
            })
            endEdgeTimer()
            break
        }
    }

    func setEdgeTimer() -> Void {
        self.edgeTimer = CADisplayLink.init(target: self, selector: #selector(edgeScroll))
        self.edgeTimer?.add(to: RunLoop.main, forMode: .commonModes)
    }

    func endEdgeTimer() -> Void {
        self.edgeTimer?.invalidate()
        self.edgeTimer = nil;
    }

    /// 取出应该交换的index
    ///
    /// - Returns: index
    func getChangedIndexPath() -> IndexPath? {
        var index1: IndexPath? = nil
        let point = self.longGesture.location(in: self)

        // 遍历是否移动到cell上
        for cell in self.visibleCells {
            if (point.x > cell.frame.origin.x
                && point.x < cell.frame.origin.x + cell.frame.size.width
                && point.y > cell.frame.origin.y
                && point.y < cell.frame.origin.y + cell.frame.size.height) {
                index1 = self.indexPath(for: cell)
                break;
            }
        }

        // 是在cell上
        if index1 != nil {
            // 如果是当前的cell就返回nil
            if (index1?.item == self.oldIndexPath?.item) && (index1?.section == self.oldIndexPath?.section) {
                return nil
            }
            // 不是当前的cell
            return index1;
        }

        // 获取最应该交换的Cell
        var width : CGFloat = CGFloat(MAXFLOAT)
        for cell in self.visibleCells {
            let p1 = self.snapedView?.center
            let p2 = cell.center
            let distance = sqrt((pow(((p1?.x)! - p2.x), 2) + pow(((p1?.y)! - p2.y), 2)))
            if (distance < width) {
                width = distance
                index1 = self.indexPath(for: cell)
            }
        }

        if ((index1 == nil)) {
            return nil;
        }
        if ((index1?.item == self.oldIndexPath?.item) && (index1?.row == self.oldIndexPath?.row)) {
            // 最近的就是隐藏的Cell时,return nil
            return nil;
        }
        return index1;
    }

    func updateSourceData() -> Void {
        var array = self.dragDataSource?.dragCellCollectionView(self)
        if self.currentIndexPath?.section == self.oldIndexPath?.section {
            if (self.currentIndexPath?.item)! > (self.oldIndexPath?.item)! {
                for i in (oldIndexPath?.item)!...(currentIndexPath?.item)! {
                    let obj1 = array?[i]
                    array?[i] = array?[i + 1] ?? ""
                    array?[i + 1] = obj1 ?? ""
                }
            } else {
                for i in (currentIndexPath?.item)!...(oldIndexPath?.item)! {
                    let obj1 = array?[i]
                    array?[i] = array?[i + 1] ?? ""
                    array?[i + 1] = obj1 ?? ""
                }
            }
        } else {
            var orignalSection = array?[(oldIndexPath?.section)!] as! Array<Any>
            var currentSection = array?[(currentIndexPath?.section)!] as! Array<Any>
            currentSection.insert(orignalSection[(oldIndexPath?.item)!], at: (currentIndexPath?.item)!)
            orignalSection.remove(at: (oldIndexPath?.item)!)
        }
        self.dragDelegate?.dragCellCollectionView(self, newDataArray: array!)
    }

    internal override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if isEndDrag {
            cell.isHidden = false
            return cell
        }
        cell.isHidden = (oldPoint != nil) && oldIndexPath?.item == indexPath.item && oldIndexPath?.section == indexPath.section
        return cell
    }
}
