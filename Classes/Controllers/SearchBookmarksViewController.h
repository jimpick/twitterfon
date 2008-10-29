//
//  SearchBookmarksViewController.h
//  TwitterFon
//
//  Created by kaz on 10/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchBookmarksViewController : UIViewController<UIActionSheetDelegate> {
    NSMutableArray*             queries;
    id                          searchView;
    IBOutlet UITableView*       bookmarkView;
}

@property(nonatomic, assign) id searchView;

//- (IBAction) edit:(id)sender;
- (IBAction) close:(id)sender;

@end
