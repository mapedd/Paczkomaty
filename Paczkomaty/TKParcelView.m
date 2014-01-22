//
//  TKParcelView.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelView.h"
#import "TKParcelLocker.h"

@interface TKParcelView () <MKMapViewDelegate>

@property (readwrite, strong, nonatomic) MKMapView *mapView;
@property (readwrite, strong, nonatomic) UILabel *nameLabel;
@property (readwrite, strong, nonatomic) UILabel *addressLabel;
@property (readwrite, strong, nonatomic) UILabel *localisationLabel;
@property (readwrite, strong, nonatomic) UILabel *hoursLabel;
@property (readwrite, strong, nonatomic) UILabel *paymentLabel;

@end

@implementation TKParcelView

#pragma mark - NSObject

- (void)dealloc{
    [self registerObservers:NO];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    [self setup];
    [self registerObservers:YES];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    [self setNeedsLayout];
}

#pragma mark - UIView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat inset = 10.0f;
    CGFloat labelWidth = width - 2 * inset;
    
    CGRect mapViewFrame = CGRectZero;
    CGRect nameLabelFrame = CGRectZero;
    CGRect addressLabelFrame = CGRectZero;
    
    CGRect localistaionLabelFrame = CGRectZero;
    CGRect hoursLabeFrame = CGRectZero;
    CGRect paymentLabelFrame = CGRectZero;
    
    CGFloat nameLabelHeight = [self.nameLabel.text sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(labelWidth, 999)].height;
    CGFloat addressLabelHeight = [self.addressLabel.text sizeWithFont:self.addressLabel.font constrainedToSize:CGSizeMake(labelWidth, 999)].height;
    
    
    CGFloat localisaitonLabelHeight = [self.localisationLabel.attributedText boundingRectWithSize:CGSizeMake(labelWidth, 9999)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                         context:0].size.height;
    CGFloat hoursLabelHeight = [self.hoursLabel.attributedText boundingRectWithSize:CGSizeMake(labelWidth, 9999)
                                                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                   context:0].size.height;
    CGFloat paymentLabelHeight = [self.paymentLabel.attributedText boundingRectWithSize:CGSizeMake(labelWidth, 9999)
                                                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                     context:0].size.height;
    
    mapViewFrame = CGRectMake(0.0f, 0.0f, width, 100.0f);
    nameLabelFrame = CGRectMake(inset,inset + CGRectGetMaxY(mapViewFrame), labelWidth, nameLabelHeight);
    addressLabelFrame = CGRectMake(inset, inset + CGRectGetMaxY(nameLabelFrame), labelWidth, addressLabelHeight);
    
    localistaionLabelFrame = CGRectMake(inset, inset + CGRectGetMaxY(addressLabelFrame), labelWidth, localisaitonLabelHeight);
    hoursLabeFrame = CGRectMake(inset, inset + CGRectGetMaxY(localistaionLabelFrame), labelWidth, hoursLabelHeight);
    paymentLabelFrame = CGRectMake(inset, inset + CGRectGetMaxY(hoursLabeFrame), labelWidth, paymentLabelHeight);
    
    self.nameLabel.frame = nameLabelFrame;
    self.addressLabel.frame = addressLabelFrame;
    self.mapView.frame = mapViewFrame;
    self.localisationLabel.frame = localistaionLabelFrame;
    self.hoursLabel.frame = hoursLabeFrame;
    self.paymentLabel.frame = paymentLabelFrame;
    
    CGFloat height = CGRectGetMaxY(paymentLabelFrame) + inset;
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, height);
    
}

#pragma mark - Setters

- (void)setParcel:(TKParcelLocker *)parcel{
    if (_parcel != parcel) {
        _parcel = parcel;
        [self reloadData];
    }
}

#pragma mark - Private

