//
//  ParticleDiscoverDeviceViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/16/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import "ParticleDiscoverDeviceViewController.h"
#import "ParticleSetupConnection.h"
#import "ParticleSetupCommManager.h"
#import "ParticleSelectNetworkViewController.h"
#import <Foundation/Foundation.h>
#ifdef USE_FRAMEWORKS
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Particle-SDK.h"
#endif
#import "ParticleSetupSecurityManager.h"
#import "ParticleSetupUILabel.h"
//#import "UIViewController+ParticleSetupCommManager.h"
#import "ParticleSetupUIElements.h"
#import "ParticleSetupVideoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "ParticleSetupCustomization.h"
#import "ParticleSetupConnection.h"
#import "ParticleSetupCommManager.h"

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif

@interface ParticleDiscoverDeviceViewController () <NSStreamDelegate, UIAlertViewDelegate, ParticleSelectNetworkViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wifiSignalImageView;

@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *troubleShootingButton;
@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (weak, nonatomic) IBOutlet UIImageView *brandBackgroundImage;
@property (strong, nonatomic) NSArray *scannedWifiList;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *step3Label;
@property (weak, nonatomic) IBOutlet ParticleSetupUIButton *readyButton;



@property (weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet ParticleSetupUIButton *showMeHowButton;

// new background local notification feature
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) NSTimer *backgroundTaskTimer;

@property (strong, nonatomic) NSTimer *checkConnectionTimer;
@property (atomic, strong) NSString *detectedDeviceID;
@property (atomic) BOOL gotPublicKey;
@property (atomic) BOOL gotOwnershipInfo;
@property (atomic) BOOL didGoToWifiListScreen;
@property (nonatomic) BOOL isDetectedDeviceClaimed;
@property (nonatomic) BOOL needToCheckDeviceClaimed;
@property (nonatomic) BOOL userAlreadyOwnsDevice;
@property (nonatomic) BOOL deviceClaimedByUser;
@property (nonatomic, strong) UIAlertView *changeOwnershipAlertView;
@property (weak, nonatomic) IBOutlet UIView *wifiView;
@property (nonatomic, strong) ParticleSetupConnection *tryConn;


@property (weak, nonatomic) IBOutlet UIImageView *connectToWifiImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wifiInfoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation ParticleDiscoverDeviceViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.didGoToWifiListScreen = NO;
    
    self.backgroundTask = UIBackgroundTaskInvalid;
    self.showMeHowButton.hidden = [ParticleSetupCustomization sharedInstance].instructionalVideoFilename ? NO : YES;
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppear:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // customize logo
    self.brandImage.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.brandImage.backgroundColor = [UIColor clearColor];
    self.brandBackgroundImage.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    self.brandBackgroundImage.image = [ParticleSetupCustomization sharedInstance].brandImageBackgroundImage;

    // force load of images from resource bundle
    self.connectToWifiImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"connect-to-wifi"];
    self.checkmarkImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"iosCheckmark"];
    self.wifiInfoImageView.image = [ParticleSetupMainController loadImageFromResourceBundle:@"iosSettingWifi"];

//    self.wifiSignalImageView.image = [UIImage imageNamed:@"iosSettingsWifi" inBundle:[ParticleSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
    self.wifiSignalImageView.hidden = NO;
    self.needToCheckDeviceClaimed = NO;
    
    self.gotPublicKey = NO;
    self.gotOwnershipInfo = NO;
    
    self.networkNameLabel.text = [NSString stringWithFormat:@"%@-XXXX",[ParticleSetupCustomization sharedInstance].networkNamePrefix];
    self.wifiView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.wifiView.layer.borderWidth = 1.0f;
    
//    self.cancelSetupButton. // customize color too
    self.cancelSetupButton.titleLabel.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].headerTextFontName size:self.self.cancelSetupButton.titleLabel.font.pointSize];
