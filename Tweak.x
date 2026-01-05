#import <UIKit/UIKit.h>

// --- DÉCLARATIONS POUR LE COMPILATEUR ---
// Ces lignes permettent à GitHub de comprendre les fonctions Theos sans erreur
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookMessageEx(Class _class, SEL selector, IMP replacement, IMP *result);
#ifdef __cplusplus
}
#endif

static BOOL menuVisible = NO;
static BOOL darkTheme = YES;

// --- CONFIGURATION WEBHOOK ---
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

@interface FloatingIcon : UIButton
@end

@interface IOS18MenuView : UIView
@end

@implementation IOS18MenuView
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(40, 120, 260, 200)];
    if (self) {
        UIBlurEffectStyle style = darkTheme ? UIBlurEffectStyleSystemUltraThinMaterialDark : UIBlurEffectStyleSystemUltraThinMaterialLight;
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        blur.frame = self.bounds;
        blur.layer.cornerRadius = 22;
        blur.clipsToBounds = YES;
        [self addSubview:blur];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 260, 30)];
        title.text = @"OneState Menu";
        title.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        [blur.contentView addSubview:title];

        UIButton *tpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        tpBtn.frame = CGRectMake(50, 65, 160, 42);
        tpBtn.layer.cornerRadius = 14;
        tpBtn.backgroundColor = [UIColor systemRedColor];
        [tpBtn setTitle:@"TP to Marker" forState:UIControlStateNormal];
        [tpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tpBtn addTarget:self action:@selector(doTP) forControlEvents:UIControlEventTouchUpInside];
        [blur.contentView addSubview:tpBtn];

        UIButton *themeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        themeBtn.frame = CGRectMake(50, 120, 160, 42);
        themeBtn.layer.cornerRadius = 14;
        themeBtn.backgroundColor = [UIColor systemBlueColor];
        [themeBtn setTitle:@"Changer Thème" forState:UIControlStateNormal];
        [themeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [themeBtn addTarget:self action:@selector(toggleTheme) forControlEvents:UIControlEventTouchUpInside];
        [blur.contentView addSubview:themeBtn];
    }
    return self;
}
- (void)doTP { [[NSNotificationCenter defaultCenter] postNotificationName:@"ExecuteTP" object:nil]; }
- (void)toggleTheme {
    darkTheme = !darkTheme;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMenu" object:nil];
}
@end

@implementation FloatingIcon { CGPoint start; }
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(15, 80, 50, 50)];
    if (self) {
        self.layer.cornerRadius = 25;
        self.backgroundColor = [UIColor clearColor];    
        
        // Chargement asynchrone pour éviter de bloquer le démarrage
        NSURL *imageURL = [NSURL URLWithString:@"https://media.discordapp.net/attachments/1457690877769027725/1457695110601904129/image.png?ex=695cefdd&is=695b9e5d&hm=11415b61da5cf95aa58631bb668716ce9713cd49e518e66fd213136c6cae8b5d&=&format=webp&quality=lossless&width=461&height=461"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:imageURL];
            if (data) {
                UIImage *img = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImage:img forState:UIControlStateNormal];
                });
            }
        });

        [self addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)toggleMenu {
    menuVisible = !menuVisible;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ToggleMenu" object:nil];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { start = [[touches anyObject] locationInView:self]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint p = [[touches anyObject] locationInView:self.superview];
    self.center = CGPointMake(p.x - start.x + 25, p.y - start.y + 25);
}
@end

static IOS18MenuView *menuView;

%hook UIApplication
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    sendWebhookNotification();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        UIWindow *w = nil;
        // Correction pour récupérer la window sur iOS 13+
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        w = window;
                        break;
                    }
                }
            }
        }
        
        if (!w) w = [UIApplication sharedApplication].windows.firstObject;
        if (!w) return;

        FloatingIcon *icon = [[FloatingIcon alloc] init];
        [w addSubview:icon];

        menuView = [[IOS18MenuView alloc] init];
        menuView.alpha = 0;
        [w addSubview:menuView];

        [[NSNotificationCenter defaultCenter] addObserverForName:@"ToggleMenu" object:nil queue:nil usingBlock:^(NSNotification *n) {
            [UIView animateWithDuration:0.3 animations:^{ menuView.alpha = menuVisible ? 1 : 0; }];
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:@"ReloadMenu" object:nil queue:nil usingBlock:^(NSNotification *n) {
                [menuView removeFromSuperview];
                menuView = [[IOS18MenuView alloc] init];
                menuView.alpha = 1;
                UIWindow *currentWin = [UIApplication sharedApplication].windows.firstObject;
                [currentWin addSubview:menuView];
        }];
    });
}
%end
