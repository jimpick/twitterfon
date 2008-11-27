#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"

@interface ProfileImage : NSObject
{
  	id                  delegate;
	UIImage*            image;
    sqlite3*            database;
    NSString*           url;
    id                  appDelegate;
}

@property (nonatomic, readonly) UIImage* image;

- (ProfileImage*)initWithURL:(NSString*)url appDelegate:(id)anAppDelegate delegate:(id)aDelegate;

@end
