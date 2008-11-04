//
//  SearchBookmarksViewController.h
//  TwitterFon
//
//  Created by kaz on 10/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostViewController;

@interface FolloweesViewController : UIViewController <UISearchBarDelegate> {
    IBOutlet UITableView*   friendsView;
    PostViewController*     postViewController;
    NSString*               screenName;
    NSMutableArray*         letters;
    NSMutableArray*         index;
    int                     numLetters;

    NSMutableArray*         searchResult;
    int                     numSearchResults;
}

@property(nonatomic, assign) PostViewController* postViewController;

- (IBAction) close:(id)sender;

@end
