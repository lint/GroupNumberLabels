
@interface CNContact
@property(strong, nonatomic) NSArray *phoneNumbers;
-(BOOL) isUnknown;
@end

@interface CNLabeledValuePair
@property(strong, nonatomic) id value;
@end

@interface CNLabeledValue
@property(strong, nonatomic) CNLabeledValuePair *labelValuePair;
@end

@interface CNPhoneNumber
@property(strong, nonatomic) NSString *formattedStringValue;
@end

@interface CKLabel : UILabel
@end

@interface CKDetailsContactsTableViewCell : UITableViewCell
@property(strong, nonatomic) CNContact *contact;
@property(strong, nonatomic) CKLabel *nameLabel;
@property(strong, nonatomic) id delegate;
@end

@interface CKDetailsContactsStandardTableViewCell : CKDetailsContactsTableViewCell
//custom elements
@property(strong, nonatomic) UILabel *numberLabel;
@end

@interface CKConversation
-(BOOL) isGroupConversation;
@end

@interface CKDetailsController
@property(strong, nonatomic) CKConversation *conversation;
@end


%hook CKDetailsContactsStandardTableViewCell
%property(strong, nonatomic) UILabel *numberLabel;

-(void) layoutSubviews{
	%orig;
	
	if ([[[self delegate] conversation] isGroupConversation]){
	
		CNContact *contact = [self contact];
		
		if (![contact isUnknown]){
			
			NSArray *phoneNumbers = [contact phoneNumbers];
			
			if ([phoneNumbers count] > 0){
				id phoneNumber = [[phoneNumbers[0] labelValuePair] value];
				
				if ([phoneNumber isKindOfClass:[%c(CNPhoneNumber) class]]){
					
					UILabel *numberLabel = [self numberLabel];
					CKLabel *nameLabel = [self nameLabel];

					if (!numberLabel){
						numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
						[self setNumberLabel:numberLabel];
						[self addSubview:numberLabel];
					}
					
					numberLabel.text = [phoneNumber formattedStringValue];
					numberLabel.textColor = [UIColor grayColor];
					numberLabel.font = [UIFont systemFontOfSize:nameLabel.font.pointSize - 2];
					
					CGRect nameFrame = nameLabel.frame;
					CGSize textSize = [[numberLabel text] sizeWithAttributes:@{NSFontAttributeName:numberLabel.font}];
					CGFloat numberLabelYOrigin = (nameFrame.size.height + nameLabel.font.pointSize) / 2 + 5;

					numberLabel.frame = CGRectMake(nameFrame.origin.x, numberLabelYOrigin, ceil(textSize.width), textSize.height);
				}
			}
		}
	}
}

%end