//    [self.cancelSetupButton setTitleColor:[ParticleSetupCustomization sharedInstance].normalTextColor forState:UIControlStateNormal];
    UIColor *navBarButtonsColor = ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? [UIColor whiteColor] : [UIColor blackColor];
    [self.cancelSetupButton setTitleColor:navBarButtonsColor forState:UIControlStateNormal];


    
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"DeviceSetup_DeviceDiscoveryScreen"];
#endif


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)resetWifiSignalIconWithDelay
{
    // TODO: this is a little bit of a hack
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.wifiSignalImageView.image = [UIImage imageNamed:@"iosSettingsWifi" inBundle:[ParticleSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        [self.spinner stopAnimating];
        self.wifiSignalImageView.hidden = NO;
    });
}

-(void)restartDeviceDetectionTimer
{
//    NSLog(@"restartDeviceDetectionTimer called");
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;

    if (!self.didGoToWifiListScreen)
        self.checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(checkDeviceWifiConnection:) userInfo:nil repeats:YES];
}

-(void)goToWifiListScreen
{
    if (self.didGoToWifiListScreen == NO)
    {
        self.didGoToWifiListScreen = YES;
        [self performSegueWithIdentifier:@"select_network" sender:self];
    }
}


-(void)willPopBackToDeviceDiscovery
{
    NSLog(@"willPopBackToDeviceDiscovery");
    self.didGoToWifiListScreen = NO;
    [self restartDeviceDetectionTimer];
}

- (IBAction)readyButton:(id)sender
{
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // TODO: solve this via autolayout?


    self.spinner.image = [self.spinner.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.spinner.tintColor = [UIColor blackColor];
    [self scheduleBackgroundTask];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self restartDeviceDetectionTimer];
}

-(void)checkDeviceConnectionForNotification:(NSTimer *)timer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            if ([ParticleSetupCommManager checkParticleDeviceWifiConnection:[ParticleSetupCustomization sharedInstance].networkNamePrefix])
            {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertAction = @"Connected";
                NSString *notifText = [NSString stringWithFormat:@"Your phone has connected to %@. Tap to continue Setup.",[ParticleSetupCustomization sharedInstance].deviceName];
                localNotification.alertBody = notifText;
                localNotification.alertAction = @"open"; // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                localNotification.soundName = UILocalNotificationDefaultSoundName; // play default sound
                localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                [timer invalidate];
            }
        }
    });
}

-(void)scheduleBackgroundTask
{
    [self.backgroundTaskTimer invalidate];
    self.backgroundTaskTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                target:self
                                                              selector:@selector(checkDeviceConnectionForNotification:)
                                                              userInfo:nil
                                                               repeats:YES];
    
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
}



-(void)ParticleSetupConnection:(ParticleSetupConnection *)connection didUpdateState:(ParticleSetupConnectionState)state error:(NSError *)error
{
    if (state == ParticleSetupConnectionStateOpened)
    {
//        NSLog(@"Photon detected!");
        [connection close];
        [self startPhotonQuery];
    }
}

-(void)startPhotonQuery
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self.checkConnectionTimer invalidate];

            dispatch_async(dispatch_get_main_queue(), ^{
                // UI activity indicator
                self.wifiSignalImageView.hidden = YES;
                [self.spinner startAnimating];
            });

            // Start connection command chain process with a small delay
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getDeviceID];
            });
        }
    });

}


-(void)checkDeviceWifiConnection:(id)sender
{
    if (@available(iOS 13.0, *) && (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways))) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:NO];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateActive) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if ([ParticleSetupCommManager checkParticleDeviceWifiConnection:[ParticleSetupCustomization sharedInstance].networkNamePrefix]) {
                        [self startPhotonQuery];
                    }
                });
            }
        });
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"select_network"])
    {

        [self.checkConnectionTimer invalidate];
        // Get reference to the destination view controller
        ParticleSelectNetworkViewController *vc = [segue destinationViewController];
        [vc setWifiList:self.scannedWifiList];
        vc.deviceID = self.detectedDeviceID;
        vc.delegate = self;
        vc.needToClaimDevice = self.needToCheckDeviceClaimed;
    }
    else if ([segue.identifier isEqualToString:@"video"])
    {
        ParticleSetupVideoViewController *vc = segue.destinationViewController;
        vc.videoFilePath = [ParticleSetupCustomization sharedInstance].instructionalVideoFilename;
    }
    
}


