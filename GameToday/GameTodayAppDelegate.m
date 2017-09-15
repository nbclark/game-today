#import "GameTodayAppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

@implementation MBAAppDelegate

static NSTimer* timer;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    //SMLoginItemSetEnabled ((__bridge CFStringRef)@"me.nicholasclark.gametoday", YES);
}

- (void)awakeFromNib {
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    [[self statusItem] setTitle:@"No Game"];
    [[self statusItem] setMenu:[self menu]];
    [[self statusItem] setHighlightMode:YES];
    
    NSData* schedule = [[NSUserDefaults standardUserDefaults] dataForKey:@"schedule"];
    NSDictionary* games;
    NSError *error;
    
    if (!schedule) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.isthereagiantsgametoday.com/data/giants2017schedule.json"]];
        games = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"schedule"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        games = [NSJSONSerialization JSONObjectWithData:schedule options:kNilOptions error:&error];
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3600 repeats:YES block:^(NSTimer * _Nonnull timer) {
        // Today is...
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        NSArray* gameList = games[@"games"];
        __block NSDictionary* hasGame = nil;
        [gameList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* game = (NSDictionary*)obj;
            if ([stringFromDate isEqualToString:game[@"date"]]) {
                hasGame = game;
                *stop = YES;
            }
        }];
        
        if (hasGame) {
            NSString* location = (NSString*)hasGame[@"location"];
            NSString* time = (NSString*)hasGame[@"time"];
            BOOL isHome = [location containsString:@"San Francisco"];
            [[self statusItem] setTitle:[NSString stringWithFormat:@"%@ Game%@", isHome?@"Home":@"Away", isHome?[NSString stringWithFormat:@" @ %@", time]:@""]];
        } else {
            [[self statusItem] setTitle:@"No Game"];
        }
    }];
    [timer fire];
}

- (IBAction)menuAction:(id)sender {
    NSLog(@"menuAction:");
}

@end
