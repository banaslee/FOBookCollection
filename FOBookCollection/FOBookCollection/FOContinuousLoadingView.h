//
//  FOContinuousLoadingControl.h
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FOContinuousLoadingState) {
    FOContinuousLoadingActive = 0,
    FOContinuousLoadingReady,
    FOContinuousLoadingNoResults,
    FOContinuousLoadingNoMoreResults,
    FOContinuousLoadingError
};

@interface FOContinuousLoadingView : UICollectionReusableView
@property (nonatomic) FOContinuousLoadingState loadingState;
@end
