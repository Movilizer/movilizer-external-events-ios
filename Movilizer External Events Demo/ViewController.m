//
//  ViewController.m
//  Movilizer External Events Demo
//
//  Created by Nick Penkov on 3/14/16.
//  Copyright © 2016 Movilizer GmbH. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSDictionary *_endpoints;
    NSDictionary *_endpointUrls;
    int _selectedEndpoint;
    int _eventId;
    UIPickerView *_targetPickerView;
}

@property (weak, nonatomic) IBOutlet UITextView *jsonPayloadTV;
@property (weak, nonatomic) IBOutlet UITextField *eventSrcID;
@property (weak, nonatomic) IBOutlet UITextView *statusMessageTV;
@property (weak, nonatomic) IBOutlet UITextField *targetTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _endpoints = @{@0: @"Movilizer", @1: @"Movilizer Pro"}; // movi-ev-sb:// & movi-ev-pro://
    _endpointUrls = @{@0: @"movi-ev-sb://", @1: @"movi-ev-pro://"};
    
    // Initialize Picker View for targets app schema URLs
    _targetPickerView = [[UIPickerView alloc] init];
    
    [_targetPickerView setDataSource:self];
    [_targetPickerView setDelegate:self];
    
    _selectedEndpoint = 0;
    [_targetPickerView selectRow:_selectedEndpoint inComponent:0 animated:NO];
    
    self.targetTF.inputView = _targetPickerView;
    
    [self.targetTF setText:[_endpoints objectForKey:[NSNumber numberWithInt:_selectedEndpoint]]];
    
    // When click on the view - dismiss keyboard
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDismissKeyboard)];
    [tapRecognizer cancelsTouchesInView];
    [[self view] addGestureRecognizer:tapRecognizer];
    _eventId = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)sendButtonClick:(UIButton *)sender {
    NSString *eventSourceId = [self.eventSrcID text];
    NSString *json = [self.jsonPayloadTV text];
    NSString *encodedQueryString = [NSString stringWithFormat:@"?eventSourceId=%@&eventID=%d&eventType=0&json=%@",
                                    eventSourceId, _eventId++,
                                    [json stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",
                     [_endpointUrls objectForKey:[NSNumber numberWithInt:(int)_selectedEndpoint]],
                     encodedQueryString];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIDevice currentDevice].systemVersion intValue] >= 9) {
        // Directly open the url
        [[UIApplication sharedApplication] openURL:url];
    } else {
        // IOS 8 and bellow
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [self.statusMessageTV setText:@"Cannot open Movilizer. Please check if it is installed"];
        }
    }
    
}

- (IBAction)onClickTarget:(UITextField *)sender {
    
}

- (void)userDismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - PickerView Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_endpoints count];
}

#pragma mark - PickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component){
        case 0:
            return [_endpoints objectForKey:[NSNumber numberWithInt:(int)row]];
            break;
        default:
            // Unknown component
            NSAssert(false, @"Unkown component for Picker view %ld", component);
            break;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedEndpoint = (int)row;
    [self.targetTF setText:[_endpoints objectForKey:[NSNumber numberWithInt:_selectedEndpoint]]];
}

@end
