//
//  CollectionView.swift
//  CollectionViewSwiftUI
//
//  Created by Shivaditya Kr on 16/06/23.
//

import SwiftUI
import UIKit

struct CollectionViewWrapper<Data, Content>: UIViewRepresentable where Data: RandomAccessCollection, Content: View {
    let items: Data
    let content: (Data.Element) -> Content
    var currentPage: Binding<Int>
    init(items: Data, currentPage: Binding<Int>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
        self.currentPage = currentPage
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: CollectionViewWrapper
        
        init(_ parent: CollectionViewWrapper) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            
            let childView = UIHostingController(rootView: parent.content(parent.items[indexPath.row as! Data.Index]))
            childView.view.frame = cell.contentView.bounds
            childView.view.backgroundColor = UIColor.clear
            childView.view.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(childView.view)
            
            NSLayoutConstraint.activate([
                childView.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                childView.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                childView.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                childView.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
            return cell
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            collectionView.bounds.size
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let pageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            parent.currentPage.wrappedValue = pageIndex
        }
    }
}
