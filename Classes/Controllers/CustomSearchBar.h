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
    UIImage*    locationBar;
    UIButton*   locationButton;
    UIButton*   distanceButton;
    CALayer*    layers[5];
    
    float       leftButtonWidth;
}

@property(nonatomic, assign) float leftButtonWidth;
@property(nonatomic, assign) UIButton* locationButton;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate;
- (void)changeBarSize:(CGRect)rect;


@end

@protocol CustomSearchBarProtocol <NSObject>

@optional

- (void)customSearchBarLocationButtonClicked:(UIButton*)LocationButton;
- (void)customSearchBarBookmarkButtonClicked:(UIButton*)bookmarkButton;

@end

