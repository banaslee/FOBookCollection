//
//  FOContinuousLoadingControl.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOContinuousLoadingView.h"

@interface FOContinuousLoadingView ()
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation FOContinuousLoadingView


- (void)setLoadingState:(FOContinuousLoadingState)loadingState {
    _loadingState = loadingState;
    
    switch (loadingState) {
        case FOContinuousLoadingActive:
            [self.activityIndicator startAnimating];
            self.statusLabel.hidden = YES;
            break;
        case FOContinuousLoadingReady:
            [self.activityIndicator stopAnimating];
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"";
            break;
        case FOContinuousLoadingNoResults:
            [self.activityIndicator stopAnimating];
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"No results";
            break;
        case FOContinuousLoadingNoMoreResults:
            [self.activityIndicator stopAnimating];
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"No more results";
            break;
        case FOContinuousLoadingError:
            [self.activityIndicator stopAnimating];
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"An error occurred";
            break;
            
        default:
            break;
    }
}
@end
