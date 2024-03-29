//
//  ParticleUserSignupViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Particle. All rights reserved.
//

#import "ParticleUserSignupViewController.h"
#ifdef USE_FRAMEWORKS
#import <ParticleSDK/ParticleSDK.h>
#import <OnePasswordExtension/OnePasswordExtension.h>
#else
#import "Particle-SDK.h"
#import "OnePasswordExtension.h"
#endif
#import "ParticleUserLoginViewController.h"
#import "ParticleSetupWebViewController.h"
#import "ParticleSetupCustomization.h"
#import "ParticleSetupUIElements.h"
#import "ParticleSetupMainController.h"

#ifdef ANALYTICS
#import <SEGAnalytics.h>
#endif




@interface ParticleUserSignupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet ParticleSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordVerifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *haveAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *createAccountLabel;
@property (weak, nonatomic) IBOutlet ParticleSetupUIButton *skipAuthButton;
@property (strong, nonatomic) UIAlertView *skipAuthAlertView;
@property (weak, nonatomic) IBOutlet UIButton *onePasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *businessAccountSwitch;
@property (weak, nonatomic) IBOutlet ParticleSetupUILabel *businessAccountLabel;
@property (weak, nonatomic) IBOutlet UIView *TosAndPpView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *contentView;
@property (weak, nonatomic) IBOutlet UIView *extraSpacer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TOSSpacerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *BottomSpacer;

@end

@implementation ParticleUserSignupViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([ParticleSetupCustomization sharedInstance].lightStatusAndNavBar) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}


-(void)applyDesignToTextField:(UITextField *)textField {
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    textField.leftView = emptyView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyNext;
    textField.font = [UIFont fontWithName:[ParticleSetupCustomization sharedInstance].normalTextFontName size:16.0];

}

- (IBAction)businessAccountSwitchChanged:(id)sender {
    if (self.businessAccountSwitch.on) {
        self.companyNameTextField.alpha = 1.0;
        self.companyNameTextField.userInteractionEnabled = YES;
        self.businessAccountLabel.text = @"This is a business account";
    } else {
        self.companyNameTextField.alpha = 0.6;
        self.companyNameTextField.userInteractionEnabled = NO;
        self.businessAccountLabel.text = @"This is a personal account";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // set brand logo
    self.logoImageView.image = [ParticleSetupCustomization sharedInstance].brandImage;
    self.logoImageView.backgroundColor = [UIColor clearColor];

    self.logoBackgroundImageView.backgroundColor = [ParticleSetupCustomization sharedInstance].brandImageBackgroundColor;
    self.logoBackgroundImageView.image = [ParticleSetupCustomization sharedInstance].brandImageBackgroundImage;
    

    [self applyDesignToTextField:self.emailTextField];
    [self applyDesignToTextField:self.passwordTextField];
    [self applyDesignToTextField:self.passwordVerifyTextField];
    
    [self applyDesignToTextField:self.firstNameTextField];
    [self applyDesignToTextField:self.lastNameTextField];
    [self applyDesignToTextField:self.companyNameTextField];
    

    if ([ParticleSetupCustomization sharedInstance].productMode)
    {
        self.firstNameTextField.hidden = YES;
        self.lastNameTextField.hidden = YES;
        self.companyNameTextField.hidden = YES;
        self.businessAccountLabel.hidden = YES;
        self.businessAccountSwitch.hidden = YES;

        self.extraSpacer.hidden = YES;
    }

    // make sign up button be closer to verify password textfield (no activation code field)
     self.skipAuthButton.hidden = !([ParticleSetupCustomization sharedInstance].allowSkipAuthentication);
    
    [self.onePasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
    if (!self.onePasswordButton.hidden) {
        self.onePasswordButton.hidden = ![ParticleSetupCustomization sharedInstance].allowPasswordManager;
    }

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField)
    {
        [self.passwordVerifyTextField becomeFirstResponder];
    }
    if (textField == self.passwordVerifyTextField)
    {
        [self.firstNameTextField becomeFirstResponder];
    }
    if (textField == self.firstNameTextField)
    {
        [self.lastNameTextField becomeFirstResponder];
    }
    if (textField == self.lastNameTextField)
    {
        [self signupButton:self];
    }

    return YES;
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];

    UIEdgeInsets scrollViewInsets = UIEdgeInsetsZero;

    self.TOSSpacerHeightConstraint.constant = 6;
    self.BottomSpacer.hidden = NO;

    if (CGRectGetHeight(self.scrollView.bounds) > (CGRectGetHeight(self.contentView.bounds) + 10)) {
        CGFloat inset = (CGRectGetHeight(self.scrollView.bounds) - CGRectGetHeight(self.contentView.bounds)) / 2;
        scrollViewInsets.top = inset - 5.0f;

        self.TOSSpacerHeightConstraint.constant = inset + 10;
        self.BottomSpacer.hidden = YES;
    }

    self.scrollView.contentInset = scrollViewInsets;
}


