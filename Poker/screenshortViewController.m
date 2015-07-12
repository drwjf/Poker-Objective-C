//
//  screenshortViewController.m
//  
//
//  Created by Admin on 01.06.15.
//
//

#import "screenshortViewController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface screenshortViewController ()
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *addToLibraryButton;

@end

@implementation screenshortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view.layer setMasksToBounds:YES];
    [self.view.layer setCornerRadius:15];
    
    [_facebookButton.layer setMasksToBounds:YES];
    [_facebookButton.layer setCornerRadius:10];
    
    [_emailButton.layer setMasksToBounds:YES];
    [_emailButton.layer setCornerRadius:10];
    
    [_addToLibraryButton.layer setMasksToBounds:YES];
    [_addToLibraryButton.layer setCornerRadius:10];
    
    [_screenImage.layer setMasksToBounds:YES];
    [_screenImage.layer setCornerRadius:5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadImage:) name:@"TestNotification" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadImage:(NSNotification*)notification {
    if([[notification name] isEqualToString:@"TestNotification"]) {
        NSLog(@"received");
        NSDictionary *userInfo = notification.userInfo;
        UIImage *image = [userInfo objectForKey:@"image"];
        _theImage = image;
        [_screenImage setImage:image];
        [_screenImage reloadInputViews];
    }
}

- (IBAction)quitClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)facebookSharingAction:(id)sender {
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatchQueue, ^(void) {
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = _theImage;
        photo.userGenerated = YES;
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];
    });
}


- (IBAction)emailSendAction:(id)sender {
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatchQueue, ^(void) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            //Тема письма
            [picker setSubject:@"Good creenshort !"];
            
            //Получатели
            NSArray *toRecipients = [NSArray arrayWithObject:@"Email ..."];
            
            [picker setToRecipients:toRecipients];
            //Прикрепление файлов к письму
            NSData *imageData = UIImageJPEGRepresentation(_theImage, 1.0);
                   [picker addAttachmentData:imageData mimeType:@"image/jpg" fileName:_theImage.accessibilityIdentifier];
            
            NSString *emailBody = @"Look at ! I advice you to download. I think, that you will not regret !";
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
    });
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

- (IBAction)saveInLibraryAction:(id)sender {
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatchQueue, ^(void) {
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        
        UIImageWriteToSavedPhotosAlbum(_theImage, self, selectorToCall, NULL);
    });
}

-(void) imageWasSavedSuccessfully:(UIImage*)paramImage didFinishSavingWithError:(NSError*)paramError contextInfo:(void*)paramContextInfo {
    if(paramError == nil) {
        NSLog(@"Image was saved successfully");
    } else {
        UIAlertView *alertMy = [[UIAlertView alloc] initWithTitle:@"Error :("
                                              message:@"I'm sorry, but image wasn't saved in album ..."
                                             delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
        [alertMy show];
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
