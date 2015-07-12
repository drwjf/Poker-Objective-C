//
//  GamerDataViewController.m
//  Poker
//
//  Created by Admin on 22.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "GamerDataViewController.h"
#import "ConnectionToServer.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AnimationOnTheTable.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


#define GET_ACCEPT 0
#define GET_STRING 1
#define GET_INT_VALUE 2
#define GET_GAMER_NAME    3
#define GET_GAMER_MONEY   4
#define GET_GAMER_LEVEL   5
#define GET_COUNT_GAMERS_ON_THE_TABLE  6

#define GET_REQUEST_FROM_SERVER 7
#define DID_WRITE_RESPONSE 101

@interface GamerDataViewController () <ConnectionToServerDelegate>

-(void)checkDefaultParameters;
@property(nonatomic,strong)UIImage *buffImage;
-(void)createEmail;

@end

@implementation GamerDataViewController

static NSString* kAppId = @"639088652858131";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkDefaultParameters];
    [self setViewParameters];
    _buffImage = nil;
    [_enableAcceslerometerSwitcher setOn:NO animated:YES];
#if (TARGET_IPHONE_SIMULATOR)
    [_enableAcceslerometerSwitcher setEnabled:NO];
#endif
}

-(void)setViewParameters {
    [_playButton.layer setMasksToBounds:YES];
    [_playButton.layer setCornerRadius:50];
    
    [_rulesOfPokerTextView.layer setMasksToBounds:YES];
    [_rulesOfPokerTextView.layer setCornerRadius:20];
    
    [_gamerMoneyLabel.layer setMasksToBounds:YES];
    [_gamerMoneyLabel.layer setCornerRadius:10];
    
    [_gamersLevel.layer setMasksToBounds:YES];
    [_gamersLevel.layer setCornerRadius:10];
    
    [_enableAccelerometerLabel.layer setMasksToBounds:YES];
    [_enableAccelerometerLabel.layer setCornerRadius:10];
    
    [_sendMessageButton.layer setMasksToBounds:YES];
    [_sendMessageButton.layer setCornerRadius:20];
    
    [_imageOfGamer.layer setMasksToBounds:YES];
    [_imageOfGamer.layer setCornerRadius:10];
}

- (IBAction)sendMessageClick:(id)sender {
#if (TARGET_IPHONE_SIMULATOR)
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Success !"
                                                      message:@"Благодарственное письмо отправлено !"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [myAlert show];
    return;
#endif
    [self createEmail];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    NSString *message = nil;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message = @"Result: canceled";
            break;
        case MFMailComposeResultSaved:
            message = @"Result: saved";
            break;
        case MFMailComposeResultSent:
            message = @"Result: sent";
            break;
        case MFMailComposeResultFailed:
            message = @"Result: failed";
            break;
        default:
            message = @"Result: not sent";
            break;
    }
    
    NSLog(@"%@", message);
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void)createEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        //Тема письма
        [picker setSubject:@"Poker messager"];
        
        //Получатели
        NSArray *toRecipients = [NSArray arrayWithObject:@"AAA777SSS@yandex.ru"];
        NSArray *ccRecipients = [NSArray arrayWithObject:
                                 @"AAA777SSS@yandex.ru"];
        NSArray *bccRecipients = [NSArray arrayWithObject:@"AAA777SSS@yandex.ru"];
        
        [picker setToRecipients:toRecipients];
        [picker setCcRecipients:ccRecipients];
        [picker setBccRecipients:bccRecipients];
        
        NSString *emailBody = @"Hello from best poker in the World !";
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
    } else {
        NSString *ccRecipients = @"schurik77799@gmail.com,AAA777SSS@yandex.ru";
        NSString *subject = @"Hello from best poker in the World !";
        NSString *recipients = [NSString stringWithFormat:
                                @"mailto:schurik77799@gmail.com?cc=%@&subject=%@",
                                ccRecipients, subject];
        NSString *body = @"&body=This is the simple message from best popker in the World !";
        
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

- (IBAction)goToGameTable:(id)sender {
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    connection.delegate = self;
    
    [connection sendDataWithTag:@"I_WONNA_GO_TO_TABLE" andTag:DID_WRITE_RESPONSE];
}

-(void)checkDefaultParameters{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:@"name"];
   
    if([result length]) {
        NSString *gamerLevel = [[NSString alloc] initWithFormat:@"%@", [userDefaults objectForKey:@"level"]];
        int level = [gamerLevel intValue];
        level++;
        [userDefaults setInteger:level forKey:@"level"];
        
        
        _gamerName.text = [userDefaults objectForKey:@"name"];
        
        NSString *gamerMoney = [[NSString alloc ] initWithFormat:@"Money : %@ $", [userDefaults objectForKey:@"money"]];
        [_gamerMoneyLabel setText:gamerMoney];
        
        NSString *gamLevel = [[NSString alloc] initWithFormat:@"Level : %@", [userDefaults objectForKey:@"level"]];
        [_gamersLevel setText:gamLevel];
        
    } else {
        [userDefaults setObject:@"Anonymos" forKey:@"name"];
        [userDefaults setInteger:100000 forKey:@"money"];
        [userDefaults setInteger:0 forKey:@"level"];
        [userDefaults setObject:@"defaultImage.jpg" forKey:@"image"];
        [userDefaults synchronize];
    }
}