-(void)getDeviceID
{
    if (!self.detectedDeviceID)
    {
        [self.checkConnectionTimer invalidate];
        
        ParticleSetupCommManager *manager = [[ParticleSetupCommManager alloc] init];
        [manager deviceID:^(id deviceResponseDict, NSError *error)
        {
//            NSLog(@"DeviceID sent");
             if (error)
             {
                 NSLog(@"Could not send device-id command: %@", error.localizedDescription);
                 [self restartDeviceDetectionTimer];
                 [self resetWifiSignalIconWithDelay];
                 
             }
             else
             {

                 self.detectedDeviceID = (NSString *)deviceResponseDict[@"id"]; //TODO: fix that dict interpretation is done in comm manager (layer completion)
                 self.detectedDeviceID = [self.detectedDeviceID lowercaseString];
                 self.isDetectedDeviceClaimed = [deviceResponseDict[@"c"] boolValue];
//                 NSLog(@"DeviceID response received: %@",self.detectedDeviceID );

                 [self photonPublicKey];
//                 NSLog(@"Got device ID: %@",deviceResponseDict);
             }
         }];
    }
    else
    {
//        NSLog(@"getDeviceID called again");
        [self photonPublicKey];
    }
}




-(void)photonScanAP
{
    if (!self.scannedWifiList)
    {
        ParticleSetupCommManager *manager = [[ParticleSetupCommManager alloc] init];
//        NSLog(@"ScanAP sent");
        [manager scanAP:^(id scanResponse, NSError *error) {
            if (error)
            {
                NSLog(@"Could not send scan-ap command: %@",error.localizedDescription);
                [self restartDeviceDetectionTimer];
                [self resetWifiSignalIconWithDelay];
            }
            else
            {
                if (scanResponse)
                {
//                    NSLog(@"ScanAP response received");
                    self.scannedWifiList = scanResponse;
//                    NSLog(@"Scan data:\n%@",self.scannedWifiList);
                    [self checkDeviceOwnershipChange];
                    
                }
                
            }
        }];
    }
    else
    {
        [self checkDeviceOwnershipChange];
    }
    
}


-(void)checkDeviceOwnershipChange
{
    if (!self.gotOwnershipInfo)
    {
        [self.checkConnectionTimer invalidate];
        self.needToCheckDeviceClaimed = NO;
        
//        self.isDetectedDeviceClaimed = YES; // DEBUG
        if (!self.isDetectedDeviceClaimed) // device was never claimed before - so we need to claim it anyways
        {
            if (self.claimCode) {
                self.needToCheckDeviceClaimed = YES;
                [self setDeviceClaimCode];
            } else {
                self.needToCheckDeviceClaimed = NO;
                [self goToWifiListScreen];
            }
        }
        else
        {
            self.deviceClaimedByUser = NO;
            
            for (NSString *claimedDeviceID in self.claimedDevices)
            {
                if ([claimedDeviceID isEqualToString:self.detectedDeviceID])
                {
                    self.deviceClaimedByUser = YES;
                }
            }
            
            // if the user already owns the device it does not need to be set with a claim code but claiming check should be performed as last stage of setup process
            if (self.deviceClaimedByUser)
                self.needToCheckDeviceClaimed = YES;
            
            self.gotOwnershipInfo = YES;
            
            if ((self.isDetectedDeviceClaimed == YES) && (self.deviceClaimedByUser == NO))
            {
                if (!self.didGoToWifiListScreen)
                {

                    if ([ParticleCloud sharedInstance].isAuthenticated)
                    {
                        // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
                        NSString *messageStr = [NSString stringWithFormat:@"Do you want to claim ownership of this %@ to %@?",[ParticleSetupCustomization sharedInstance].deviceName,[ParticleCloud sharedInstance].loggedInUsername];
                        self.changeOwnershipAlertView = [[UIAlertView alloc] initWithTitle:@"Product ownership" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
                        [self.checkConnectionTimer invalidate];
                        [self.changeOwnershipAlertView show];
                    }
                    else // user skipped authentication so no need to claim or set claim code
                    {
                        self.needToCheckDeviceClaimed = NO;
                        [self goToWifiListScreen];

                    }
                }
            }
            else
            {
                // no need to set claim code because the device is owned by current user
                [self goToWifiListScreen];
            }
            
        }
        
        // all cases:
//        (1) device not claimed c=0 — device should also not be in list from API => mobile app assumes user is claiming and sets device claimCode + check its claimed at last stage
//        (2) device claimed c=1 and already in list from API => mobile app does not ask user about taking ownership because device already belongs to this user, does NOT set claimCode to device (no need) but does check ownership in last setup step
//        (3) device claimed c=1 and NOT in the list from the API => mobile app asks whether user would like to take ownership. YES: set claimCode and check ownership in last step, NO: doesn't set claimCode, doesn't check ownership in last step
    }
    else
    {
        if (self.needToCheckDeviceClaimed)
        {
            if (!self.deviceClaimedByUser)
                [self setDeviceClaimCode];
        }
        else
            [self goToWifiListScreen];
        
    }
    
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.changeOwnershipAlertView)
    {
        if (buttonIndex == 0) //YES
        {
            self.needToCheckDeviceClaimed = YES;
            [self setDeviceClaimCode];
        }
        else
        {
            self.needToCheckDeviceClaimed = NO;
            [self goToWifiListScreen];
        }
    }
}




