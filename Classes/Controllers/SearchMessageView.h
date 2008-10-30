//
//  SearchView.h
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchMessageView: UIView {
    IBOutlet UILabel*                   messageLabel;
    IBOutlet UIActivityIndicatorView*   messageIndicator;;
    UISearchBar*                        searchBar;
    
    CGPoint                             point;
    BOOL                                moved;
}

@property(nonatomic, assign) UISearchBar* searchBar;

- (void)setMessage:(NSString*)message indicator:(BOOL)indicator;

@end
