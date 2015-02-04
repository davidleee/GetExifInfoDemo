//
//  ViewController.m
//  GetExifInfoDemo
//
//  Created by Lee on 2/4/15.
//  Copyright (c) 2015 Lee. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface ViewController ()
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // here are two solutions for "Unbalance calls to begin/end appearance transitions", but neither is the best
    // since they all look a little bit hacky
    // the best way to do a presentVC is to do it in viewDidAppear:animated: , where all the UI elements of THIS VC are set
    
    // doesn't work in iOS 8, but I suppose it would work in iOS 7 and earlier versions
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentImagePicker];
//    });
    
    // can work but not so good
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self presentImagePicker];
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickPhotoAction:(id)sender
{
    [self presentImagePicker];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)presentImagePicker
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"[%@ %@] : Not Allowed To Open Photo Library!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
    [self accessExifDictionaryFromMediaInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Exif Getter

- (void)accessExifDictionaryFromMediaInfo:(NSDictionary *)info
{
    __weak typeof(self) weakSelf = self;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        
        NSDictionary *imageInfo = [asset defaultRepresentation].metadata;
        weakSelf.resultTextView.text = [NSString stringWithFormat:@"%@", imageInfo];
        
        /* that's it! */
        
        
        
        // the code below shows an old school way for those who want to know more
        // thanks to http://stackoverflow.com/a/9767129/4177374
        
//        // create a buffer to hold image data
//        uint8_t *buffer = (Byte *)malloc(image_representation.size);
//        NSUInteger length = [image_representation getBytes:buffer fromOffset:.0f length:image_representation.size error:nil];
//        
//        if (length) {
//            
//            // buffer -> NSData object; free buffer afterwards
//            NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:image_representation.size freeWhenDone:YES];
//            
//            // identify image type (jpeg, png, RAW file, ...) using UTI hint
//            NSDictionary *sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:[image_representation UTI], kCGImageSourceTypeIdentifierHint, nil];
//            
//            // create CGImageSource with NSData
//            CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)sourceOptionsDict);
//            
//            // get imagePropertiesDictionary
//            CFDictionaryRef imagePropertiesDictionary;
//            imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL);
//            
//            // get exif data
//            CFDictionaryRef exif = (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyExifDictionary);
//            NSDictionary *exif_dict = (__bridge NSDictionary*)exif;
//            NSLog(@"exif_dict: %@",exif_dict);
//            weakSelf.resultTextView.text = [NSString stringWithFormat:@"%@", exif_dict];
//            
//            // clean up
//            CFRelease(imagePropertiesDictionary);
//            CFRelease(sourceRef);
//        } else {
//            weakSelf.resultTextView.text = @"An Error Occurred In Creating Image Buffer!";
//        }
        
    } failureBlock:^(NSError *error) {
        
        weakSelf.resultTextView.text = @"Not Allowed To Access Photo Library!";
        
    }];
}

@end
