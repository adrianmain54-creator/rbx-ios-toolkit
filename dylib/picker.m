#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#include <unistd.h>

extern const char* rbxswap_assets_dir(void);
extern void set_rbxswap_enabled(int en);
extern int get_rbxswap_enabled(void);

@interface RBXSettingsVC : UIViewController <PHPickerViewControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) UITextField* idField;
@property (nonatomic, strong) UISwitch* masterSwitch;
@property (nonatomic, strong) UISwitch* boostSwitch;
@end

@implementation RBXSettingsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"RBXSwap Settings";
    
    UILabel* mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 200, 30)];
    mLabel.text = @"Enable Mods"; mLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:mLabel];
    
    self.masterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 100, 50, 30)];
    self.masterSwitch.on = get_rbxswap_enabled();
    [self.masterSwitch addTarget:self action:@selector(toggleMods:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.masterSwitch];
    
    UILabel* fLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 200, 30)];
    fLabel.text = @"FPS Boost (Restart)"; fLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:fLabel];
    
    self.boostSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 150, 50, 30)];
    [self.boostSwitch addTarget:self action:@selector(toggleBoost:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.boostSwitch];
    
    self.idField = [[UITextField alloc] initWithFrame:CGRectMake(20, 220, 320, 40)];
    self.idField.borderStyle = UITextBorderStyleRoundedRect; 
    self.idField.placeholder = @"Asset ID (e.g. 1234567)";
    self.idField.keyboardType = UIKeyboardTypeNumberPad; 
    [self.view addSubview:self.idField];
    
    UIButton* b1 = [UIButton buttonWithType:UIButtonTypeSystem]; b1.frame = CGRectMake(20, 280, 320, 40); 
    [b1 setTitle:@"Replace Asset (Photos)" forState:UIControlStateNormal]; 
    [b1 addTarget:self action:@selector(pickPhoto) forControlEvents:UIControlEventTouchUpInside]; 
    [self.view addSubview:b1];
    
    UIButton* b2 = [UIButton buttonWithType:UIButtonTypeSystem]; b2.frame = CGRectMake(20, 330, 320, 40); 
    [b2 setTitle:@"Replace Asset (Files)" forState:UIControlStateNormal]; 
    [b2 addTarget:self action:@selector(pickFile) forControlEvents:UIControlEventTouchUpInside]; 
    [self.view addSubview:b2];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
}

- (void)toggleMods:(UISwitch*)s { set_rbxswap_enabled(s.isOn); }
- (void)toggleBoost:(UISwitch*)s {
    NSString* path = [@(getenv("HOME")) stringByAppendingPathComponent:@"Library/Application Support/ClientAppSettings.json"];
    if (s.isOn) {
        NSString* json = @"{\n  \"DFIntTaskSchedulerTargetFps\": \"240\",\n  \"FIntDebugTextureManagerSkipMips\": \"1\",\n  \"DFIntTextureQualityOverride\": \"0\",\n  \"DFFlagTextureQualityOverrideEnabled\": \"true\",\n  \"FIntRenderShadowmapBias\": \"100000\",\n  \"FFlagDisablePostFx\": \"true\",\n  \"FIntFRMMinGrassDistance\": \"0\"\n}";
        [json writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    UIAlertController* a = [UIAlertController alertControllerWithTitle:@"Restart Required" message:@"Close and reopen Roblox." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)close { [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)pickPhoto {
    if (!self.idField.text.length) return;
    PHPickerConfiguration* cfg = [PHPickerConfiguration new]; cfg.filter = PHPickerFilter.imagesFilter;
    PHPickerViewController* p = [[PHPickerViewController alloc] initWithConfiguration:cfg]; p.delegate = self; [self presentViewController:p animated:YES completion:nil];
}
- (void)picker:(PHPickerViewController*)p didFinishPicking:(NSArray<PHPickerResult*>*)r {
    [p dismissViewControllerAnimated:YES completion:nil]; if (!r.count) return;
    [r[0].itemProvider loadObjectOfClass:UIImage.class completionHandler:^(UIImage* img, NSError* e) {
        if (img) {
            NSString* path = [@(rbxswap_assets_dir()) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", self.idField.text]];
            [UIImageJPEGRepresentation(img, 0.9) writeToFile:path atomically:YES];
        }
    }];
}
- (void)pickFile {
    if (!self.idField.text.length) return;
    UIDocumentPickerViewController* dp = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    dp.delegate = self; [self presentViewController:dp animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController*)dp didPickDocumentsAtURLs:(NSArray<NSURL*>*)u {
    [dp dismissViewControllerAnimated:YES completion:nil]; if (!u.count) return;
    NSString* path = [@(rbxswap_assets_dir()) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.idField.text, u[0].pathExtension]];
    [[NSFileManager defaultManager] copyItemAtURL:u[0] toURL:[NSURL fileURLWithPath:path] error:nil];
}
@end

@interface RBXFloatingButton : UIButton @end
@implementation RBXFloatingButton
- (void)drawRect:(CGRect)r {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [UIColor colorWithRed:0.1 green:0.6 blue:0.9 alpha:0.9].CGColor);
    CGContextFillEllipseInRect(c, r);
    [[UIColor whiteColor] setStroke]; CGContextSetLineWidth(c, 2); CGContextStrokeEllipseInRect(c, CGRectInset(r, 1, 1));
}
@end

__attribute__((constructor)) static void init_ui(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification* n){
            static dispatch_once_t once; dispatch_once(&once, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIWindow* w = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    w.windowLevel = UIWindowLevelAlert + 100; w.backgroundColor = [UIColor clearColor]; w.rootViewController = [UIViewController new];
                    
                    RBXFloatingButton* btn = [RBXFloatingButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(20, 80, 44, 44);
                    [btn setTitle:@"R" forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
                    [btn addTarget:w.rootViewController action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
                    
                    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:w.rootViewController action:@selector(drag:)];
                    [btn addGestureRecognizer:pan];
                    
                    [w.rootViewController.view addSubview:btn]; w.hidden = NO;
                });
            });
        }];
    });
}

@interface UIViewController (RBX) @end
@implementation UIViewController (RBX)
- (void)drag:(UIPanGestureRecognizer*)g {
    UIView* v = g.view; CGPoint t = [g translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y); [g setTranslation:CGPointZero inView:v.superview];
}
- (void)showSettings:(id)sender {
    RBXSettingsVC* vc = [RBXSettingsVC new];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}
@end
