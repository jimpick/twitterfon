//
//  CustomSearchBar.h
//  TwitterFon
//
//  Created by kaz on 11/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomSearchBar : UITextField {
    UIImage*    inputField;
    UIButton*   locationButton;
}

@property(nonatomic, assign) UIButton* locationButton;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate;

@end

@protocol CustomSearchBarProtocol <NSObject>

@optional

- (void)customSearchBarLocationButtonClicked:(UIButton*)LocationButton;
- (void)customSearchBarBookmarkButtonClicked:(UIButton*)bookmarkButton;

@end

