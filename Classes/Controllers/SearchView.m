//
//  SearchView.m
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SearchView.h"


@implementation SearchView

@synthesize searchBar;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
