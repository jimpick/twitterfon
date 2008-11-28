//
//  CustomSearchBar.h
//  TwitterFon
//
//  Created by kaz on 11/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchTextField.h"

@protocol CustomSearchBarDelegate;

@interface CustomSearchBar : UIView <UITextFieldDelegate> {
    CustomSearchTextField*      textField;
    
    UIButton*                   locationButton;
    UIButton*                   distanceButton;
    CALayer*                    layers[5];
    BOOL                        leftButtonExpanded;
    id<CustomSearchBarDelegate> delegate;
    NSString*                   text;
}

@property(nonatomic, assign) UIButton* locationButton;
@property(nonatomic, assign) UIButton* distanceButton;
@property(nonatomic, assign) NSString* text;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate;

@end

@protocol CustomSearchBarDelegate <NSObject>

@optional

- (BOOL)customSearchBarShouldBeginEditing:(CustomSearchBar *)searchBar;
- (void)customSearchBarTextDidBeginEditing:(CustomSearchBar *)searchBar;
- (BOOL)customSearchBarShouldEndEditing:(CustomSearchBar *)searchBar;
- (void)customSearchBarTextDidEndEditing:(CustomSearchBar *)searchBar;

- (void)customSearchBar:(CustomSearchBar *)searchBar textDidChange:(NSString *)searchText;

- (void)customSearchBarSearchButtonClicked:(CustomSearchBar*)searchBar;
- (void)customSearchBarDistanceButtonClicked:(CustomSearchBar*)searchBar;
- (void)customSearchBarLocationButtonClicked:(CustomSearchBar*)searchBar;
- (void)customSearchBarBookmarkButtonClicked:(CustomSearchBar*)searchBar;

@end

