#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

static double customLat = 39.9042;
static double customLng = 116.4074;
static BOOL isSpoofing = NO;

%hook CLLocation

- (CLLocationCoordinate2D)coordinate {
    if (isSpoofing) {
        CLLocationCoordinate2D coords;
        coords.latitude = customLat;
        coords.longitude = customLng;
        return coords;
    }
    return %orig;
}

- (double)latitude { return isSpoofing ? customLat : %orig; }
- (double)longitude { return isSpoofing ? customLng : %orig; }

%end

%hook UIWindow

- (void)becomeKeyWindow {
    %orig;

    UILongPressGestureRecognizer *g = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleFake:)];
    g.minimumPressDuration = 1.0;
    g.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:g];
}

%new
- (void)handleFake:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"虚拟定位"
                                                                       message:@"输入纬度,经度 (如 39.9042,116.4074)"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"纬度, 经度";
        }];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *input = alert.textFields.firstObject.text;
            NSArray *parts = [input componentsSeparatedByString:@","];
            if (parts.count == 2) {
                customLat = [parts[0] doubleValue];
                customLng = [parts[1] doubleValue];
                isSpoofing = YES;
            }
        }];

        [alert addAction:ok];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

%end
