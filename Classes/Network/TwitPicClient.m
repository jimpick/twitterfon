//
//  TwitterClient.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "TwitPicClient.h"
#import "StringUtil.h"
#import "REString.h"

@interface NSObject (TwitterClientDelegate)
- (void)twitPicClientDidPost:(TwitPicClient*)sender mediaId:(NSString*)mediaId;
- (void)twitPicClientDidFail:(TwitPicClient*)sender error:(NSString*)error detail:(NSString*)detail;
@end

@implementation TwitPicClient

@synthesize context;

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction
{
    [super initWithDelegate:aDelegate];
    action = anAction;
    return self;
}

- (NSString*) nameValString: (NSDictionary*) dict {
	NSArray* keys = [dict allKeys];
	NSString* result = [[NSString alloc] initWithString: @""];
	int i;
	for (i = 0; i < [keys count]; i++) {
        result = [result stringByAppendingString:
                  [@"--" stringByAppendingString:
                   [TWITTERFON_FORM_BOUNDARY stringByAppendingString:
                    [@"\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                     [[keys objectAtIndex: i] stringByAppendingString:
                      [@"\"\n\n" stringByAppendingString:
                       [[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString: @"\n"]]]]]]];
	}

	return result;
}

- (void)upload:(UIImage*)image
{
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

	NSString* url = [NSString stringWithFormat:@"http://twitpic.com/api/upload"];
    NSData *jpeg = UIImageJPEGRepresentation(image, 0.8);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         username, @"username",
                         password, @"password",
                         @"TwitterFon", @"source", nil];
    
    NSString *param = [self nameValString:dic];
    NSString *footer = [NSString stringWithFormat:@"\n--%@--\n", TWITTERFON_FORM_BOUNDARY];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\n", TWITTERFON_FORM_BOUNDARY]];
    param = [param stringByAppendingString:@"Content-Disposition: form-data; name=\"media\";filename=\"image.jpg\"\nContent-Type: image/jpeg\n\n"];
    NSLog(@"jpeg size: %d", [jpeg length]);

    NSMutableData *data = [NSMutableData data];
    [data appendData:[param dataUsingEncoding:NSASCIIStringEncoding]];
    [data appendData:jpeg];
    [data appendData:[footer dataUsingEncoding:NSASCIIStringEncoding]];

    [self post:url data:data];
    
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    [delegate twitPicClientDidFail:self error:@"Connection Failed" detail:[error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [delegate twitPicClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    NSLog(@"%@", content);
    
    if (statusCode != 200) {
        NSString *error = [NSString stringWithFormat:@"TwitPic Error: %d", statusCode];
        [delegate twitPicClientDidFail:self error:error detail:@"Failed to upload photo to TwitPic."];
        return;
    }

    NSMutableArray *substr = [NSMutableArray array];
    NSRange r;
    
    r = [content  rangeOfString:@"<rsp stat=\"ok\">"];
    if (r.location != NSNotFound) {
        if ([content matches:@"<mediaid>([A-Za-z0-9]+)</mediaid>" withSubstring:substr]) {
            NSLog(@"mediaid = %@", [substr objectAtIndex:0]);
            [delegate twitPicClientDidPost:self mediaId:[substr objectAtIndex:0]];
        }
        else {
            [delegate twitPicClientDidFail:self error:@"TwitPic Error" detail:@"TwitPic responded unknown content."];
        }
    }
    else if ([content matches:@"<err +code=\"([0-9]+)\" +msg=\"([A-Za-z0-9\\. ]+)\" */>" withSubstring:substr]) {
        NSLog(@"TwitPic error: %@ %@", [substr objectAtIndex:0], [substr objectAtIndex:1]);
        [delegate twitPicClientDidFail:self error:[NSString stringWithFormat:@"TwitPic Error: %@", [substr objectAtIndex:0]]
                                                                      detail:[substr objectAtIndex:1]];
    }
    else {
        [delegate twitPicClientDidFail:self error:@"TwitPic Error" detail:@"TwitPic responded unknown content."];
    }
}


@end
