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

@interface screenshortViewController () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *screenImageView;

@property (weak, nonatomic) IBOutlet UIButton *faceBookButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (weak, nonatomic) IBOutlet UIButton *addToAlbumButton;

@end

@implementation screenshortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

#define DEFAULT_CORNER_RASIUS_FOR_BUTTONS 6

- (void)updateUI {
        [_screenImageView setImage:_theImage];
        [_screenImageView reloadInputViews];
    
    [self setCornerRadius:_faceBookButton andRadius:DEFAULT_CORNER_RASIUS_FOR_BUTTONS];
    [self setCornerRadius:_emailButton andRadius:DEFAULT_CORNER_RASIUS_FOR_BUTTONS];
    [self setCornerRadius:_addToAlbumButton andRadius:DEFAULT_CORNER_RASIUS_FOR_BUTTONS];
    
}
- (void)setCornerRadius:(UIView *)view andRadius:(int)radius
{
    [view.layer setMasksToBounds:YES];
    [view.layer setCornerRadius:radius];
}


#pragma mark - FaceBook poste NOTE method


- (IBAction)facebookSharingAction:(id)sender {
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = _theImage;
        photo.userGenerated = YES;
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];
}



#pragma mark - Send email with sceenshort

- (IBAction)emailSendAction:(id)sender {
    
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
            
           // [self presentModalViewController:picker animated:YES];
            [self presentViewController:picker animated:YES completion:nil];
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
    
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction method "Save in album"

- (IBAction)saveInLibraryAction:(id)sender {
      SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        
        UIImageWriteToSavedPhotosAlbum(_theImage, self, selectorToCall, NULL);
}

- (void) imageWasSavedSuccessfully:(UIImage*)paramImage didFinishSavingWithError:(NSError*)paramError contextInfo:(void*)paramContextInfo {
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

@end