-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[SEGAnalytics sharedAnalytics] track:@"Auth_SignUpScreen"];
#endif
    [self businessAccountSwitchChanged:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onePasswordButtonTapped:(id)sender {
    NSDictionary *newLoginDetails = @{
                                      AppExtensionTitleKey: @"Particle",
                                      AppExtensionUsernameKey: self.emailTextField.text ? : @"",
                                      AppExtensionPasswordKey: self.passwordTextField.text ? : @"",
                                      AppExtensionNotesKey: @"Saved with the Particle app",
                                      AppExtensionSectionTitleKey: @"Particle",
                                      AppExtensionFieldsKey: @{
                                              @"username" : self.emailTextField.text ? : @""
                                              // Add as many string fields as you please.
                                              }
                                      };
    
    // The password generation options are optional, but are very handy in case you have strict rules about password lengths, symbols and digits.
    NSDictionary *passwordGenerationOptions = @{
                                                // The minimum password length can be 4 or more.
                                                AppExtensionGeneratedPasswordMinLengthKey: @(8),
                                                
                                                // The maximum password length can be 50 or less.
                                                AppExtensionGeneratedPasswordMaxLengthKey: @(30),
                                                
                                                // If YES, the 1Password will guarantee that the generated password will contain at least one digit (number between 0 and 9). Passing NO will not exclude digits from the generated password.
                                                AppExtensionGeneratedPasswordRequireDigitsKey: @(YES),
                                                
                                                // If YES, the 1Password will guarantee that the generated password will contain at least one symbol (See the list bellow). Passing NO with will exclude symbols from the generated password.
                                                AppExtensionGeneratedPasswordRequireSymbolsKey: @(NO),
                                                
                                                // Here are all the symbols available in the the 1Password Password Generator:
                                                // !@#$%^&*()_-+=|[]{}'\";.,>?/~`
                                                // The string for AppExtensionGeneratedPasswordForbiddenCharactersKey should contain the symbols and characters that you wish 1Password to exclude from the generated password.
                                                AppExtensionGeneratedPasswordForbiddenCharactersKey: @"!@#$%/0lIO"
                                                };
    
    [[OnePasswordExtension sharedExtension] storeLoginForURLString:@"https://login.particle.io" loginDetails:newLoginDetails passwordGenerationOptions:passwordGenerationOptions forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
        
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Failed to use 1Password App Extension to save a new Login: %@", error);
            }
            return;
        }
        
        self.emailTextField.text = loginDictionary[AppExtensionUsernameKey] ? : @"";
        self.passwordTextField.text = loginDictionary[AppExtensionPasswordKey] ? : @"";
        self.passwordVerifyTextField.text = loginDictionary[AppExtensionPasswordKey] ? : @"";
        // retrieve any additional fields that were passed in newLoginDetails dictionary
    }];
}

