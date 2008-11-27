//
//  SearchView.h
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchBar.h"

typedef enum {
    OVERLAY_MODE_HIDDEN,
    OVERLAY_MODE_DARKEN,
    OVERLAY_MODE_SHADOW,
    OVERLAY_MODE_MESSAGE,
} OverlayViewMode;

@interface OverlayView : UIView {
    CustomSearchBar*            searchBar;
    UITableView*                searchView;
    UIActivityIndicatorView*    spinner;

    CGPoint         point;
    BOOL            moved;
    UIImage*        searchShadow;
    NSString*       message;
    
    OverlayViewMode mode;
}

- (void)setMessage:(NSString*)aMessage spinner:(BOOL)flag;

@property(nonatomic, assign) CustomSearchBar*   searchBar;
@property(nonatomic, assign) UITableView*       searchView;
@property(nonatomic, assign) OverlayViewMode    mode;

@end
