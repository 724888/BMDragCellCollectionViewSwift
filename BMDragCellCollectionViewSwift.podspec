Pod::Spec.new do |s|
s.name         = 'BMDragCellCollectionViewSwift'
s.version      = '1.0.2'
s.summary      = '一款可以简单实现长按拖拽重排的 UICellCollectionView Cell框架的Swift版，简单实现支付宝等拖拽重排功能,完美支持iOS8+'
s.homepage     = 'https://github.com/asiosldh/BMDragCellCollectionViewSwift'
s.license      = 'MIT'
s.authors      = {'idhong' => 'asiosldh@163.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/asiosldh/BMDragCellCollectionViewSwift.git', :tag => s.version}
s.source_files = 'BMDragCellCollectionView/**/*.{swift}'
s.requires_arc = true
end