- (IBAction)signupButton:(id)sender
{
    [self.view endEditing:YES];

    //trim spaces on all textfields
    [self trimTextFieldValue:self.emailTextField];
    [self trimTextFieldValue:self.firstNameTextField];
    [self trimTextFieldValue:self.lastNameTextField];
    [self trimTextFieldValue:self.companyNameTextField];

    NSString *email = [self.emailTextField.text lowercaseString];
    NSString *password1 = self.passwordTextField.text;
    NSString *password2 = self.passwordVerifyTextField.text;

    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"last_used_email"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (password1.length < 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password must be at least 8 characters long" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else if (![password1 isEqualToString:password2])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords do not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self isValidEmail:email])
    {
        BOOL productMode = [ParticleSetupCustomization sharedInstance].productMode;
        if (productMode)
        {
            // org user sign up
            [self.spinner startAnimating];
            self.signupButton.enabled = NO;
            
            // Sign up and then login
            [[ParticleCloud sharedInstance] createCustomer:email password:password1 productId:[ParticleSetupCustomization sharedInstance].productId accountInfo:nil completion:^(NSError *error) {
                if (!error)
                {
#ifdef ANALYTICS
                    [[SEGAnalytics sharedAnalytics] track:@"Auth_SignedUpNewCustomer"];
#endif
                    
                    [self.delegate didFinishUserAuthentication:self loggedIn:YES];

                }
                else
                {
                    [self.spinner stopAnimating];
                    self.signupButton.enabled = YES;
                    NSLog(@"Error signing up: %@",error.localizedDescription);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not signup" message:@"Make sure your user email does not already exist and that you have entered the activation code correctly and that it was not already used"/*error.localizedDescription*/ delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            }];
        }
        else
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if ([ParticleSetupCustomization sharedInstance].organization) {
                NSException* deprecationException = [NSException
                                                     exceptionWithName:@"OrganizationModeDeprecated"
                                                     reason:@"You can no longer use orgnaization mode, set productMode to true and set your productId"
                                                     userInfo:nil];
                @throw deprecationException;
            }
#pragma clang diagnostic pop
            
            // normal user sign up
            [self.spinner startAnimating];
            self.signupButton.enabled = NO;

            NSString *firstName = self.firstNameTextField.text;
            NSString *lastName = self.lastNameTextField.text;
            NSString *companyName = self.companyNameTextField.text;

            NSMutableDictionary *accountInfo;
            if (firstName.length > 0 || lastName.length > 0 || companyName.length > 0) {
                accountInfo = [@{@"first_name":firstName,
                                 @"last_name":lastName,
                                 @"business_account":[NSNumber numberWithBool:self.businessAccountSwitch.on]
                                 } mutableCopy];
                
                if (self.businessAccountSwitch.on) {
                    accountInfo[@"company_name"] = companyName;
                }
            }
            
            // Sign up and then login
            [[ParticleCloud sharedInstance] createUser:email password:self.passwordTextField.text accountInfo:accountInfo completion:^(NSError *error) {
                if (!error)
                {
#ifdef ANALYTICS
                    [[SEGAnalytics sharedAnalytics] track:@"Auth_SignedUpNewUser"];
#endif
                    
                    [[ParticleCloud sharedInstance] loginWithUser:email password:self.passwordTextField.text completion:^(NSError *error) {
                        [self.spinner stopAnimating];
                        self.signupButton.enabled = YES;
                        if (!error)
                        {
                            //                        [self performSegueWithIdentifier:@"discover" sender:self];
                            [self.delegate didFinishUserAuthentication:self loggedIn:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                }
                else
                {
                    [self.spinner stopAnimating];
                    self.signupButton.enabled = YES;
                    NSLog(@"Error signing up: %@",error.localizedDescription);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
            }];
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)privacyPolicyButton:(id)sender
{
    [self.view endEditing:YES];
    
    ParticleSetupWebViewController* webVC = [[ParticleSetupMainController getSetupStoryboard]instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [ParticleSetupCustomization sharedInstance].privacyPolicyLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)termOfServiceButton:(id)sender
{
    [self.view endEditing:YES];

    ParticleSetupWebViewController* webVC = [[ParticleSetupMainController getSetupStoryboard] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [ParticleSetupCustomization sharedInstance].termsOfServiceLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)haveAnAccountButtonTouched:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate didRequestUserLogin:self];
}

- (IBAction)skipAuthButtonTapped:(id)sender {
    // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
    NSString *messageStr = [ParticleSetupCustomization sharedInstance].skipAuthenticationMessage;
    self.skipAuthAlertView = [[UIAlertView alloc] initWithTitle:@"Skip authentication" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
    [self.skipAuthAlertView show];

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.skipAuthAlertView)
    {
        if (buttonIndex == 0) //YES
        {
#ifdef ANALYTICS
            [[SEGAnalytics sharedAnalytics] track:@"Auth_AuthSkipped"];
#endif
            [self.delegate didFinishUserAuthentication:self loggedIn:NO];
        }
    }
}


@end