- (void)registerObservers:(BOOL)registerOrNot{
    if (registerOrNot) {
        [self.nameLabel addObserver:self forKeyPath:@"text" options:0 context:NULL];
        [self.addressLabel addObserver:self forKeyPath:@"text" options:0 context:NULL];
        
        [self.localisationLabel addObserver:self forKeyPath:@"attributedText" options:0 context:NULL];
        [self.hoursLabel addObserver:self forKeyPath:@"attributedText" options:0 context:NULL];
        [self.paymentLabel addObserver:self forKeyPath:@"attributedText" options:0 context:NULL];
    }else{
        [self.nameLabel removeObserver:self forKeyPath:@"text"];
        [self.addressLabel removeObserver:self forKeyPath:@"text" context:NULL];
        
        [self.localisationLabel removeObserver:self forKeyPath:@"attributedText" context:NULL];
        [self.hoursLabel removeObserver:self forKeyPath:@"attributedText" context:NULL];
        [self.paymentLabel removeObserver:self forKeyPath:@"attributedText" context:NULL];
    }
}

- (void)setup{
    
    UIColor *textColor = [UIColor colorWithRed:0.122 green:0.514 blue:0.984 alpha:1.000];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    mapView.showsUserLocation = YES;
    mapView.delegate = self;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = [self TKBoldFontOfSize:20.0f];
    nameLabel.textColor = textColor;
    nameLabel.numberOfLines = 0;
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addressLabel.font = [self TKBoldFontOfSize:18.0f];
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = textColor;
    
    UILabel *localisationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    localisationLabel.numberOfLines = 0;
    localisationLabel.textColor = textColor;
    
    UILabel *hoursLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hoursLabel.textColor = textColor;
    hoursLabel.numberOfLines = 0;
    
    UILabel *paymentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    paymentLabel.numberOfLines = 0;
    paymentLabel.textColor = textColor;
    
    
    [self addSubview:nameLabel];
    [self addSubview:addressLabel];
    [self addSubview:mapView];
    [self addSubview:localisationLabel];
    [self addSubview:hoursLabel];
    [self addSubview:paymentLabel];
    
    self.nameLabel = nameLabel;
    self.addressLabel = addressLabel;
    self.mapView = mapView;
    self.localisationLabel = localisationLabel;
    self.hoursLabel = hoursLabel;
    self.paymentLabel = paymentLabel;
}

- (void)reloadData{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.parcel];
    
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = self.parcel.coordinate.latitude;
    mapRegion.center.longitude = self.parcel.coordinate.longitude;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [self.mapView setRegion:mapRegion animated: YES];
    self.mapView.centerCoordinate = self.parcel.coordinate;

    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Paczkomat",nil), self.parcel.name];
    self.addressLabel.text = [NSString stringWithFormat:@"%@ %@\r%@ %@", self.parcel.street, self.parcel.buildingNumber, self.parcel.postalCode, self.parcel.town];
    self.localisationLabel.attributedText = [self attributesStringWithBoldString:NSLocalizedString(@"Localisation: ",nil)
                                                          normalString:self.parcel.locationDescription ?: NSLocalizedString(@"No info",nil)];
    self.hoursLabel.attributedText = [self attributesStringWithBoldString:NSLocalizedString(@"Hour opened: ",nil)
                                                             normalString:self.parcel.operatingHours ?: NSLocalizedString(@"No info",nil)];
    self.paymentLabel.attributedText = [self attributesStringWithBoldString:NSLocalizedString(@"Payment: ",nil)
                                                               normalString:self.parcel.paymentType ?: NSLocalizedString(@"No info",nil)];
}

#pragma mark - Helpers

- (NSAttributedString *)attributesStringWithBoldString:(NSString *)boldString normalString:(NSString *)normalString{
    
    NSDictionary *boldAttrs = @{UITextAttributeFont : [self TKBoldFontOfSize:18.0f]};
    NSDictionary *normalAttrs = @{UITextAttributeFont : [self TKMediumFontOfSize:15.0f]};
    
    NSAttributedString *bold = [[NSAttributedString alloc] initWithString:boldString attributes:boldAttrs];
    NSAttributedString *normal = [[NSAttributedString alloc] initWithString:normalString attributes:normalAttrs];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString:bold];
    [string appendAttributedString:normal];
    return [[NSAttributedString alloc] initWithAttributedString:string];
}

- (UIFont *)TKBoldFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

- (UIFont *)TKMediumFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}


@end