-(void)photonPublicKey
{
    if (!self.gotPublicKey)
    {
//        NSLog(@"PublicKey sent");
        [self.checkConnectionTimer invalidate];
        ParticleSetupCommManager *manager = [[ParticleSetupCommManager alloc] init];
        [manager publicKey:^(id responseCode, NSError *error) {
            if (error)
            {
                NSLog(@"Error sending public-key command to target: %@",error.localizedDescription);
                [self restartDeviceDetectionTimer]; // TODO: better error handling
                [self resetWifiSignalIconWithDelay];
                
            }
            else
            {
                NSInteger code = [responseCode integerValue];
                if (code != 0)
                {
                    NSLog(@"Public key retrival error");
                    [self restartDeviceDetectionTimer]; // TODO: better error handling
                    [self resetWifiSignalIconWithDelay];
                    
                }
                else
                {
//                    NSLog(@"PublicKey response received");
                    self.gotPublicKey = YES;
                    [self photonScanAP];
                }
            }
        }];
    }
    else
    {
        [self photonScanAP];
    }
}




-(void)setDeviceClaimCode
{
    ParticleSetupCommManager *manager = [[ParticleSetupCommManager alloc] init];
    [self.checkConnectionTimer invalidate];
//    NSLog(@"Claim code - trying to set");
    [manager setClaimCode:self.claimCode completion:^(id responseCode, NSError *error) {
        if (error)
        {
            NSLog(@"Could not send set command: %@", error.localizedDescription);
            [self restartDeviceDetectionTimer];
        }
        else
        {
//            NSLog(@"Device claim code set successfully: %@",self.claimCode);
            // finished - segue
            [self goToWifiListScreen];

        }
    }];
    
}




-(void)getDeviceVersion
{
    [self.checkConnectionTimer invalidate];

    ParticleSetupCommManager *manager = [[ParticleSetupCommManager alloc] init];
    [manager version:^(id version, NSError *error) {
        if (error)
        {
            NSLog(@"Could not send version command: %@",error.localizedDescription);
        }
        else
        {
//            NSString *versionStr = version;
//            NSLog(@"Device version:\n%@",versionStr);
        }
    }];
}



- (IBAction)cancelButtonTouched:(id)sender
{
    // finish gracefully
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kParticleSetupDidFinishNotification object:nil userInfo:@{kParticleSetupDidFinishStateKey:@(ParticleSetupMainControllerResultUserCancel)}];
    
    
}




@end
