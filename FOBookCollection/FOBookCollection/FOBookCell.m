//
//  FOBookCell.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOBookCell.h"

@interface FOBookCell ()
@end

@implementation FOBookCell

- (void)prepareForReuse {
    self.coverImageView.image = nil;
}

@end