-(NSString*)returnIntValueFromId:(NSString*)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *outStr = [[NSString alloc] initWithFormat:@"%@", [userDefaults objectForKey:key]];
    
    return outStr;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    #if (TARGET_IPHONE_SIMULATOR)
        return;
    #endif
    
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    

    if(touch.view == self.imageOfGamer) {
        if([self isPhotoLibraryAvaible]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            
            if([self canUserPickPhotosFromThotoLibrary]) {
                [mediaTypes addObject:(__bridge NSString*)kUTTypeImage];
            }
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self.navigationController presentModalViewController:controller animated:YES];
        }   
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ConnectionToServer Delegate Methods

-(void)returnOnPreviusView {
    [self.navigationController popViewControllerAnimated:YES];
}

    -(void)updateInfo{
        ConnectionToServer *connect = [ConnectionToServer sharedInstance];
        connect.numberOfAttribut++;
        switch (connect.numberOfAttribut) {
            case 1:
                if([connect.receiveString isEqualToString:@"NAME?"]) {
                    NSLog(@"server : %@", connect.receiveString);
                    [connect sendData:_gamerName.text];
                    NSLog(@"client : %@",_gamerName.text);
                    [connect readDataWithTag:GET_STRING];
                }
                break;
            case 2:
                if([connect.receiveString isEqualToString:@"money?"]) {
                    NSLog(@"server : %@", connect.receiveString);
                    [connect sendData:[self returnIntValueFromId:@"money"]];
                    NSLog(@"client : %@", [self returnIntValueFromId:@"money"]);
                    [connect readDataWithTag:GET_STRING];
                }
                break;
                
            case 3:
                if([connect.receiveString isEqualToString:@"level?"]) {
                    NSLog(@"server : %@", connect.receiveString);
                    [connect sendData:[self returnIntValueFromId:@"level"]];
                    NSLog(@"client : %@", [self returnIntValueFromId:@"level"]);
                    
                    connect.numberOfAttribut = 0;
                    
                    [connect readDataWithTag:GET_ACCEPT]; //J;blfем ответа, что данные доставлены...
                }
                
            default:
                break;
        }
}

-(void)setNewGamerName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_gamerName.text forKey:@"name"];
    
}

-(void)accept{
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    NSString *string = [[NSString alloc] initWithString:connect.receiveString];
    
    if([string isEqualToString:@"YOU_ADDED_TO_GAME_LIST"]) {
        [self setNewGamerName];
        [self sendInfoAboutMySelf];
    } else if([string isEqualToString:@"received"]) {
        [self performSegueWithIdentifier:@"mySecondSegue" sender:self];
    } else {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Error :("
                                                          message:@"Check connection to WiFi and repeat again"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [myAlert show];
    }
}

-(void)sendInfoAboutMySelf {
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    connect.numberOfAttribut = 0;
    [connect sendData:@"received"];
    [connect readDataWithTag: GET_STRING];
}

-(void)updateInfoAboutPlayer{
   
}


#pragma mark UIImagePickerController delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(__bridge NSString*)kUTTypeImage]) {
        UIImage *theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        _buffImage = theImage;
        [_imageOfGamer setImage:theImage];
        [_imageOfGamer reloadInputViews];
    }
}

-(BOOL)isPhotoLibraryAvaible {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(BOOL)camerSupportMedia:(NSString*)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    
    if([paramMediaType length] == 0) {
        return  0;
    }
    NSArray *avaibleMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    
    [avaibleMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString*)obj;
        if([mediaType isEqualToString:paramMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

-(BOOL)canUserPickPhotosFromThotoLibrary {
    return [self camerSupportMedia:(__bridge NSString*)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AnimationOnTheTable *secVC = [segue destinationViewController];
    secVC.isUseAccelerometer = [_enableAcceslerometerSwitcher isOn];
    secVC.bufferImage = _buffImage;
}


@end