#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"

@interface ProfileImage : NSObject
{
  	NSObject*           delegate;
	UIImage*            image;
    sqlite3*            database;
    NSString*           url;
}

@property (nonatomic, readonly) UIImage* image;

- (ProfileImage*)initWithURL:(NSString*)url delegate:(id)aDelegate;

@end
