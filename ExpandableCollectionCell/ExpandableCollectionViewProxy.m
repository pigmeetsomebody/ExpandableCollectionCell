//
//  ExpandableCollectionViewProxy.m
//  ExpandableCollectionCell
//
//  Created by 朱彦谕 on 2021/9/15.
//

#import "ExpandableCollectionViewProxy.h"


@interface ExpandableCollectionViewProxy()

@property (nonatomic, weak) id proxyDelegate;
@property (nonatomic, weak) id collectionDelegate;

@end

@implementation ExpandableCollectionViewProxy

- (instancetype)initWithCollectionDelegate:(id <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>)collectionDelegate
                        proxyDelegate:(id <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>)proxyDelegate
{
    self.collectionDelegate = collectionDelegate;
    self.proxyDelegate = proxyDelegate;
    
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.proxyDelegate respondsToSelector:aSelector]) {
        return self.proxyDelegate;
    } else if ([self.collectionDelegate respondsToSelector:aSelector]) {
        return self.collectionDelegate;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.proxyDelegate respondsToSelector:aSelector]) {
        return YES;
    } else if ([self.collectionDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.collectionDelegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.collectionDelegate methodSignatureForSelector:sel];
}

@end

