#import <UIKit/UIKit.h>

// On déclare les fonctions pour que le serveur GitHub ne dise pas "Undeclared"
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookMessageEx(Class _class, SEL selector, IMP replacement, IMP *result);
#ifdef __cplusplus
}
#endif

static BOOL menuVisible = NO;
static BOOL darkTheme = YES;

// --- WEBHOOK ---
static NSString *webhookURL = @"https://discord.com/api/webhooks/1457690928230699230/QON6TBFFdJV4_0J-Ft1tw5bkuw6WXmOEZ7kBHgH8j9ye0jO-xXP4MSaEATe21wLNpjBg";

void sendWebhookNotification() {
    NSURL *url = [NSURL URLWithString:webhookURL];
    if (!url) return;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *message = [NSString stringWithFormat:@"🚀 **OneState lancé !**\nUtilisateur : **%@**", deviceName];
    NSDictionary *jsonBody = @{@"content": message};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonBody options:0 error:nil];
    [request setHTTPBody:jsonData];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request] resume];
}

// --- INTERFACES ---
@interface FloatingIcon : UIButton
@end

@interface IOS18MenuView : UIView
@end

@implementation IOS18MenuView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(40, 120, 260, 200)];
    if (self) {
        UIBlurEffectStyle style = darkTheme ? UIBlurEffectStyleSystemUltraThinMaterialDark : UIBlurEffectStyleSystemUltraThinMaterialLight;
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        blur.frame = self.bounds;
        blur.layer.cornerRadius = 22;
        blur.clipsToBounds = YES;
        [self addSubview:blur];
    }
    return self;
}
@end

@implementation FloatingIcon
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(15, 80, 50, 50)];
    if (self) {
        self.layer.cornerRadius = 25;
        self.backgroundColor = [UIColor redColor]; // Simple pour tester la compilation
    }
    return self;
}
@end

// --- HOOKS ---
%hook UIApplication
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    sendWebhookNotification();
}
%end
