//
//  CustomGallerySource.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import ImageViewer
import Nuke

public class CustomGallerySource: GalleryItemsDataSource {
  private let assets: [Asset]
  
  public init(_ assets: [Asset]) {
    self.assets = assets
  }
  
  public func itemCount() -> Int {
    return assets.count
  }
  
  public func provideGalleryItem(_ index: Int) -> GalleryItem {
    let url = assets[index].url
    let request = Request(url: url)
    let image = Cache.shared[request]
    
    return GalleryItem.image { $0(image) }
  }
}
