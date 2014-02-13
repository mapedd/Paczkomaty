//
//  TKParcelView.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelView.h"
#import "TKParcelLocker.h"
#import "UIImageView+AFNetworking.h"
#import "TKLockerHelper.h"

#define MAP_BANNER_INDEX 0
#define PHOTO_BANNER_INDEX 1

#define BANNER_HEIGHT 150.0f

@interface TKParcelView () <MKMapViewDelegate>

@property (readwrite, strong, nonatomic) MKMapView *mapView;
@property (readwrite, strong, nonatomic) UIImageView *imageView;
/**********************************************************************/
@property (readwrite, strong, nonatomic) UISegmentedControl *segmentedControl;
/**********************************************************************/
@property (readwrite, strong, nonatomic) UILabel *nameLabel;
@property (readwrite, strong, nonatomic) UILabel *addressLabel;
@property (readwrite, strong, nonatomic) UILabel *localisationLabel;
@property (readwrite, strong, nonatomic) UILabel *hoursLabel;
@property (readwrite, strong, nonatomic) UILabel *paymentLabel;

@property (assign, nonatomic) NSInteger shownBanner;

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
    CGRect imageViewFrame = CGRectZero;
    
    CGRect segmentedControlFrame = CGRectZero;
    
    CGRect nameLabelFrame = CGRectZero;
    CGRect addressLabelFrame = CGRectZero;
    
    CGRect localistaionLabelFrame = CGRectZero;
    CGRect hoursLabeFrame = CGRectZero;
    CGRect paymentLabelFrame = CGRectZero;
    
    CGFloat nameLabelHeight = [self.nameLabel tk_attributedTextHeightWithWidth:labelWidth];
    
    CGFloat addressLabelHeight = [self.addressLabel tk_attributedTextHeightWithWidth:labelWidth];
    
    CGFloat localisaitonLabelHeight = [self.localisationLabel tk_attributedTextHeightWithWidth:labelWidth];
    
    CGFloat hoursLabelHeight = [self.hoursLabel tk_attributedTextHeightWithWidth:labelWidth];
    
    CGFloat paymentLabelHeight = [self.paymentLabel tk_attributedTextHeightWithWidth:labelWidth];
    
    mapViewFrame = CGRectMake(0.0f, 0.0f, width, BANNER_HEIGHT);
    imageViewFrame = CGRectMake(0.0f, 0.0f, width, BANNER_HEIGHT);
    
    segmentedControlFrame = CGRectMake(inset, inset + CGRectGetMaxY(mapViewFrame), labelWidth, 40.0f);
    
    nameLabelFrame = CGRectMake(inset,inset + CGRectGetMaxY(segmentedControlFrame), labelWidth, nameLabelHeight);
    addressLabelFrame = CGRectMake(inset, inset + CGRectGetMaxY(nameLabelFrame), labelWidth, addressLabelHeight);
    
    localistaionLabelFrame = CGRectMake(inset, inset + CGRectGetMaxY(addressLabelFrame), labelWidth, localisaitonLabelHeight);
    hoursLabeFrame = CGRectMake(inset, inset + CGRectGetMaxY(localistaionLabelFrame), labelWidth, hoursLabelHeight);
    paymentLabelFrame = CGRectMake(inset, inset + CGRectGetMaxY(hoursLabeFrame), labelWidth, paymentLabelHeight);
    
    self.imageView.frame = imageViewFrame;
    self.nameLabel.frame = nameLabelFrame;
    self.segmentedControl.frame = segmentedControlFrame;
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
    
    if (self.shownBanner == PHOTO_BANNER_INDEX) {
        self.mapView.hidden = YES;
        self.imageView.hidden = NO;
    }else if (self.shownBanner == MAP_BANNER_INDEX){
        self.mapView.hidden = NO;
        self.imageView.hidden = YES;
    }
    
}

#pragma mark - Setters

- (void)setParcel:(TKParcelLocker *)parcel{
    if (_parcel != parcel) {
        _parcel = parcel;
        [self reloadData];
    }
}

