//
//  ExpandableCollectionViewProxy.h
//  ExpandableCollectionCell
//
//  Created by 朱彦谕 on 2021/9/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExpandableCollectionViewProxy : NSProxy <UICollectionViewDelegate, UICollectionViewDataSource>

- (instancetype)initWithCollectionDelegate:(id <UICollectionViewDelegate, UICollectionViewDataSource>)collectionDelegate
                        proxyDelegate:(id <UICollectionViewDelegate, UICollectionViewDataSource>)proxyDelegate;

@end

NS_ASSUME_NONNULL_END