- (void)setShownBanner:(NSInteger)shownBanner{
    if (_shownBanner != shownBanner) {
        _shownBanner = shownBanner;
        [self setNeedsLayout];
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
    
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    mapView.showsUserLocation = YES;
    mapView.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSArray *items = @[TKLocalizedStringWithToken(@"picker-title.map"),
                       TKLocalizedStringWithToken(@"picker-title.photo")];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    [segmentedControl setSelectedSegmentIndex:MAP_BANNER_INDEX];
    [segmentedControl addTarget:self action:@selector(setVisibleBanner:) forControlEvents:(UIControlEventValueChanged)];
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = [self TKBoldFontOfSize:20.0f];
    nameLabel.numberOfLines = 0;
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addressLabel.font = [self TKBoldFontOfSize:18.0f];
    addressLabel.numberOfLines = 0;
    
    UILabel *localisationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    localisationLabel.numberOfLines = 0;
    
    UILabel *hoursLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hoursLabel.numberOfLines = 0;
    
    UILabel *paymentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    paymentLabel.numberOfLines = 0;
    
    
    
    [self addSubview:nameLabel];
    [self addSubview:addressLabel];
    [self addSubview:imageView];
    imageView.hidden = YES;
    [self addSubview:mapView];
    [self addSubview:segmentedControl];
    [self addSubview:localisationLabel];
    [self addSubview:hoursLabel];
    [self addSubview:paymentLabel];
    
    self.segmentedControl = segmentedControl;
    self.imageView = imageView;
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
    
    NSString *imageAddress = [NSString stringWithFormat:@"http://paczkomaty.pl/images/paczkomaty/big/%@.jpg", self.parcel.name];
    NSURL *url = [NSURL URLWithString:imageAddress];
    [self.imageView setImageWithURL:url];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = self.parcel.coordinate.latitude;
    mapRegion.center.longitude = self.parcel.coordinate.longitude;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [self.mapView setRegion:mapRegion animated: YES];
    self.mapView.centerCoordinate = self.parcel.coordinate;
    
    self.nameLabel.attributedText = [self attributesStringWithBoldString:TKLocalizedStringWithToken(@"label.locker") normalString:self.parcel.name];
    
    NSString *boldString = TKLocalizedStringWithToken(@"label.address");
    
    NSString *normalString = [NSString stringWithFormat:@"%@ %@\r%@ %@", self.parcel.street, self.parcel.buildingNumber, self.parcel.postalCode, self.parcel.town];
    
    self.addressLabel.attributedText = [self attributesStringWithBoldString:boldString normalString:normalString];
    
    self.localisationLabel.attributedText = [self attributesStringWithBoldString:TKLocalizedStringWithToken(@"label.localisation")
                                                                    normalString:self.parcel.locationDescription ?: TKLocalizedStringWithToken(@"label.no-info")];
    
    self.hoursLabel.attributedText = [self attributesStringWithBoldString:TKLocalizedStringWithToken(@"label.opening-hours")
                                                             normalString:self.parcel.operatingHours ?: TKLocalizedStringWithToken(@"label.no-info")];
    
    self.paymentLabel.attributedText = [self attributesStringWithBoldString:TKLocalizedStringWithToken(@"label.payment")
                                                               normalString:self.parcel.paymentType ?: TKLocalizedStringWithToken(@"label.no-info")];
}


#pragma mark - Actions

- (void)setVisibleBanner:(UISegmentedControl *)segmentedControl{
    [self setShownBanner:segmentedControl.selectedSegmentIndex];
}

#pragma mark - Helpers

- (NSAttributedString *)attributesStringWithBoldString:(NSString *)boldString normalString:(NSString *)normalString{
    
    NSDictionary *boldAttrs = (@{
                                 NSFontAttributeName : [self TKBoldFontOfSize:18.0f],
                                 NSForegroundColorAttributeName : [UIColor grayColor]
                                 });
    
    NSDictionary *normalAttrs = (@{
                                   NSFontAttributeName : [self TKMediumFontOfSize:15.0f],
                                   NSForegroundColorAttributeName : [UIColor colorWithRed:0.122 green:0.514 blue:0.984 alpha:1.000]
                                   });
    
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


@implementation UILabel (Paczkomaty_Additions)

- (CGFloat)tk_attributedTextHeightWithWidth:(CGFloat)width{
    return fmaxf(ceilf([self.attributedText boundingRectWithSize:CGSizeMake(width, 9999)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                         context:0].size.height), 50.0f);
}

@end
