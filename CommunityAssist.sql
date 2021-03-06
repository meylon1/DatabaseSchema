USE [master]
GO
if Exists
	(Select name from sys.Databases where name='CommunityAssist')
begin
Drop database CommunityAssist
end
go
/****** Object:  Database [CommunityAssist]    Script Date: 1/8/2014 11:47:01 AM ******/
CREATE DATABASE [CommunityAssist]
 CONTAINMENT = NONE
 GO

USE [CommunityAssist]
GO
/****** Object:  User [RegisteredDonorsUser]    Script Date: 1/8/2014 11:47:02 AM ******/
CREATE USER [RegisteredDonorsUser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [IPadLogin]    Script Date: 1/8/2014 11:47:02 AM ******/
CREATE USER [IPadLogin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [DonorsLogin]    Script Date: 1/8/2014 11:47:02 AM ******/
CREATE USER [DonorsLogin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [IPadLogin]
GO
/****** Object:  XmlSchemaCollection [dbo].[ReviewNotesSchema]    Script Date: 1/8/2014 11:47:02 AM ******/
CREATE XML SCHEMA COLLECTION [dbo].[ReviewNotesSchema] AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.communityassist.org/reviewnotes" targetNamespace="http://www.communityassist.org/reviewnotes" elementFormDefault="qualified"><xsd:element name="reviewnote"><xsd:complexType><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence><xsd:element name="comment" type="xsd:anyType" /><xsd:element name="concerns"><xsd:complexType><xsd:complexContent><xsd:restriction base="xsd:anyType"><xsd:sequence><xsd:element name="concern" type="xsd:anyType" maxOccurs="unbounded" /></xsd:sequence></xsd:restriction></xsd:complexContent></xsd:complexType></xsd:element><xsd:element name="recommendation" type="xsd:string" /></xsd:sequence></xsd:restriction></xsd:complexContent></xsd:complexType></xsd:element></xsd:schema>'
GO
/****** Object:  StoredProcedure [dbo].[usp_newDonation]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_newDonation]
@lastName nvarchar(255),
@firstName nvarchar(255),
@userName nvarchar(25),
@plainPassword nvarchar(50),
@Street nvarchar(255), 
@Apartment nvarchar(255)=null, 
@State nvarchar(2) = 'WA', 
@City nvarchar(255)='Seattle', 
@Zip nvarchar(10), 
@email nvarchar(255),
@Phone nvarchar(255),
@DonationAmt money
As
Declare @EmailType int
Declare @PhoneType int
Declare @PersonKey int
Declare @EmployeeKey int
set @EmailType=6
set @phoneType=1
set @EmployeeKey=1
Begin tran
Begin try
if not exists
	(select Lastname, firstName, ContactInfo
	 From Person p
	 inner join personContact pc
	 on p.PersonKey=pc.PersonKey
	 where p.LastName=@LastName
	 and firstName=@firstName
	 and contactInfo=@email
	 and ContactTypeKey=@EmailType)
begin
Declare @Password varbinary(500);
Set @password = HASHBYTES('sha1',@PlainPassword)


Insert into person(Lastname, Firstname, userName, userPassword, plainPassword)
values (@lastName, @firstName, @userName, @password, @plainPassword)

Set @personKey = IDENT_CURRENT('Person')

insert into PersonAddress(Street, Apartment, State, City, Zip, PersonKey)
Values(@street, @apartment, @state, @city, @zip, @personkey)

insert into PersonContact(ContactInfo, PersonKey, ContactTypeKey)
Values (@Email, @personKey, @EmailType)

insert into PersonContact(ContactInfo, PersonKey, ContactTypeKey)
Values (@phone, @PersonKey, @PhoneType)
end
else
Begin
Select @personKey=p.personkey
 From Person p
	 inner join personContact pc
	 on p.PersonKey=pc.PersonKey
	 where p.LastName=@LastName
	 and firstName=@firstName
	 and contactInfo=@email
	 and ContactTypeKey=@EmailType
End

Insert into Donation(DonationDate, DonationAmount, PersonKey, EmployeeKey)
values(GetDate(), @DonationAmt, @PersonKey, @EmployeeKey)

commit tran
End try
Begin Catch
rollback tran
print Error_message()
End catch
GO
/****** Object:  UserDefinedFunction [dbo].[fx_HashPassword]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create function [dbo].[fx_HashPassword]
( @password nvarchar(50))
returns varbinary(500)
As
Begin
Declare @hashedPassword varbinary(500)
set @hashedPassword=HASHBYTES('sha1',@password)
return @hashedPassword
End
GO
/****** Object:  Table [dbo].[BusinessRules]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessRules](
	[BusinessRuleKey] [int] IDENTITY(1,1) NOT NULL,
	[BusinessRule] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[BusinessRuleKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CommunityService]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommunityService](
	[ServiceKey] [int] IDENTITY(1,1) NOT NULL,
	[ServiceName] [nvarchar](255) NULL,
	[ServiceDescription] [nvarchar](255) NULL,
	[ServiceMaximum] [money] NULL,
	[ServiceLifetimeMaximum] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[ServiceKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ContactType]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactType](
	[ContactTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[ContactTypeName] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ContactTypeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Donation]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Donation](
	[DonationKey] [int] IDENTITY(1,1) NOT NULL,
	[DonationDate] [datetime] NOT NULL,
	[DonationAmount] [money] NOT NULL,
	[PersonKey] [int] NULL,
	[EmployeeKey] [int] NULL,
	[DonationConfirmDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[DonationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Employee]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmployeeKey] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeHireDate] [datetime] NULL,
	[EmployeeSSNumber] [nvarchar](9) NULL,
	[EmployeeDependents] [int] NULL,
	[PersonKey] [int] NULL,
	[EmployeeStatus] [nchar](2) NULL,
	[EmployeeMonthlySalary] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EmployeeJobTitle]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeJobTitle](
	[EmployeeJobTitleKey] [int] IDENTITY(1,1) NOT NULL,
	[JobTitleKey] [int] NULL,
	[JobTitleAssignedDate] [date] NULL,
	[JobTitleEndDate] [date] NULL,
	[EmployeeKey] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeJobTitleKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GrantReview]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GrantReview](
	[GrantReviewNotesKey] [int] IDENTITY(1,1) NOT NULL,
	[GrantReviewDate] [date] NULL,
	[EmployeeKey] [int] NULL,
	[GrantKey] [int] NULL,
	[GrantReviewNote] [xml](CONTENT [dbo].[ReviewNotesSchema]) NULL,
PRIMARY KEY CLUSTERED 
(
	[GrantReviewNotesKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Jobtitle]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jobtitle](
	[JobTitleKey] [int] IDENTITY(1,1) NOT NULL,
	[JobTitleName] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[JobTitleKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Person]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Person](
	[PersonKey] [int] IDENTITY(1,1) NOT NULL,
	[PersonLastName] [nvarchar](255) NOT NULL,
	[PersonFirstName] [nvarchar](255) NULL,
	[PersonUsername] [nvarchar](25) NULL,
	[PersonPlainPassword] [nvarchar](50) NULL,
	[Personpasskey] [int] NULL,
	[PersonEntryDate] [date] NULL,
	[PersonUserPassword] [varbinary](500) NULL,
 CONSTRAINT [PK__Person__45F58D861C95870A] PRIMARY KEY CLUSTERED 
(
	[PersonKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersonAddress]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonAddress](
	[PersonAddressKey] [int] IDENTITY(1,1) NOT NULL,
	[Street] [nvarchar](255) NULL,
	[Apartment] [nvarchar](255) NULL,
	[State] [nvarchar](2) NULL,
	[City] [nvarchar](255) NULL,
	[Zip] [nvarchar](10) NULL,
	[PersonKey] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonAddressKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PersonContact]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonContact](
	[ContactKey] [int] IDENTITY(1,1) NOT NULL,
	[ContactInfo] [nvarchar](255) NULL,
	[PersonKey] [int] NULL,
	[ContactTypeKey] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ContactKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ServiceGrant]    Script Date: 1/8/2014 11:47:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceGrant](
	[GrantKey] [int] IDENTITY(1,1) NOT NULL,
	[GrantAmount] [money] NULL,
	[GrantDate] [datetime] NULL,
	[PersonKey] [int] NULL,
	[ServiceKey] [int] NULL,
	[EmployeeKey] [int] NULL,
	[GrantReviewDate] [date] NULL,
	[GrantApprovalStatus] [nvarchar](10) NULL,
	[GrantNeedExplanation] [nvarchar](max) NULL,
	[GrantAllocation] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[GrantKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[BusinessRules] ON 

GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (1, N'All Requests must be reviewed by an employee within 48 hours of entry')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (2, N'No individual grant can be greated than the Service Maximum')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (3, N'No individual can recieve more than the lifetime maximum in total grants for a particular service')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (4, N'Grants are meant for one time assistance only and are not to be given on a recurring schedule')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (5, N'Employees should seek to help clients find more long term solutions to problems')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (6, N'Grants should not be awarded if other funding sources are available')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (7, N'All grants should be approved or disapproved within 7 days of entry')
GO
INSERT [dbo].[BusinessRules] ([BusinessRuleKey], [BusinessRule]) VALUES (8, N'All Donations should be verified, especially large donations')
GO
SET IDENTITY_INSERT [dbo].[BusinessRules] OFF
GO
SET IDENTITY_INSERT [dbo].[CommunityService] ON 

GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (1, N'Food', N'assistance for purchasing groceries', 200.0000, 1000.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (2, N'Rent', N'assistance for monthly Rent payments', 900.0000, 2700.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (3, N'Child care', N'assistance for childcare expenses', 300.0000, 1000.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (4, N'Transportation', N'assistance for transportation to and from work', 250.0000, 500.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (5, N'Medical', N'assistance with medical bills', 1200.0000, 5000.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (6, N'Dental', N'assistance with dental bills', 950.0000, 5000.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (7, N'Utilities', N'help with monthly utilites', 250.0000, 1000.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (8, N'home repair', N'one time assistance with home repair', 800.0000, 5000.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (9, N'Education', N'help with worker retraining', 700.0000, 2100.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (10, N'Clothes', N'help especially with cothes for job search or work clothes', 200.0000, 800.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (11, N'Funerary', N'assistence for funeral costs', 1500.0000, 1500.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (12, N'holiday', N'holiday assistance (food, gifts, etc)', 300.0000, 750.0000)
GO
INSERT [dbo].[CommunityService] ([ServiceKey], [ServiceName], [ServiceDescription], [ServiceMaximum], [ServiceLifetimeMaximum]) VALUES (13, N'Emergancy Travel', N'assistance for emergancy travel needs', 1000.0000, 1000.0000)
GO
SET IDENTITY_INSERT [dbo].[CommunityService] OFF
GO
SET IDENTITY_INSERT [dbo].[ContactType] ON 

GO
INSERT [dbo].[ContactType] ([ContactTypeKey], [ContactTypeName]) VALUES (1, N'Home Phone')
GO
INSERT [dbo].[ContactType] ([ContactTypeKey], [ContactTypeName]) VALUES (2, N'Work Phone')
GO
INSERT [dbo].[ContactType] ([ContactTypeKey], [ContactTypeName]) VALUES (3, N'Cell Phone')
GO
INSERT [dbo].[ContactType] ([ContactTypeKey], [ContactTypeName]) VALUES (4, N'pager')
GO
INSERT [dbo].[ContactType] ([ContactTypeKey], [ContactTypeName]) VALUES (5, N'fax')
GO
SET IDENTITY_INSERT [dbo].[ContactType] OFF
GO
SET IDENTITY_INSERT [dbo].[Donation] ON 

GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (1, CAST(0x0000A21500A58BF2 AS DateTime), 157.5000, 51, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (2, CAST(0x0000A21500A58BF2 AS DateTime), 157.5000, 53, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (3, CAST(0x0000A21500A58BF2 AS DateTime), 500.0000, 3, 2, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (4, CAST(0x0000A21500A58BF2 AS DateTime), 250.0000, 6, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (5, CAST(0x0000A21500A58BF2 AS DateTime), 50.0000, 8, 6, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (6, CAST(0x0000A21500A58BF2 AS DateTime), 1500.0000, 11, 4, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (7, CAST(0x0000A21500A58BF2 AS DateTime), 25.0000, 13, 2, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (8, CAST(0x0000A21500A58BF2 AS DateTime), 100.0000, 15, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (9, CAST(0x0000A21500A58BF2 AS DateTime), 500.0000, 19, 6, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (10, CAST(0x0000A21500A58BF2 AS DateTime), 1200.0000, 26, 5, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (11, CAST(0x0000A21500A58BF2 AS DateTime), 2500.0000, 28, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (12, CAST(0x0000A21500A58BF2 AS DateTime), 500.0000, 3, 2, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (13, CAST(0x0000A21500A58BF2 AS DateTime), 100.0000, 29, 3, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (14, CAST(0x0000A21500A58BF2 AS DateTime), 5000.0000, 31, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (15, CAST(0x0000A21500A58BF2 AS DateTime), 50.0000, 33, 2, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (16, CAST(0x0000A21500A58BF2 AS DateTime), 100.0000, 35, 4, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (17, CAST(0x0000A21500A58BF2 AS DateTime), 500.0000, 38, 5, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (18, CAST(0x0000A21500A58BF2 AS DateTime), 2500.0000, 40, 5, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (19, CAST(0x0000A21500A58BF2 AS DateTime), 1500.0000, 41, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (20, CAST(0x0000A21500A58BF2 AS DateTime), 50.0000, 42, 2, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (21, CAST(0x0000A21500A58BF2 AS DateTime), 250.0000, 48, 6, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (22, CAST(0x0000A21500A58BF2 AS DateTime), 150.0000, 50, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (23, CAST(0x0000A21500A58BF2 AS DateTime), 500.0000, 3, 2, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (24, CAST(0x0000A21500A58BF2 AS DateTime), 320.5000, 54, 1, CAST(0x73370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (25, CAST(0x0000A2160102F35E AS DateTime), 345.9000, 1, 1, CAST(0x74370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (26, CAST(0x0000A2160109429D AS DateTime), 375.0000, 6, 1, CAST(0x74370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (27, CAST(0x0000A216010A725E AS DateTime), 290.5600, 11, 1, CAST(0x74370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (28, CAST(0x0000A217014775FC AS DateTime), 578.5500, 56, 1, CAST(0x75370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (29, CAST(0x0000A2170149C10F AS DateTime), 245.3800, 57, 1, CAST(0x75370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (30, CAST(0x0000A2170154408D AS DateTime), 982.4500, 58, 1, CAST(0x75370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (31, CAST(0x0000A21D00C310DF AS DateTime), 535.5000, 67, 1, CAST(0x7B370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (32, CAST(0x0000A21D00C4C317 AS DateTime), 500.0000, 69, 1, CAST(0x7B370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (33, CAST(0x0000A21E00AD9D70 AS DateTime), 235.5500, 71, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (34, CAST(0x0000A21E00B4ED73 AS DateTime), 2000.0000, 75, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (35, CAST(0x0000A21E00B56850 AS DateTime), 6000.0000, 76, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (36, CAST(0x0000A21E00B7871C AS DateTime), 2000.0000, 77, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (37, CAST(0x0000A21E00B83F00 AS DateTime), 980.5500, 11, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (38, CAST(0x0000A21E00B8A66A AS DateTime), 678.9300, 29, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (39, CAST(0x0000A21E00B93C47 AS DateTime), 12150.5500, 78, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (40, CAST(0x0000A21E00BA4026 AS DateTime), 450.7500, 79, 1, CAST(0x7C370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (41, CAST(0x0000A22400D62579 AS DateTime), 2450.0000, 96, 1, CAST(0x82370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (42, CAST(0x0000A22E00B18E4A AS DateTime), 1200.0000, 114, 1, CAST(0x91370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (43, CAST(0x0000A23000EAF0EB AS DateTime), 800.0000, 115, 1, CAST(0x91370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (44, CAST(0x0000A23000EF91F8 AS DateTime), 2500.0000, 121, 1, CAST(0x91370B00 AS Date))
GO
INSERT [dbo].[Donation] ([DonationKey], [DonationDate], [DonationAmount], [PersonKey], [EmployeeKey], [DonationConfirmDate]) VALUES (45, CAST(0x0000A23600D12FCD AS DateTime), 200.0000, 122, 1, CAST(0x91370B00 AS Date))
GO
SET IDENTITY_INSERT [dbo].[Donation] OFF
GO
SET IDENTITY_INSERT [dbo].[Employee] ON 

GO
INSERT [dbo].[Employee] ([EmployeeKey], [EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus], [EmployeeMonthlySalary]) VALUES (1, CAST(0x0000904D00000000 AS DateTime), N'555551234', 2, 5, N'FT', 6250.0000)
GO
INSERT [dbo].[Employee] ([EmployeeKey], [EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus], [EmployeeMonthlySalary]) VALUES (2, CAST(0x0000920300000000 AS DateTime), N'555553456', NULL, 12, N'FT', 5845.9500)
GO
INSERT [dbo].[Employee] ([EmployeeKey], [EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus], [EmployeeMonthlySalary]) VALUES (3, CAST(0x0000933800000000 AS DateTime), N'555554567', NULL, 18, N'PT', 0.0000)
GO
INSERT [dbo].[Employee] ([EmployeeKey], [EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus], [EmployeeMonthlySalary]) VALUES (4, CAST(0x0000933800000000 AS DateTime), N'555555678', 1, 23, N'PT', 0.0000)
GO
INSERT [dbo].[Employee] ([EmployeeKey], [EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus], [EmployeeMonthlySalary]) VALUES (5, CAST(0x00009A2400000000 AS DateTime), N'555557890', 3, 47, N'FT', 6125.4400)
GO
INSERT [dbo].[Employee] ([EmployeeKey], [EmployeeHireDate], [EmployeeSSNumber], [EmployeeDependents], [PersonKey], [EmployeeStatus], [EmployeeMonthlySalary]) VALUES (6, CAST(0x00009BF200000000 AS DateTime), N'555550123', NULL, 7, N'PT', 1800.4500)
GO
SET IDENTITY_INSERT [dbo].[Employee] OFF
GO
SET IDENTITY_INSERT [dbo].[EmployeeJobTitle] ON 

GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (5, 1, CAST(0x70370B00 AS Date), NULL, 1)
GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (6, 2, CAST(0x70370B00 AS Date), NULL, 1)
GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (7, 3, CAST(0x70370B00 AS Date), NULL, 2)
GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (8, 4, CAST(0x70370B00 AS Date), NULL, 5)
GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (9, 5, CAST(0x70370B00 AS Date), NULL, 3)
GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (10, 5, CAST(0x70370B00 AS Date), NULL, 4)
GO
INSERT [dbo].[EmployeeJobTitle] ([EmployeeJobTitleKey], [JobTitleKey], [JobTitleAssignedDate], [JobTitleEndDate], [EmployeeKey]) VALUES (11, 5, CAST(0x70370B00 AS Date), NULL, 6)
GO
SET IDENTITY_INSERT [dbo].[EmployeeJobTitle] OFF
GO
SET IDENTITY_INSERT [dbo].[GrantReview] ON 

GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (5, CAST(0x71370B00 AS Date), 5, 1, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is an easy one</comment><concerns><concern>None</concern></concerns><recommendation>Approve Loan</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (6, CAST(0x71370B00 AS Date), 5, 2, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I am for granting this for this month only, but they need other sources</comment><concerns><concern>I fear this may be a continuing problem</concern><concern>Need to find other funding or new apartment</concern></concerns><recommendation>approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (7, CAST(0x71370B00 AS Date), 5, 5, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This should be ok for a one time loan</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (8, CAST(0x71370B00 AS Date), 5, 3, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This amount seems excessive</comment><concerns><concern>Too much money for utilities</concern><concern>other more pressing concerns</concern></concerns><recommendation>Not approved</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (9, CAST(0x71370B00 AS Date), 5, 4, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is an ongoing problem. We need to find a longer term solution</comment><concerns><concern>not a one time need</concern></concerns><recommendation>Approve this once but find other solutions for long term</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (10, CAST(0x71370B00 AS Date), 5, 6, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>approve once</comment><concerns><concern>none</concern></concerns><recommendation>approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (11, CAST(0x71370B00 AS Date), 5, 7, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I went and reviewed the damage. it is more like a 1000 dollars. they are paying the other 500</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (12, CAST(0x71370B00 AS Date), 5, 8, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>One time and reasonable</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (13, CAST(0x71370B00 AS Date), 5, 9, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Lots of these cases. Again the problem is one time doesn''t provide a solution</comment><concerns><concern>recurring problem</concern></concerns><recommendation>Approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (14, CAST(0x71370B00 AS Date), 5, 10, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is very specific and expensive and I think we can arrange other solutions by working with the insurance and the doctor</comment><concerns><concern>Other solutions available</concern></concerns><recommendation>Don''t approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (15, CAST(0x71370B00 AS Date), 5, 11, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>A little problematic because of the size of the request</comment><concerns><concern>Large amount</concern></concerns><recommendation>Approve once and see if we can suggest longer term solutions</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (16, CAST(0x72370B00 AS Date), 5, 12, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Request vague. I called and checked with them. This could be an ongoing problem</comment><concerns><concern>On going problem</concern></concerns><recommendation>Approve once but find other resources for the family</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (17, CAST(0x72370B00 AS Date), 5, 13, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Like other cases this seems a continuing problem</comment><concerns><concern>Continuing problem</concern></concerns><recommendation>Approve once, find other solutions</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (18, CAST(0x72370B00 AS Date), 5, 14, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Worked out a payment plan with the dentist</comment><concerns><concern>Had not contacted the dentist about bill</concern></concerns><recommendation>deny</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (19, CAST(0x72370B00 AS Date), 5, 15, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Reasonable request, though it could be an annual issue</comment><concerns><concern>None</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (20, CAST(0x72370B00 AS Date), 5, 16, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is a problem. I think we need to help them with the landlord or find a new place to live</comment><concerns><concern>The grant doesn''t solve the problem</concern></concerns><recommendation>Approve once then find them a new apartment or make a deal with the landlord</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (21, CAST(0x72370B00 AS Date), 5, 17, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>need to investigate financial aid and loan possibilities more thoroughly</comment><concerns><concern>Haven''t explored all the avenues</concern></concerns><recommendation>deny for now</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (22, CAST(0x72370B00 AS Date), 5, 18, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to look at their budget and find room for food</comment><concerns><concern>need better budgeting</concern></concerns><recommendation>approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (23, CAST(0x72370B00 AS Date), 5, 19, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This does seem to be a one off thing. Family had an emergency car repair</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (24, CAST(0x72370B00 AS Date), 5, 19, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment /><concerns><concern>none</concern></concerns><recommendation></recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (25, CAST(0x72370B00 AS Date), 5, 20, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is going to be an on-going problem. We need to help them find a cheaper place.</comment><concerns><concern>on going problem</concern></concerns><recommendation>Approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (26, CAST(0x72370B00 AS Date), 5, 21, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment /><concerns><concern>none</concern></concerns><recommendation>approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (27, CAST(0x72370B00 AS Date), 5, 22, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>same issues of ongoing expenses</comment><concerns><concern>on going</concern></concerns><recommendation>approve, provide budget help</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (28, CAST(0x72370B00 AS Date), 5, 23, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is a good request. One time should suffice</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (29, CAST(0x72370B00 AS Date), 5, 24, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to check out other options</comment><concerns><concern>Need to check financial aid possibilities</concern></concerns><recommendation>deny for now</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (30, CAST(0x72370B00 AS Date), 5, 25, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to provide budgetary counseling</comment><concerns><concern>budget issues</concern></concerns><recommendation>Approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (31, CAST(0x72370B00 AS Date), 5, 26, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need budget advice</comment><concerns><concern>none</concern></concerns><recommendation>Approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (32, CAST(0x72370B00 AS Date), 5, 27, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This request looks good. The client is shouldering most of the expense themselves</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (33, CAST(0x72370B00 AS Date), 5, 28, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Reasonable one time request</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (34, CAST(0x72370B00 AS Date), 5, 29, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Too much exceeds our maximum grant. </comment><concerns><concern>Too high of request</concern><concern>Continuing problem</concern></concerns><recommendation>Deny and find the client a cheaper place to live</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (35, CAST(0x72370B00 AS Date), 5, 30, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to find other funding sources. Request is larger than max allotted </comment><concerns><concern>Request larger than maximum</concern><concern>continuing issue</concern><concern>Needs to explore other funding</concern></concerns><recommendation>deny </recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (36, CAST(0x72370B00 AS Date), 5, 31, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>We talked to doctor and arranged payment schedule</comment><concerns><concern>none</concern></concerns><recommendation>Deny</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (37, CAST(0x72370B00 AS Date), 5, 33, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>reasonable, but need to provide some budget consultation</comment><concerns><concern>Budget issues</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (38, CAST(0x72370B00 AS Date), 5, 33, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>No issues</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (39, CAST(0x72370B00 AS Date), 5, 34, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Better to arrange a payment plan with the dentist</comment><concerns><concern>Need to consult with the dentist</concern></concerns><recommendation>Deny</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (40, CAST(0x77370B00 AS Date), 5, 35, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This seems clear cut and simple</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (41, CAST(0x77370B00 AS Date), 5, 36, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This also seems easy enough. The leak has been repaired</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (42, CAST(0x77370B00 AS Date), 5, 37, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>No big problems</comment><concerns><concern>Need to find a longer term solution</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (43, CAST(0x77370B00 AS Date), 5, 39, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>No issues here</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (44, CAST(0x77370B00 AS Date), 5, 40, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I would suggest that we work with the hospital for a payment plan</comment><concerns><concern>Should work with Hospital for terms</concern></concerns><recommendation>Maybe give a lesser amount</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (45, CAST(0x77370B00 AS Date), 5, 41, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>No real problems</comment><concerns><concern>none</concern></concerns><recommendation>Approved</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (46, CAST(0x77370B00 AS Date), 5, 42, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment /><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (47, CAST(0x78370B00 AS Date), 5, 40, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Talked to client and worked with emergency room to get payment plan and reduced amt due</comment><concerns><concern>none</concern></concerns><recommendation>Approve for 200</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (48, CAST(0x79370B00 AS Date), 5, 43, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to make sure this is not a continuing issue, maybe find other sources of funding</comment><concerns><concern>could be continuting issue</concern></concerns><recommendation>approve this time</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (49, CAST(0x79370B00 AS Date), 5, 44, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is an easy one</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (50, CAST(0x7A370B00 AS Date), 5, 46, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>We should help the client research alternate ways to get books</comment><concerns><concern>Find alternate ways to get books</concern><concern /></concerns><recommendation>Approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (51, CAST(0x7A370B00 AS Date), 5, 47, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Should grant this one. Seems legitimate</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (52, CAST(0x7A370B00 AS Date), 5, 48, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This one should be reviewed more to see if is a real need situation</comment><concerns><concern>Review more</concern><concern>May have other possibilities</concern></concerns><recommendation>revisit after speaking to client</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (53, CAST(0x7A370B00 AS Date), 5, 49, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Similar to some others. We need to work with the client to find alternate ways to get textbooks</comment><concerns><concern>Need to find alternates</concern></concerns><recommendation>Approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (54, CAST(0x7A370B00 AS Date), 5, 50, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This seems a little odd. Maybe we can find him clothes for the wedding</comment><concerns><concern>Should be other means</concern></concerns><recommendation>deny for now</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (55, CAST(0x7A370B00 AS Date), 5, 51, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This seems fair</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (56, CAST(0x7A370B00 AS Date), 5, 52, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>No problems though we can''t support her for more than a month</comment><concerns><concern>Limit the support</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (57, CAST(0x7A370B00 AS Date), 5, 53, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Client has done due diligence. I say approve</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (58, CAST(0x7F370B00 AS Date), 5, 48, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>After further conversations I feel we should grant request</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (59, CAST(0x7F370B00 AS Date), 5, 54, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Reasonable</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (60, CAST(0x81370B00 AS Date), 5, 55, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I think this is legitimate</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (61, CAST(0x81370B00 AS Date), 5, 56, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I am unsure of this. Maybe grant just this once.</comment><concerns><concern>Seems too much</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (62, CAST(0x81370B00 AS Date), 5, 57, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to work with the electric company</comment><concerns><concern>Haven''t worked with the Electric Company</concern></concerns><recommendation>Approve for less</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (63, CAST(0x81370B00 AS Date), 5, 58, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to work with the dentist. We arranged 5 payments of 100. We will pay the first 189.90</comment><concerns><concern>too much need to work out payments</concern><concern>Payments arranged</concern></concerns><recommendation>approve for less</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (64, CAST(0x81370B00 AS Date), 5, 59, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This seems good</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (65, CAST(0x81370B00 AS Date), 5, 60, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I inspected the roof this seems legit. The repair costs much more that the amount requested. It is meant to make up the difference between what the client can pay and the cost</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (66, CAST(0x81370B00 AS Date), 5, 61, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Legitimate but we can find better air fare</comment><concerns><concern>none</concern></concerns><recommendation>approve for less</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (67, CAST(0x81370B00 AS Date), 5, 62, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is accurate, but we found a contractor who will do it for less</comment><concerns><concern>Can find less expensive contractor</concern></concerns><recommendation>Approve for less</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (68, CAST(0x81370B00 AS Date), 5, 63, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Legit but can arrange payments with the Utility</comment><concerns><concern>none</concern></concerns><recommendation>approve for 100</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (69, CAST(0x81370B00 AS Date), 5, 64, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to work with employer</comment><concerns><concern>Employer should pay</concern></concerns><recommendation>deny</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (70, CAST(0x81370B00 AS Date), 5, 65, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to make arrangements with dentist. Did arrange</comment><concerns><concern>Shd try to schedule a payment plan</concern></concerns><recommendation>approve one payment</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (71, CAST(0x83370B00 AS Date), 5, 66, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is fair though they can get a discount through the school</comment><concerns><concern>Need to use discounted school pass</concern></concerns><recommendation>approve for less</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (72, CAST(0x83370B00 AS Date), 5, 67, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Suggest giving the money one time and then finding new sources of food money</comment><concerns><concern>needs to be one time only</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (73, CAST(0x83370B00 AS Date), 5, 68, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>need to find alternate way to pay for this</comment><concerns><concern>Too much </concern><concern>Need alternate way to get money</concern></concerns><recommendation>deny</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (74, CAST(0x83370B00 AS Date), 5, 69, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Reasonable request</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (75, CAST(0x85370B00 AS Date), 5, 70, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>There are cheaper ways to get the textbooks</comment><concerns><concern>other means to provide the books</concern></concerns><recommendation>approve but reduce</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (76, CAST(0x85370B00 AS Date), 5, 71, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is valid</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (77, CAST(0x85370B00 AS Date), 5, 72, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>I have checked this out and it seems legitimate and a worthy cause</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (78, CAST(0x85370B00 AS Date), 5, 73, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Need to make arrangements with the dentist</comment><concerns><concern>need to arrange payments</concern></concerns><recommendation>reduce</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (79, CAST(0x85370B00 AS Date), 5, 74, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>fare is 975 so he is paying 300. It is a lot be he is desperate</comment><concerns><concern>a lot</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (80, CAST(0x89370B00 AS Date), 5, 75, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>approve, though find way to save for oil purchases in the future</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (81, CAST(0x89370B00 AS Date), 5, 76, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>approve but find alternate ways to help</comment><concerns><concern>Need alternate ways to pay</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (82, CAST(0x89370B00 AS Date), 5, 77, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>fair enough</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (83, CAST(0x89370B00 AS Date), 5, 78, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Made arrangements with the dentist for payments</comment><concerns><concern>arranged payments</concern></concerns><recommendation>reduced</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (84, CAST(0x89370B00 AS Date), 5, 79, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>the porch is treacherous</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (85, CAST(0x89370B00 AS Date), 5, 80, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Landlord is intractable approve</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (86, CAST(0x8C370B00 AS Date), 5, 81, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>There are no buses that go close</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (87, CAST(0x8C370B00 AS Date), 5, 82, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Should make arrangements with the hospital, but they seem unwilling</comment><concerns><concern>just the beginning of financial concerns</concern><concern>Need to find other sources to fund</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (88, CAST(0x8C370B00 AS Date), 5, 83, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>They were broken by vandals.</comment><concerns><concern>none</concern></concerns><recommendation>Approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (89, CAST(0x8C370B00 AS Date), 5, 84, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>There are cheaper mowers</comment><concerns><concern>none</concern></concerns><recommendation>approve a reduced amount</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (90, CAST(0x8C370B00 AS Date), 5, 85, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Not a serious request</comment><concerns><concern>Not serious</concern></concerns><recommendation>deny</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (91, CAST(0x93370B00 AS Date), 5, 86, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Suggest allowing once</comment><concerns><concern>on going issue</concern></concerns><recommendation>approve once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (92, CAST(0x93370B00 AS Date), 5, 87, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>Reasonable request should only require this one months donation</comment><concerns><concern>none</concern></concerns><recommendation>approve</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (93, CAST(0x93370B00 AS Date), 5, 88, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This one is a bit of a problem. It may help but that''s not garanteed</comment><concerns><concern>not sure if it helps</concern><concern>a lot of money</concern></concerns><recommendation>allow once</recommendation></reviewnote>')
GO
INSERT [dbo].[GrantReview] ([GrantReviewNotesKey], [GrantReviewDate], [EmployeeKey], [GrantKey], [GrantReviewNote]) VALUES (94, CAST(0x93370B00 AS Date), 5, 89, N'<reviewnote xmlns="http://www.communityassist.org/reviewnotes"><comment>This is a lot for tuirion. Need to find other funding sources</comment><concerns><concern>Need other funding</concern><concern>A lot for a one time grant</concern></concerns><recommendation>approve once</recommendation></reviewnote>')
GO
SET IDENTITY_INSERT [dbo].[GrantReview] OFF
GO
SET IDENTITY_INSERT [dbo].[Jobtitle] ON 

GO
INSERT [dbo].[Jobtitle] ([JobTitleKey], [JobTitleName]) VALUES (1, N'Manager')
GO
INSERT [dbo].[Jobtitle] ([JobTitleKey], [JobTitleName]) VALUES (2, N'Web Donation Supervisor')
GO
INSERT [dbo].[Jobtitle] ([JobTitleKey], [JobTitleName]) VALUES (3, N'Donation Manager')
GO
INSERT [dbo].[Jobtitle] ([JobTitleKey], [JobTitleName]) VALUES (4, N'Grant Reviewer')
GO
INSERT [dbo].[Jobtitle] ([JobTitleKey], [JobTitleName]) VALUES (5, N'Associate')
GO
SET IDENTITY_INSERT [dbo].[Jobtitle] OFF
GO
SET IDENTITY_INSERT [dbo].[Person] ON 

GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (1, N'Anderson', N'Jay', N'JAnderson@gmail.com', N'JPass', 5595738, CAST(0x70370B00 AS Date), 0xD274056DFA20B3A3B6F1C74C9A521D7495C2CE2280CBC682FDA7486B460C991884B7F23441C1B4BE4BC9272600CEF2739B749B9598D2EDA9E132CBF078DD8C28)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (2, N'Zimmerman', N'Toby', N'TZimmerman@gmail.com', N'TPass', 4123155, CAST(0x70370B00 AS Date), 0xE8F370F887FD17C18E5A9B202B6BDD662B951812F6076B59D6892FCF4C74A2D74E99482DFC97CB41F2AC717C51D506CD84320576BB00182C45158A2B34A3FC3A)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (3, N'Mann', N'Louis', N'LMann@gmail.com', N'LPass', 7352400, CAST(0x70370B00 AS Date), 0x79EBCD1E0726D0E8C6AC9E79D6DE963B6FA177F882BAF98410206D6DEBEDE7D12D82A7FEF0880A3FE46A954A57C5690D1D6EE2DE8606923C849134F8F3E9E2EB)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (4, N'Carmel', N'Bob', N'BCarmel@gmail.com', N'BPass', 7352400, CAST(0x70370B00 AS Date), 0x3F2E5540336103C4CB59199A073B7E7CCAE940CACA87FBA7BD9DBC27A180C53066782829905A28595A677DFDBCE0786CF453A77BA34B1A62C49F510CED270176)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (5, N'Lewis', N'Mary', N'MLewis@gmail.com', N'MPass', 7352400, CAST(0xA8250B00 AS Date), 0x8D23C8D14E77963BF21D147E4F30AB326F73B9653BC3C5C875DA2A2C441B0EC046E6D5F20D3F429EEDBF8D9425A7AEB63D48A773B3661319452ABC16A14D32B1)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (6, N'Tanner', N'Thomas', N'TTanner@gmail.com', N'TPass', 7352400, CAST(0x70370B00 AS Date), 0xA8AAFC52BC0E11F6174BCA6F9B55F89CF3F86A02AD4140C442E1576CDAED13A46F3B9A326308CCD93092BBDE6CF0466F92BAC3502BCCCF03B12BE4696ECB4F4D)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (7, N'Patterson', N'Jody', N'JPatterson@gmail.com', N'JPass', 7352400, CAST(0x4D310B00 AS Date), 0xEC7797842458E07343C386A6B730344F056308C6D123E0ABD76B85076757575FAB58893FA233019BE101EEDE01E3505AEB6CFC214567363931D55F54D38D3BE2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (8, N'Brown', N'Matt', N'MBrown@gmail.com', N'MPass', 7352400, CAST(0x70370B00 AS Date), 0x8D23C8D14E77963BF21D147E4F30AB326F73B9653BC3C5C875DA2A2C441B0EC046E6D5F20D3F429EEDBF8D9425A7AEB63D48A773B3661319452ABC16A14D32B1)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (9, N'Smith', N'Jerry', N'JSmith@gmail.com', N'JPass', 7352400, CAST(0x70370B00 AS Date), 0xEC7797842458E07343C386A6B730344F056308C6D123E0ABD76B85076757575FAB58893FA233019BE101EEDE01E3505AEB6CFC214567363931D55F54D38D3BE2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (10, N'Peters', N'Jay', N'JPeters@gmail.com', N'JPass', 7352400, CAST(0x70370B00 AS Date), 0xEC7797842458E07343C386A6B730344F056308C6D123E0ABD76B85076757575FAB58893FA233019BE101EEDE01E3505AEB6CFC214567363931D55F54D38D3BE2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (11, N'Masters', N'Fae', N'FMasters@gmail.com', N'FPass', 7352400, CAST(0x70370B00 AS Date), 0xB202ECF3091E4895EEA6E4DC503CDEB144BC17B23A410C4C495FF6A996D42C121999C0F072870244E813D6FDCBF5731B81641E04B89E5FADB79B43EAF2380EC0)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (12, N'Moon', N'Tina', N'TMoon@gmail.com', N'TPass', 1581646, CAST(0x5E270B00 AS Date), 0xF814E879AD394EC7F326E94D3E98ECBC0EC276961E27ADB8142F7E4938358D3510BF25D5FB459FBD159FE2EC9AD6497AD73849D8D3FE51EF99130B91295E4E09)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (13, N'Nguyen', N'Lu', N'LNguyen@gmail.com', N'LPass', 1581646, CAST(0x70370B00 AS Date), 0x8481D29B8BAA75209431AE5948A02F91A6286525BAF481503AE0A51C84ABF51DD31C542B6A2976B6C54286A487BFA54DD3C2BE585326B782C885D2782D0170E1)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (14, N'Chau', N'Mary', N'MChau@gmail.com', N'MPass', 1581646, CAST(0x70370B00 AS Date), 0xECB1C324927155F8828E01DB35F3214C624D13E077B3C0617EA9858269C7B6B54E2291DCDBFA0C11DB64AAC56218126E7AD12929570745B728768C66A8D5FDF2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (15, N'Kerry', N'Anne', N'AKerry@gmail.com', N'APass', 1581646, CAST(0x70370B00 AS Date), 0x9CD861A944ADDEB566EBD778DD77226821922FE4A4514F32FF97B219FAD568096B0DD808CE8E413D61E05E337352518751199EFB0AC0D35F492379F2293D491B)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (16, N'Robinson', N'Mike', N'MRobinson@gmail.com', N'MPass', 1581646, CAST(0x70370B00 AS Date), 0xECB1C324927155F8828E01DB35F3214C624D13E077B3C0617EA9858269C7B6B54E2291DCDBFA0C11DB64AAC56218126E7AD12929570745B728768C66A8D5FDF2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (17, N'Martin', N'Taylor', N'TMartin@gmail.com', N'TPass', 1581646, CAST(0x70370B00 AS Date), 0xF814E879AD394EC7F326E94D3E98ECBC0EC276961E27ADB8142F7E4938358D3510BF25D5FB459FBD159FE2EC9AD6497AD73849D8D3FE51EF99130B91295E4E09)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (18, N'McGraw', N'Alysson', N'AMcGraw@gmail.com', N'APass', 1581646, CAST(0x93280B00 AS Date), 0x9CD861A944ADDEB566EBD778DD77226821922FE4A4514F32FF97B219FAD568096B0DD808CE8E413D61E05E337352518751199EFB0AC0D35F492379F2293D491B)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (19, N'Morgan', N'Cheryl', N'CMorgan@gmail.com', N'CPass', 1581646, CAST(0x70370B00 AS Date), 0xB57FDFC3D0339F6CEC7D130B0D711D6885B4D93F106DDE48C97E787C09BA3695C363BFD76FFDF795CCD035C6C1CDDADDDDE54ABE8F74B49A751944869CAA15EF)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (20, N'Tan', N'Lee', N'LTan@gmail.com', N'LPass', 1581646, CAST(0x70370B00 AS Date), 0x8481D29B8BAA75209431AE5948A02F91A6286525BAF481503AE0A51C84ABF51DD31C542B6A2976B6C54286A487BFA54DD3C2BE585326B782C885D2782D0170E1)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (21, N'Jameson', N'Roberto', N'RJameson@gmail.com', N'RPass', 1581646, CAST(0x70370B00 AS Date), 0x02BE9AEE444D38F1D6E9AF669EBD98D4435162DC93D53F34068682BA9F61712178E990498425FB508F41BB436F86A23F0B3D1069B3473FD8369032B5C815D343)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (22, N'Banner', N'June', N'JBanner@gmail.com', N'JPass', 1581646, CAST(0x70370B00 AS Date), 0xA08B9C23639CE722400AAFB638565D4805EC387801613F18AA85D10E2AA64FC8196FBC2954C77B2E536E3ED336F4D347C259E45EC5A14DA879DDA71AF0C11232)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (23, N'Lee', N'Tracy', N'TLee@gmail.com', N'TPass', 9109062, CAST(0x93280B00 AS Date), 0x3E383F5ECCFDEB84C86AF662813B583CFB14F19D1AFFD43386AE77C2F6ADBB5F8D6FF757DD98813D8CA7EE9EF0E58D558FE7C47412945B59DEE35B7249E8107D)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (24, N'Fabre', N'Jill', N'JFabre@gmail.com', N'JPass', 3338308, CAST(0x70370B00 AS Date), 0x1552CDC38DB8DAA6DF7AFC5A26F9E27CCF1AD4E5FF07EAB83A66E5ECFE708823D02EBD206036973D623266B9F2B11FD400B497ADAB4C260F8B561427ED6E88AE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (25, N'Gardner', N'Tom', N'TGardner@gmail.com', N'TPass', 3338308, CAST(0x70370B00 AS Date), 0x585A550A3A5719822EEE3485029746EF9C238FBD80AD41D7DE9B2970745F089EFC3709C712236B851745A424036AD1FB4644082357FCBCF888AF7214D6AE6F05)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (26, N'Yesler', N'Bill', N'BYesler@gmail.com', N'BPass', 3338308, CAST(0x70370B00 AS Date), 0x2EB40B29B3ED79EEAC7A1BE911EDFB49F0F4889353C3AFF99C1F5CDD3CB082BDD4882A59B426C6E64DE6236FF404E1349659D992B731DD5ED0A457E5FFB210EE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (27, N'Caroll', N'Lisa', N'LCaroll@gmail.com', N'LPass', 3338308, CAST(0x70370B00 AS Date), 0xC54F74E15A48D69D1AA65F4EDE5153A70BC4F2A37FC81C40EF4D6699156101F10C5F1DAC51A9402A6D826FEFF485A1305E033FEBEF3C9DB1EE90EDC268232D5F)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (28, N'Lamont', N'Tess', N'TLamont@gmail.com', N'TPass', 3338308, CAST(0x70370B00 AS Date), 0x585A550A3A5719822EEE3485029746EF9C238FBD80AD41D7DE9B2970745F089EFC3709C712236B851745A424036AD1FB4644082357FCBCF888AF7214D6AE6F05)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (29, N'Johnston', N'Sara', N'SJohnston@gmail.com', N'SPass', 3338308, CAST(0x70370B00 AS Date), 0x5FBFCA7C40DAB4A462BFB79AB4973422F5B6EB0219181E7DCE54B0BFF32EF98EE84B214504F9D0EF99543537085DB8C6ED3794CBCF11EFE3D556D191DCEA15A8)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (30, N'Eliot', N'James', N'JEliot@gmail.com', N'JPass', 3338308, CAST(0x70370B00 AS Date), 0x1552CDC38DB8DAA6DF7AFC5A26F9E27CCF1AD4E5FF07EAB83A66E5ECFE708823D02EBD206036973D623266B9F2B11FD400B497ADAB4C260F8B561427ED6E88AE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (31, N'Nguyen', N'Jane', N'JNguyen@gmail.com', N'JPass', 3338308, CAST(0x70370B00 AS Date), 0x1552CDC38DB8DAA6DF7AFC5A26F9E27CCF1AD4E5FF07EAB83A66E5ECFE708823D02EBD206036973D623266B9F2B11FD400B497ADAB4C260F8B561427ED6E88AE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (32, N'Perry', N'Lee', N'LPerry@gmail.com', N'LPass', 3338308, CAST(0x70370B00 AS Date), 0xC54F74E15A48D69D1AA65F4EDE5153A70BC4F2A37FC81C40EF4D6699156101F10C5F1DAC51A9402A6D826FEFF485A1305E033FEBEF3C9DB1EE90EDC268232D5F)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (33, N'Norton', N'Carrie', N'CNorton@gmail.com', N'CPass', 1865726, CAST(0x70370B00 AS Date), 0x83D1913758276E94388330F4C14DE50DF119B93B6FBED5F6D5D2CFBD2A8D517C7EA0BF77BACB36BEF9DDFC43D2BA3A69FCD31F50009442B7465D0EDE3C12CFF9)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (34, N'Farris', N'Mark', N'MFarris@gmail.com', N'MPass', 1865726, CAST(0x70370B00 AS Date), 0xD6C6B88CB599D5DF26DDDCF5819AF8AA2A130A808C053EFC19BB0122A43C59B689C45D0992BA20BF475D528913A025190BD548DC9D8DCB5A9271BACAD69089F7)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (35, N'Farmer', N'Tim', N'TFarmer@gmail.com', N'TPass', 5094971, CAST(0x70370B00 AS Date), 0xFB907F5BF0781124C678DA19EDC3922EB0ED7C78B86DBF576A89D4330D5B2075105960C1B1FF2D182E4E66D8073162020C594B6DB22C292D4AAD8A54B7DB9362)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (36, N'Sanders', N'Lea', N'LSanders@gmail.com', N'LPass', 5094971, CAST(0x70370B00 AS Date), 0x5661D5F37581DD4D315BC9401FC25399B6A60F0BB927D4477B1D23F6347A70435A06C19D3672DE19F77E4599DC1C6F6709A4239FA7A7CA8B76116B4B14140760)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (37, N'Smith', N'Jim', N'JSmith@gmail.com', N'JPass', 5094971, CAST(0x70370B00 AS Date), 0x4EC3A1224D26572046D225756FA97506F4F7DC46A685239360E4BE1AEC819003CBAC15F6CF32C89E5AF57C00957498420813467DEE0AB49099F7EB46B3BAE291)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (38, N'Zukof', N'Petra', N'PZukof@gmail.com', N'PPass', 5094971, CAST(0x70370B00 AS Date), 0x7D5CBE73BD03B1CD59B747E216D29C9037D6CCC89583DD95E9CA8C60EE5041116B6B0233EF6A8598602701C04E3EB40ED73CA51287A9A030596D760AE7AFF4B7)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (39, N'Kim', N'Karen', N'KKim@gmail.com', N'KPass', 5094971, CAST(0x70370B00 AS Date), 0x8C1F8D63A7843AB380EE28D03F887B9B7D956DD82D9057776E749498CE5ADDD6BD530126A6B7B66BE686F2413B49184596B0B6211276CB23A100D96E58467059)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (40, N'Norman', N'Tina', N'TNorman@gmail.com', N'TPass', 5094971, CAST(0x70370B00 AS Date), 0xFB907F5BF0781124C678DA19EDC3922EB0ED7C78B86DBF576A89D4330D5B2075105960C1B1FF2D182E4E66D8073162020C594B6DB22C292D4AAD8A54B7DB9362)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (41, N'Manning', N'Carol', N'CManning@gmail.com', N'CPass', 5094971, CAST(0x70370B00 AS Date), 0xF5A44B974BBB1A84115942A8EB84575B7EF7893D2DC18B2BBFF59DB1D997B5DE38FF3A4BCB769DEA988EF3989F92089495BB0AD78F4DF55985BA9072C4A6B043)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (42, N'Patton', N'Laura', N'LPatton@gmail.com', N'LPass', 5094971, CAST(0x70370B00 AS Date), 0x5661D5F37581DD4D315BC9401FC25399B6A60F0BB927D4477B1D23F6347A70435A06C19D3672DE19F77E4599DC1C6F6709A4239FA7A7CA8B76116B4B14140760)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (43, N'Jorgenson', N'Amy', N'AJorgenson@gmail.com', N'APass', 5094971, CAST(0x70370B00 AS Date), 0x6EA26A56F56F378107AABCC9C60FB8C06586663FFC4F585DF0455D24BF61ABDF948F850AF1EF1BA3C77CDA365DBA7D80A3185C2434D684EFDD8022882E601F8B)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (44, N'Schneider', N'Franz', N'FSchneider@gmail.com', N'FPass', 5094971, CAST(0x70370B00 AS Date), 0xCAE0657BF6938041B4DCBC89561E972FE96A195E757655D98BFE12683837CA9D91BEF0C7CA453A891034FCD22806FB46E229D0B336D323BBED95BA97CD0CDE93)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (45, N'Kim', N'Lee', N'LKim@gmail.com', N'LPass', 8324216, CAST(0x70370B00 AS Date), 0xE16309CA49116CB2050DDCE10A9C928FB3F207927C3F4DAC0496A377C67741B212D34030F4C5A1261DC0269C603DD4FD8C14770193200DE8E532CF17D6D17A07)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (46, N'Denny', N'Phil', N'PDenny@gmail.com', N'PPass', 8324216, CAST(0x70370B00 AS Date), 0xC00D7F0B07DFA83A80976793061D1729D0EBCFEDEBA50AF510B987FB076C68DF045903C8B40C6B06B542BF8DFB41DD079A54E8B3943115D132C86886508E6404)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (47, N'Conner', N'Jessie', N'JConner@gmail.com', N'JPass', 8324216, CAST(0x7F2F0B00 AS Date), 0x819894EB2EDBC49717BF0D402ED6DE7D2979E48380BBE75A0DBD3CB31AB0228CAAD4C711325A98AF4D345DC6FAAE82DA1B1C62F2143A16A31968F55CD229E616)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (48, N'Keanne', N'Ann', N'AKeanne@gmail.com', N'APass', 8324216, CAST(0x70370B00 AS Date), 0x93CFD0D247E77198AB7A42EABE6F2A188976104D4A2741330783985122D72E7197D9DABD77C805BEF2B794B68773EB0D6B925037DF0B6C49714F3EECBD0EF337)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (49, N'Meuller', N'John', N'JMeuller@gmail.com', N'JPass', 8324216, CAST(0x70370B00 AS Date), 0x819894EB2EDBC49717BF0D402ED6DE7D2979E48380BBE75A0DBD3CB31AB0228CAAD4C711325A98AF4D345DC6FAAE82DA1B1C62F2143A16A31968F55CD229E616)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (50, N'Rogers', N'Cherise', N'CRogers@gmail.com', N'CPass', 8324216, CAST(0x70370B00 AS Date), 0xAA00A2C75129876FA7CD7DC07ED57C2ABC322BC3E4747408F279D5F2DED81A01E2F25A268332549B6EE94AB26BD77CDE84250D982E6FBC8663876EB27C1FB0A2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (51, N'Ponge', N'Sue', N'SPonge@gmail.com', N'SPass', 8324216, CAST(0x70370B00 AS Date), 0xDD58F533B72568029EA5750E615B99A30609A57B9D0A092F6F46235A8D9A70C4408E7118F84C18FA5A380365098524B776E97E118996F09C8F050B195FF58A22)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (53, N'Tanner', N'Chelsea', N'ctanner@gmail.com', N'mypasswd', 8324216, CAST(0x70370B00 AS Date), 0x78C5CFE845DB891A7F53299E5098AC08F11C82F51A79D76C3F45ECB8C1B1A0BD21065AD8C3CC0EF499B92136FC7974FA3A845C8140AC107FFDA411F43D6C1A5B)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (54, N'Olson', N'Sonya', N'solson@gmail.com', N'sonyapass', 6851633, CAST(0x70370B00 AS Date), 0x3EB230BFB0A7BFB478287C1AD8D2F21AE0BA5ED1A74AFE2E6FF9EAAD4D444C91C6CE6A7DB8265450A181957A71C8A49AC8AE18EF8609A109471D2BB297519501)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (55, N'Robertson', N'Jeff', N'JeffRobertson@msn.com', N'JRoberts', 4285846, CAST(0x72370B00 AS Date), 0xEDAE8A826EBFBF4762FEF8F0ADF384CD07BE364F8F7EB7A1567D468A53F61AD480F86B9C69EC0B85804F199EA95449601D68D57C4A2484E159773E07D6B7CEA3)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (56, N'Jameson', N'Jessica', N'jj@yahoo.com', N'jessicaPass', 2749031, CAST(0x72370B00 AS Date), 0xEFE8FBD87CA924626C5D96A4460760860B8526B4CDF9F7F3EC7961DA0A647F9459541D19CF3DB2B1C8A471F81EBB687FAA8CDBDBFE7BA2DEC93CF15D3C21CB4A)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (57, N'Masters', N'Carley', N'cmasters@msn.com', N'themaster', 5620605, CAST(0x72370B00 AS Date), 0xDFC6BD12C948438A1ECAC16C49407AF41C68310C76E76E41037F5EDEF56FC111922FA55E9AE9ACA80C461E0FB84A3F72150110BE2C295F1D78FF585FBB9CAEF1)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (58, N'Nelson', N'Martha', N'marthan@yahoo.com', N'NelsonPass', 2814605, CAST(0x72370B00 AS Date), 0xD0790BE0F37AF4A738AB570A5CA59263589AC651369AB323DA9943FD07FE4E65D078F1E8D33B6F462973DDC02A485C2CFA43D4188A4A7F28989E4BFFE0211D97)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (59, N'Pearson', N'Monica', N'pearson@gmail.com', N'pearsonPass', 5612101, CAST(0x77370B00 AS Date), 0xBCE8D23481F32A6381A30F62FF7372EEA7CD2689BF2D94288ABE0F6FED499547098D6D6D37A838E47AFC5424871F57FE94ABA6F70E70F9F72C12D773E9F489C7)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (60, N'Lynn', N'Jennifer', N'jl@aol.com', N'lynnPass', 8339094, CAST(0x77370B00 AS Date), 0x65FA8AFF2C4835AC3603394EEE37F4BBECB286A3856EA05322F1FCDF24529E8E4920F6B224E777E58EEA4647F330F6965808E03836666C7BD02D2D8C628CF4AB)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (61, N'Johnson', N'Tina', N'tj@msn.com', N'tinaPass', 7010204, CAST(0x77370B00 AS Date), 0xC9B588ECA81E4A7141FC78D2D0A5DC57A60108BB3DB403719B8FBA0C33C28CA4C5D5CA3B1A372D48D6917C0A726C4BE2B31ADA2CDB4090747F0D2A9AD0360AFE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (62, N'Thompson', N'Danielle', N'dthompson@msn.com', N'dtPass', 2780401, CAST(0x77370B00 AS Date), 0x80C02ED3C5E0CAB694667FB8DC4E83B9BAF0941F5E89ACFAAD932042D8B5B718DC91BD31AFAEB59EE546687DEC27A415F087788FE0D93733EBE6754C645CC153)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (63, N'Brown', N'Leah', N'leahbrown@comcast.com', N'leahPass', 1019655, CAST(0x77370B00 AS Date), 0x267ABDB406C54C1CE8FA7F7ABF123AFEF28DB70C2E1D8A31058DC71DB61BC8DF5A4F91580F8999B591E9E195121BF99CA258280B31614AA2D4DFE94A5C42990D)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (64, N'Nelson', N'Caitlin', N'caitlinnelson@msn.com', N'caitlinPass', 9929625, CAST(0x77370B00 AS Date), 0x28BD84D3C833903385732A59DE53BBA12069B4E670B94EA0BB702D86DF2BB4C7885C0E1647516697DB5096DD084E5686301D3F6054EA34A86D337A1EBA184393)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (65, N'Handle', N'Martin', N'handlethis@google.com', N'handlethisPass', 4027146, CAST(0x77370B00 AS Date), 0xDB0CF503056AF4E27DD8576FF6D32BD1572FCE777E455708F58BEE88A87CD3168AB60B39B17CDAEB54E43FAF9335515D69C4750304F32A49D7C1EFCD0A0DB222)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (66, N'Comstad', N'Fred', N'comstad@gmail.com', N'fredPass', 3487077, CAST(0x77370B00 AS Date), 0x9102E97427A223AE91D475B99108C0733C8BEE34321E0CC8D545BFB46ACBBBDE86A2F0F9BC0C7B48A087E4DC61A82F71436D1AE349A128D8DC45DE558B3493EE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (67, N'Manson', N'Patrick', N'pm@gmail.com', N'patPass', 8248342, CAST(0x78370B00 AS Date), 0x238ED6B6D151ED56A215A12EC7E4FCBB07F3F3FD63A4265F6BD2C10E4902F2F824681AE0AF49510EA6965DC5FCF2E51148140B523B6600D92FFD61A64D434FFB)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (68, N'Baker', N'Sally', N'sallyb@gmail.com', N'sBaker', 4200342, CAST(0x78370B00 AS Date), 0x81916D61C6233E2742B0BD4D80481EE64E71D68339BF4E4BC7EEC91387A578425E5276BDC0018D21CCE0C4C8863F9F38DBF3E1CDC277ACEC38A64714F92946F3)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (69, N'Mithin', N'Tammy', N'tammy@mithon.org', N'tammyPass', 2661350, CAST(0x78370B00 AS Date), 0x8A2326D88E4306113F39C838F18A6E21B7369D0B10BDB9C368A29960E6413E5494B3405855DA2AADF0FB4863D3B29BC99480FCDE0CF874D853C0BDCD76E5797D)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (70, N'Peterson', N'Monica', N'mpet@msn.com', N'monicaPass', 3926441, CAST(0x78370B00 AS Date), 0x74B28A8E42CDA6D227FA143CC6257D10F92DE21B1A3DBC2FCC3A26FCDD294AAF63BE6EE396566A55CE7C6F306FE30D1E496B9D3A751A9F2A3DEB2F01A675B988)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (71, N'Blake', N'Salem', N'salemblake@yahoo.com', N'salempass', 2490392, CAST(0x79370B00 AS Date), 0x73F58EF012D2ECBE4E6F6924097951F2DAC13808186AB0F59503927393B3BD6E1CBC9E1A7B5E840784C7CA90C9E9BA0DB6433C5217E126380B2F67AA87183BF4)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (72, N'Zorn', N'Ken', N'kz@yahoo.com', N'kzPass', 4304367, CAST(0x79370B00 AS Date), 0x34A5974F831EBF7C335D1302019168190CB18D516205FB7D2EA312A1DEF016D6801F1CFACD1BCF34466EFCD35D49EFFB421F13F2AAE1234D21068C789115076B)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (73, N'Baylor', N'Henry', N'hbaylor@uwashington.edu', N'hbPass', 3236262, CAST(0x79370B00 AS Date), 0x3EAC95222966BE8BD43D1717410D18EBA7BFEC8233AA265E47AC1EA803DA824B9D29755B55D13574F2473ED7CF7E78FBE3FB655BB7AD7C40CFC0B1F365695561)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (74, N'Taylor', N'Beth', N'btaylor@yahoo.com', N'bethPass', 8626647, CAST(0x79370B00 AS Date), 0x63D8BF100EDF55072E5FA9B1270C3CB6BB11585F3A3175D4C4C84D57F4C999CE4470E361535AB49C5491992115E57FC24A34D817CF84018F13FCEDC64A3E6086)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (75, N'Madison', N'Lawrence', N'lmadison@msn.com', N'madisonPass', 8958346, CAST(0x79370B00 AS Date), 0xE69FDEA4CCA80D347453CFB8C8BDBB3B6F1A532F639F19D392CF0381B7CFF823C4B48327CD317B3D922EF0508FF66A37F0C305083AB7CCEB2CB9B6BD56C88B0F)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (76, N'Gates', N'Bill', N'ggates@microsoft.com', N'bgatesPass', 8981262, CAST(0x79370B00 AS Date), 0x59477371E7AF61BC310555507F670A98C33C35449017175EA14905B424B2B5C23C42459727B0FF2FAD562BF4F320D7FE24CE6E80763C96AB5BF8840C43CD43A2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (77, N'Green', N'Lewis', N'lg@outlook.com', N'lgPass', 6763893, CAST(0x79370B00 AS Date), 0x08419C07FD281262189D58B3F60AA8A1ABCB19CD02291FA1F30FC568528A22597F16F21FD1E3B95172293BAC28C63E834CC975E5DD00FFF27D5953762345745C)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (78, N'Allen', N'Paul', N'pa@outlook.com', N'pallenPass', 6909274, CAST(0x79370B00 AS Date), 0xADCDA850B716E84B2752F4E1474BAD50F4207A405EDD5D7566D54557F083F7E3B456E79E17D03BCE29F657EC762D33197EEDEC4F09A15988E8F93B5B5EA8C11E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (79, N'Fortier', N'Karen', N'KFortier@outlook.com', N'KFPass', 7026519, CAST(0x79370B00 AS Date), 0x0277DAC8F6C6CE383442117D1BAA3446A9A90E41D743416E38F29AE3E4592D3FA05D817D937D5CD62748B4FA1365D749DA3913B4F073014FB577395601A6027C)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (80, N'nguyen', N'Lee', N'nguyen200@msn.com', N'leePass', 5090530, CAST(0x7A370B00 AS Date), 0x212ECA3CEB87485020C9223469778781CAA15FF1720E3095D91D7A522ED2130F4BFF235809DEF946E2A8D59FC0EAFCDA3BCBFC1D13647A95A3BECB93E6DDBC57)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (81, N'Christensen', N'Judy', N'jChristensen@seattleu.edu', N'judyPass', 6022177, CAST(0x7A370B00 AS Date), 0x66FB56E38DEE82E40B991392DF43E54C70623797A2836430DFC73F4FA23BE48E0B7D3301FFE460A9623ECB921B0A52B28C6A514B296F210AB992F9941CCC403F)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (82, N'Eliot', N'Neil', N'neliot@yahoo.com', N'neilPass', 2929660, CAST(0x7A370B00 AS Date), 0x77D65E32CE2469F49248D0E368C6E4143CFD3E2E4DA1F0350D209934AD6C3220D44B7A0F8B4A8D1E34746A653462F49B422B257417051E4A2E08C15D90AD0E10)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (83, N'Weinberg', N'Jeffery', N'jWeinberg@speakeasy.org', N'weinPass', 5523966, CAST(0x7A370B00 AS Date), 0xFCE8A1D9CA2C1B600A2527B2C974A435AA362EDD80D0DEB55B1D7D445650B93B66A630953B4E2B99DD8F12509DB46C2B2F9DCD188AD1BB9A539595E48C85370E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (84, N'Beneford', N'Gail', N'beneford@gmail.com', N'gailPass', 9924298, CAST(0x7A370B00 AS Date), 0x58B5367A80131032F046DC21C9DD3646B9FD6E4D7378AB39382072F05460A5C406DBFD40E3378E8CE76BA6EA66DF36A79F1989BED3FE64968726186336F9E28C)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (85, N'Owens', N'Leslie', N'leslieOwen@outlook.com', N'LesliePass', 1973408, CAST(0x7A370B00 AS Date), 0xDA4011BE3F78DAD1CEBE6AAE01BD15EA50458446D7FA2A88CEE7506375DF0AC225F179EAE50BE155262B8A00DC54E01741BCA9F84E96EA2BA622D121E475648D)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (86, N'Sullivan', N'Heather', N'heatherSullivan@gmail.com', N'heatherPass', 8307411, CAST(0x7F370B00 AS Date), 0x311BE7F91245482DF9090694CF69861125E2DD6CAB3C4A8E92B40085E8D7B5BC418AA46611580BAE7CDB9E3A844D7BF12543675023593DF632DC9CA53E10C244)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (87, N'KIngsley', N'Sally', N'sk@kingsley.com', N'SallyPass', 8652279, CAST(0x7F370B00 AS Date), 0x0309179B616A7611EC70139F6A306985BCB5FA67401BA78B82348C371BAFA87C84B300D67F34CDB0199F5A22E8972C117428A0165A06D5BB38C1EE6B94145204)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (88, N'Miller', N'Walter', N'waltermiller@yahoo.com', N'walterPass', 8807244, CAST(0x7F370B00 AS Date), 0x5EA147968A40009620AC0A3B2E7F1DD661DFC78AAAFD32963A2DCBFD551B8EF1A8E9725DF559AD88962B359BA80C33BDAFA5DB48AB01E0C3822E9E40F512B565)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (89, N'Nelson', N'Leah', N'leah@starwars.org', N'leahPass', 2435622, CAST(0x7F370B00 AS Date), 0x7FAB390CC5D52C2A45F66F0F18A5573124EA0C27B0874B02F7D9FA74E01DB6A76D2F8715A59D330CFDF85C7EB5D9D8194F0950845203267165A175C59B0FFEFF)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (90, N'Tanner', N'Nathan', N'natherntanner@gmail.com', N'tannerPass', 1390813, CAST(0x7F370B00 AS Date), 0x98E5F2498990C606E2F903D53107A6A37B853275D46EBC5EFB679978F268D5D1A21AD28259F9541B574C3E7506AEB094C515507D9CA7E4E6EFE3D5CE181E0591)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (91, N'Denten', N'Laura', N'ldenten@aol.com', N'ldPass', 8502425, CAST(0x7F370B00 AS Date), 0xEAAFE478DCC64D15E56F8FFF28DE21C55F668B43329F4AACF94D9F198FA24B2EEA97840E54872298F7D5997E15857DB9532323C553A971991B3BDA9C48F37EF6)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (92, N'Clayborne', N'Robert', N'rclayborne@outlook.com', N'calybornePass', 2346080, CAST(0x7F370B00 AS Date), 0x1B481113D686242C5CEEB20DCC09E2AC86438BEE0DA16351FF467BBD0DBBF769ADB0E8C3954F2D630FD7A35A88196450413297C8C9D1167311DF918B4A7B4536)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (93, N'Meyer', N'Paul', N'pmeyer@hotmail.com', N'paulPass', 5931143, CAST(0x7F370B00 AS Date), 0x8E761467905ADB470A1D88E86CCE980AD0D7D749B7BCEF533576B15BBC43C580F31BCB7B5D7DCA1EC6121E40034B376602151C753B8033B8EBB524928BF34F05)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (94, N'Mithen', N'Leslie', N'leslie24@hotmail.com', N'MithenPass', 6617795, CAST(0x7F370B00 AS Date), 0xE9AF0C00E78D9BE63D8828FABAD38D1F71267A5E970215443A1AC01E56B0C68A2F8097300173AF778A934AD736E2FE8663F9F841685972A5EAAEE3F3A1E9F6DE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (95, N'Hawks', N'Gina', N'hawks@northwest.org', N'hawksPass', 1883630, CAST(0x7F370B00 AS Date), 0xF790528425C1FF8CB91A1A5979CCCEE9223D3190210B7E2B3C36FA41378A0E43FB6875AC9FA8BFF641CC8E4F5D0879390834BA6FAAC79AA815B7CFBC4DA0DB47)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (96, N'Bishop', N'Martin', N'mBishop@enterprise.com', N'bishopPass', 1693337, CAST(0x7F370B00 AS Date), 0xBF19A9FB025CB5CFC013FF41CBC96D789E0D7B1E373F247CAEE2BDF40BB11A4887E36E5793F4245655B172B0C19C19113ADB28232C17F9DC16B278A58539716E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (97, N'Danielson', N'Erin', N'EDanielson@hotmail.com', N'ErinPass', 3318275, CAST(0x7F370B00 AS Date), 0x539F35C234D0D061570423F6F8E094AEF7BD0B17DD92E5C07C7E84D5087FE255D2CF7BE53335082809AAE4A2D295EF5D3BC5BA3E244753B7971CE45465A4A3B6)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (98, N'Skeat', N'Jonathen', N'skeat@newage.com', N'skeatPass', 3328834, CAST(0x7F370B00 AS Date), 0x7F2C0591E5636C5BBBDC4358F746B362EBE0648607A3A2CBDD4AA7696C772C8482BA7FE57F58C6A43ECD143E2B6DF99F49AFC4E05AEC80E02399E8569A51169E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (99, N'Lovelace', N'Monica', N'mlove@hotmail.com', N'monicaPass', 7465721, CAST(0x82370B00 AS Date), 0x997CD3487445D25AD0198A1923986458D63461248E050E12F6B49DCDBDEE436C8FFAE730DD3C61B7AE5B0586FD0F62DE6796EB8E03F877CB3A821D9B9F4B3C19)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (100, N'Manners', N'Jill', N'jillmanners@outlook.com', N'mannersPass', 4649606, CAST(0x82370B00 AS Date), 0xB6FECC2CCB5BC02127AE099726420AB8A52A8F9BD23328679E8AB2DC6CE877208E5B2C3808890B55F95B08FA849A7F0CD3FA7FF4C0C16EBCBF762DACA2CBB311)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (101, N'St. Marie', N'Nelson', N'nelson@seattleworks.org', N'nelsonPass', 2574413, CAST(0x82370B00 AS Date), 0xF3C3C9921729ACB32738B4706144A9E9179360563F9BF7932F8C3413BC093A44226F4BC304972F3B2FB38C4ACB64C3735699F22A5A81A24BE6A8BEC506982B9E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (102, N'Kerry', N'Elizabeth', N'ekerry@gmail.com', N'elizabethPass', 3160963, CAST(0x82370B00 AS Date), 0xCF9DD974706D97324EF237AAF27DAC0EBD418CB387DDFB827DD1D00307B1A560265201A5407C7DC903F864C702FBD301768D75C5004F10392A5C9275E355C866)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (103, N'Kendel', N'Harriet', N'hkendel@outlook.com', N'kendelPass', 4187422, CAST(0x83370B00 AS Date), 0xFB2044E807E12B734E183D219A708A4522A118EE5635C38BB0D213E9998FA5C75915952C61C2B11A80960CEB1EC2BCD4F3BF9AF521DB990E3A2693B4D3A078D3)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (104, N'Taylor', N'Rachel', N'rtaylor@gmail.com', N'rachelPass', 2656333, CAST(0x83370B00 AS Date), 0x9BE87419954267793DE980AAFE7F3FE9DDE9B831FB5437767F072E33E0FA2E75765FE3079051C0D296EC9355C18D4056F0425646750649EE324C1C8854A77A8E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (105, N'Grindle', N'Harris', N'hgrindle@outlook.com', N'grindlePass', 3784641, CAST(0x83370B00 AS Date), 0x95A6993A3AE68B8D229C35A963E5CDF9CFEC561B23A556E5CE5A835D1F43FDCD787E1952BEF24F8E2EEF89B956E4B93B303211BC603A4DE8CD5D65B895E377D5)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (106, N'Esperanzo', N'Letty', N'esperabzo@aol.com', N'lettyPass', 3541877, CAST(0x83370B00 AS Date), 0xCA37D28EB3EA7C7839F471BEEDB3A023AFA334FE8B4CE40D2342A2F54DAC638F0ED452BD764EA7ADF9D4CE93AF7360216CCE692D3EAC1E19359F49B6F7C58576)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (107, N'Susuki', N'Lee', N'leesusuki@emeraldcity.org', N'susukiPass', 5849492, CAST(0x83370B00 AS Date), 0x21C182FB2D78005510858C0219B69B23614965D088C0F879D21A721C48C245102F7C0B27C4AC5805C164F8D37547D24E259D34D51E9317FDD7A60DE3F1BF7C0D)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (108, N'Valencia', N'Roger', N'rvalencia@gmail.com', N'rogerPass', 4102888, CAST(0x85370B00 AS Date), 0xD8B2B6C78E4B7B7D6F50A6AEBBBC012620F21578B1E4D83D6BA5271A6CFAC3302DE0793E7BA87A6796B592374F9A2BDDDC503ACC16808C2EA51D1066C1D7FB9B)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (109, N'Scanlon', N'Renee', N'scanlon@outlook.com', N'ReneePass', 8389408, CAST(0x85370B00 AS Date), 0x765319AF5AB45352DCC683C46C69296A0EE2C63A049817A59296600DC667090946A9D8970CF0816716BBFDAB8F991BF2EDD9C833A1F8B5ED10931FE487CEE207)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (110, N'Pham', N'Lee', N'leepham@outlook.com', N'phamPass', 2611978, CAST(0x87370B00 AS Date), 0x21BC94062490E28F675286C074118ED43E5AF28504B4C606F15811866C7222C96C8B2AF1D2772B5ECDE974E4696881F9440978F17608862D9E68CE0CA0DE6AA2)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (111, N'Mandela', N'Terry', N'tmandela@community.org', N'TmPass', 2172173, CAST(0x87370B00 AS Date), 0x64B8FF7A6C4BCF61570AF8006020D96E4492A9622A31265FFF421179DAED7EC5FA1FB8CF21502272AE181816EBF53132BF33BF4D90822DE555DA0FEECF06E23C)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (112, N'Snow', N'Lester', N'lestersnow@hotmail.com', N'snowPass', 7773319, CAST(0x87370B00 AS Date), 0xBE8A9EBDF8B22CBCF3E1BE9E61034A4E3F688104B06265B51D81324E064491A59E2BB37389677D8EBC398AC28ADDFA88A7D40FF852293C8312310B8B59575FDE)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (113, N'Miller', N'Aldus', N'aldusmiller@gmail.com', N'aldusPass', 9821513, CAST(0x87370B00 AS Date), 0xAFF60BCD25A185B8DD47812DEDFFF314C6410917CC6C33B911741B0F63A12639B97E9E3DAF2A137B05FA451263E3E2F4456E518B3C9D534E35499222572EF541)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (114, N'Rogers', N'Jill', N'jillRogers@msn.com', N'rogersPass', 2227245, CAST(0x89370B00 AS Date), 0xCC635ACDA3FF015D1550B5A1F45F3368B5D17E2CD9C9D52A6FD462817B7152ADFCCAB58CD35D77B39D294FD71A3E7F3E0CEEF2A602859042D33303040F94F6E9)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (115, N'Sung', N'Mary', N'marysung@outlook.com', N'sungPass', 7242466, CAST(0x8B370B00 AS Date), 0x9392B1265BFE7EA32D52D54A482395CACCE2ACEC11FF0CB65673B17A9853CADE818759B60C901DC35582A617638F709EBB964CEBF0426FD939A97A62B5E75BFD)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (116, N'Jones', N'Lester', N'lj@speakeasy.org', N'LesterPass', 2186176, CAST(0x8B370B00 AS Date), 0x746FE55BE07F8D0674705A3B9622FA1B42DFAAD6D3F2E8110B92C7C97EBF2388404C460CD5486DC42598584CDE69082853585660296BC0E16D686E875D699C6F)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (117, N'Xui', N'Nick', N'Xui@yahoo.com', N'xuiPass', 9481604, CAST(0x8B370B00 AS Date), 0xA9E644698B46AB2356C45EDFA393CC66E95DA0AEF1A6765EBD9D567C91C4DB17D86CE307D68D923F90D1E905B05EDB40271EFC6898BCE1F05E696970F4FC0405)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (118, N'Yun', N'Luong', N'Yun@outlook.com', N'luongPass', 7990405, CAST(0x8B370B00 AS Date), 0x959AECDEE60742693531FFE3058C73A7E41D8EE0CC396AA3D5DA3828FD077C401550F9DA62EAF4F47143AA964A3C6E04C3E8269881F9F70E0B8EA9934BC14AC6)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (119, N'Kendrick', N'Peter', N'pk403@yahoo.com', N'kendrickPass', 9534021, CAST(0x8B370B00 AS Date), 0xC771AD70B8037A59557B2862041F5C0814EC2311E4C3C1073C9BD1D61A7BE57D3095492FB0BF5BA2BA29212581F49437CDD04EB04445A18C92A09B03F97D0502)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (120, N'Baker', N'Tom', N'tombaker@bbc.org', N'tardisPass', 2854319, CAST(0x8B370B00 AS Date), 0xDFA6AA9113E858DB22352E28C48E354A31B50C02E56A4FC8D26D4B887382B22CEE0380E68BE912579CA64E5B54E65AA3262703A594A97CCFC12CF51396E07538)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (121, N'Liddell', N'Scott', N'scottLiddel@oxford.uk.edu', N'liddellPass', 9864962, CAST(0x8B370B00 AS Date), 0x6DEC79A797174A92618DDAD7458C985E5763E253FC2A57A95049B6679B515AA694FF425331544225292EE1076437DE8D9345E91418EC0A2FE73BEAECE2A1E11F)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (122, N'Nguyen', N'Lee', N'leeNguyen@outlook.com', N'LeePass', 6340983, CAST(0x91370B00 AS Date), 0x8C5795D89DCAC2DCD7FBF95D8B9B5101FDB3A9D6F101181FEFE1B33D59C0880BDC9F11EA65FADE18A37767DABA5C49524023C5692C4FC3C96F4420A14484F5A5)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (123, N'Browning', N'Sally', N'SallyBrowning@aol.com', N'BrowningPass', 5088357, CAST(0x91370B00 AS Date), 0x3F005573FC30DB2C0CA32F8A7248F71CFC5E64BE75099E7144FBC0FF97D98AFD98CDEF1644D02300E5B0B6FD97D38C5071367B3EE6B98FF0E89E4B7229AAE01E)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (124, N'Stevens', N'Carla', N'carlaStevens@msn.com', N'carlastevensPass', 4307647, CAST(0x91370B00 AS Date), 0x0D0278B780D134448A0840C866EAD3411D7A5C73D6D219B7AF74C970029BF7177E34DE3D49CE9922BD7BCC71F75E23954F1C7DB201E400725D4EF36E0A1AF698)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (125, N'Steeler', N'Beth', N'bsteeler@hotmail.com', N'steelerPass', 2755811, CAST(0x91370B00 AS Date), 0x533F88A07DE669F8B462CBF27B80197FB1133DFB23EA0C6B2A66C254E0FB6C1E3B5080EC826A1FA23EDDAADE19CB15ADA5024602B6507EEEE9379825D219B1E4)
GO
INSERT [dbo].[Person] ([PersonKey], [PersonLastName], [PersonFirstName], [PersonUsername], [PersonPlainPassword], [Personpasskey], [PersonEntryDate], [PersonUserPassword]) VALUES (126, N'Davidson', N'Pat', N'patDavidson@speakeasy.org', N'DavidsonPass', 2048257, CAST(0x91370B00 AS Date), 0xB2BD8C7E003AB782FCC811F7E6C545C872164067F72EE1CA5918EC64DE75F97A3AB3278187991B7C6E4826CF9B51CD1B2DE6C6C88A8DA5461B2902024598A817)
GO
SET IDENTITY_INSERT [dbo].[Person] OFF
GO
SET IDENTITY_INSERT [dbo].[PersonAddress] ON 

GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (1, N'100 South Mann Street', NULL, N'WA', N'Seattle', N'98001', 1)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (2, N'328 Norh Division Blvd', N'205A', N'WA', N'Seattle', N'98001', 2)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (3, N'110 4th Avenue', N'Suite 756', N'WA', N'Seattle', N'98002', 3)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (4, N'230 Eastland Street', NULL, N'WA', N'Seattle', N'98001', 3)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (5, N'213 Elm Street', NULL, N'WA', N'Seattle', N'98001', 4)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (6, N'222 Jackson Way', N'201', N'WA', N'Seattle', N'98002', 5)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (7, N'132 Second Avenue', N'Suite 344', N'WA', N'Seattle', N'98010', 6)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (8, N'932 Maple Ave', NULL, N'WA', N'Seattle', N'98001', 7)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (9, N'1928 Bradly', NULL, N'WA', N'Seattle', N'98002', 8)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (10, N'7070 Westlake Ave', N'314', N'WA', N'Seattle', N'98001', 9)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (11, N'Western Towers', N'Suite 2003', N'WA', N'Seattle', N'98010', 10)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (12, N'100 Madison', N'Apt 905', N'WA', N'Seattle', N'98010', 10)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (13, N'201A Birch', NULL, N'WA', N'Seattle', N'98001', 11)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (14, N'1325 Backway Park Road', NULL, N'WA', N'Seattle', N'98001', 12)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (15, N'100 Main', NULL, N'WA', N'Kent', N'98011', 13)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (16, N'1212 Native Street', N'110', N'WA', N'Seattle', N'98001', 14)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (17, N'400 West Bank Road', NULL, N'WA', N'Seattle', N'98001', 15)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (18, N'1000 Forest Lane', NULL, N'WA', N'Bellevue', N'98012', 16)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (19, N'930 A Street', NULL, N'WA', N'Seattle', N'98002', 17)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (20, N'3030 Belle', N'720', N'WA', N'Seattle', N'98001', 18)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (21, N'23 W. Century Way', NULL, N'WA', N'Shoreline', N'98013', 19)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (22, N'909 Waterview Way', NULL, N'WA', N'Seattle', N'98002', 20)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (23, N'200 Division South', N'101', N'WA', N'Seattle', N'98001', 21)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (24, N'503 Route 20', NULL, N'WA', N'Seattle', N'98010', 22)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (25, N'100 12th Avenue', NULL, N'WA', N'Seattle', N'98001', 23)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (26, N'365 3rd Avenue South', N'213', N'WA', N'Seattle', N'98001', 24)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (27, N'99 C Street', NULL, N'WA', N'Seattle', N'98001', 25)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (28, N'233 Kelso Road', NULL, N'WA', N'Seattle', N'98010', 26)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (29, N'200 Lakeside Plaza', N'1200', N'WA', N'Seattle', N'98010', 27)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (30, N'22 Jackson Way', N'Rm 202', N'WA', N'Seattle', N'98002', 27)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (31, N'3400 Candlestick blvd', NULL, N'WA', N'Kent', N'98012', 28)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (32, N'922 Hillstone way', NULL, N'WA', N'Seattle', N'98002', 29)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (33, N'1112 Nelson Blvd', NULL, N'WA', N'Seattle', N'98002', 30)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (34, N'3400 Candlestick blvd', NULL, N'WA', N'Seattle', N'98002', 31)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (35, N'22 D Street', N'322', N'WA', N'Kent', N'98002', 32)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (36, N'200 Harvard', NULL, N'WA', N'Shoreline', N'98011', 33)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (37, N'1020 Smith Bld', N'Suite 222', N'WA', N'Seattle', N'98001', 34)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (38, N'900 West Lake', NULL, N'WA', N'Seattle', N'98002', 34)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (39, N'101 Fourth', N'523', N'WA', N'Seattle', N'98002', 35)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (40, N'1200 Wilson Road', NULL, N'WA', N'Seattle', N'98002', 36)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (41, N'3030 Lester', NULL, N'WA', N'Seattle', N'98002', 37)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (42, N'300 Brown', N'300', N'WA', N'Seattle', N'98002', 38)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (43, N'400 G Street', NULL, N'WA', N'Shoreline', N'98011', 39)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (44, N'5667 Patterson', N'103', N'WA', N'Seattle', N'98001', 40)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (45, N'9732 Denny', NULL, N'WA', N'Seattle', N'98001', 41)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (46, N'300 8th', NULL, N'WA', N'Seattle', N'98001', 42)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (47, N'278 Mall Way', N'Suite 200', N'WA', N'Bellevue', N'98013', 43)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (48, N'78 Yale Blvd', N'412', N'WA', N'Seattle', N'98002', 44)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (49, N'756 9th', N'Suite 200', N'WA', N'Seattle', N'98001', 45)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (50, N'800 23rd', N'Suite 1200', N'WA', N'Bellevue', N'98013', 45)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (51, N'303 Lincoln', NULL, N'WA', N'Seattle', N'98002', 46)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (52, N'879 Martin', NULL, N'WA', N'Seattle', N'98002', 47)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (53, N'900 South Broadway', NULL, N'WA', N'Seattle', N'98001', 48)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (54, N'8792 N Street', NULL, N'WA', N'Seattle', N'98002', 49)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (55, N'500 Still Street', NULL, N'WA', N'Seattle', N'98001', 50)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (56, N'900 Fifth Avenue', NULL, N'WA', N'Seattle', N'98001', 51)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (57, N'1001 Meridain South', NULL, N'WA', N'Seattle', N'98911', 51)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (58, N'1001 Meridain South', NULL, N'WA', N'Seattle', N'98911', 53)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (59, N'1001 Fremont South', NULL, N'WA', N'Seattle', N'98911', 54)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (60, N'1924 Broadway street', NULL, N'WA', N'Seattle', N'98102', 55)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (61, N'2001 Oddessy Avenue', NULL, N'WA', N'Seattle', N'98001', 56)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (62, N'Kenwood Blvd', NULL, N'WA', N'Seattle', N'98001', 57)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (63, N'1823 Eastern Way', NULL, N'WA', N'Seattle', N'98122', 58)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (64, N'201 South Luther Way', NULL, N'WA', N'Seattle', N'98002', 59)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (65, N'111 South Jackson', N'203', N'WA', N'Seattle', N'98122', 60)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (66, N'2312 Broadway Ave', NULL, N'WA', N'Seattle', N'98122', 61)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (67, N'121 Brandon Way', NULL, N'WA', N'Seattle', N'98002', 62)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (68, N'2022 Northgate way', NULL, N'WA', N'Seattle', N'98011', 63)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (69, N'802 Pine', N'243', N'WA', N'Seattle', N'98212', 64)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (70, N'2323 24th Street', NULL, N'WA', N'Seattle', N'98112', 65)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (71, N'2102 Pike ', N'110', N'WA', N'Seattle', N'98122', 66)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (72, N'1230 Meridian Street', NULL, N'WA', N'Puyallup', N'98328', 67)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (73, N'234 2nd Ave ', NULL, N'WA', N'Seattle', N'98100', 68)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (74, N'404 EightAvenue', NULL, N'WA', N'Bellevue', N'98234', 69)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (75, N'21st ', N'101 ', N'WA', N'Seattle', N'98100', 70)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (76, N'200 S Fifth', N'103', N'WA', N'Seattle', N'98003', 71)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (77, N'24th Street E', NULL, N'WA', N'Seattle', N'98123', 72)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (78, N'211 Pacific Ave', N'321', N'WA', N'Seattle', N'98102', 73)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (79, N'1405 Pine', N'343', N'WA', N'Seattle', N'98100', 74)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (80, N'201 North Elliot', NULL, N'WA', N'Seattle', N'98011', 75)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (81, N'', NULL, N'', N'', N'', 76)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (82, N'234 Ballard Way', N'121', N'WA', N'Seattle', N'98100', 77)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (83, N'', NULL, N'', N'', N'', 78)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (84, N'204 34th Street', NULL, N'WA', N'Seattle', N'980122', 79)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (85, N'212 Union Street', NULL, N'WA', N'Seattle', N'98001', 80)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (86, N'123 14th', N'203', N'WA', N'Seattle', N'98123', 81)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (87, N'323 North Broad Street', NULL, N'WA', N'Seattle', N'98124', 82)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (88, N'291 harvard', N'321', N'WA', N'Seattle', N'98100', 83)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (89, N'2323 WestLake', N'201', N'WA', N'Seattle', N'98110', 84)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (90, N'2345 Eastlake', NULL, N'WA', N'Seattle', N'98100', 85)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (91, N'1423 North Pike', N'322', N'WA', N'Seattle', N'98123', 86)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (92, N'203 South Denny', NULL, N'WA', N'Seattle', N'98200', 87)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (93, N'346 2nd Ave', N'435', N'WA', N'Seattle', N'98100', 88)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (94, N'2021 Bell', N'765', N'WA', N'Seattle', N'98100', 89)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (95, N'1201 Magnolia blvd', NULL, N'WA', N'Seattle', N'98100', 90)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (96, N'Bell', N'451', N'WA', N'Seattle', N'98100', 91)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (97, N'324 82nd Ave', NULL, N'WA', N'Seattle', N'98001', 92)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (98, N'234 Ballard Way', N'212', N'WA', N'Seattle', N'98100', 93)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (99, N'2121 65th Street', NULL, N'WA', N'Seattle', N'98001', 94)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (100, N'292 Greenwood', NULL, N'WA', N'Seattle', N'98100', 95)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (101, N'1201 East 8th', N'756', N'WA', N'Bellevue', N'98302', 96)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (102, N'306 Westlake', NULL, N'WA', N'Seattle', N'98100', 97)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (103, N'121 Harvard', N'344', N'WA', N'Seattle', N'98122', 98)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (104, N'325 24th Street', N'101', N'WA', N'Seattle', N'98001', 99)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (105, N'2003 North 34th', NULL, N'WA', N'Seattle', N'98100', 100)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (106, N'501 Nineth', N'343', N'WA', N'Seattle', N'98100', 101)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (107, N'213 NorthGate Blvd', NULL, N'', N'', N'', 102)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (108, N'North 8th Street', N'345', N'WA', N'Seattle', N'98100', 103)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (109, N'203 East Ballard', NULL, N'WA', N'Seattle', N'98001', 104)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (110, N'102 34thStreet', N'303', N'WA', N'Seattle', N'98100', 105)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (111, N'404 Lester aver', NULL, N'WA', N'Seattle', N'98001', 106)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (112, N'102 Jackson Street', N'342', N'WA', N'Seattle', N'98002', 107)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (113, N'2003 Northwest Blvd', N'231b', N'WA', N'Seattle', N'98100', 108)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (114, N'1231 15th', NULL, N'WA', N'Seattle', N'98100', 109)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (115, N'1101 Pine', N'121', N'WA', N'Seattle', N'98100', 110)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (116, N'908 24th Streer', NULL, N'WA', N'Seattle', N'98001', 111)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (117, N'131 North 36th Ave', NULL, N'WA', N'Seattle', N'98001', 112)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (118, N'201 Queen Anne', N'213', N'WA', N'Seattle', N'98100', 113)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (119, N'204 56th Street', NULL, N'WA', N'Redmond', N'98102', 114)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (120, N'324 WestLake Drive', NULL, N'WA', N'Seattle', N'98001', 115)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (121, N'1536 Madison', N'109', N'WA', N'Seattle', N'98200', 116)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (122, N'2031 15th East', N'453', N'WA', N'Seattle', N'98100', 117)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (123, N'1245 James ', NULL, N'WA', N'Seattle', N'98001', 118)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (124, N'432 24th Ave', NULL, N'WA', N'Seattle', N'98101', 119)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (125, N'203 Tardis Way', NULL, N'WA', N'Seattle', N'98100', 120)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (126, N'900 West Fifth', NULL, N'NY', N'New York', N'00012', 121)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (127, N'324 8th Street', N'419', N'WA', N'Seattle', N'98001', 122)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (128, N'153 North Denny', NULL, N'WA', N'Seattle', N'98002', 123)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (129, N'456 Eastlake', NULL, N'WA', N'Seattle', N'98100', 124)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (130, N'334 Ballard Ave', N'2', N'WA', N'Seattle', N'98002', 125)
GO
INSERT [dbo].[PersonAddress] ([PersonAddressKey], [Street], [Apartment], [State], [City], [Zip], [PersonKey]) VALUES (131, N'333 South Eliot Way', NULL, N'WA', N'Seattle', N'98002', 126)
GO
SET IDENTITY_INSERT [dbo].[PersonAddress] OFF
GO
SET IDENTITY_INSERT [dbo].[PersonContact] ON 

GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (1, N'2065551234', 1, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (2, N'2065552345', 2, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (3, N'3605551234', 2, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (4, N'2065551356', 3, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (6, N'2065555678', 4, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (7, N'2065556789', 5, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (8, N'2065550001', 5, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (10, N'2065559876', 6, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (11, N'2065553344', 6, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (13, N'2065558642', 7, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (14, N'2065550002', 7, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (17, N'2065550875', 9, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (18, N'2065556767', 10, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (19, N'2065552323', 11, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (20, N'2065551111', 11, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (22, N'2065559965', 12, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (23, N'2065550003', 12, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (25, N'4155551234', 13, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (26, N'4155550001', 13, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (27, N'4155551469', 13, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (28, N'2065550192', 14, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (29, N'2065557777', 15, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (30, N'36065551234', 16, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (31, N'2065552121', 17, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (32, N'2065550747', 18, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (33, N'2065550004', 18, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (35, N'2065558888', 18, 4)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (36, N'4155551200', 19, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (38, N'2065557089', 20, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (39, N'2065552543', 21, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (40, N'2065558697', 22, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (41, N'2065551666', 23, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (42, N'2065550005', 23, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (44, N'2065550019', 23, 4)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (45, N'3605552374', 24, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (46, N'2065552019', 25, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (47, N'2065558734', 26, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (48, N'2065559532', 27, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (50, N'4155551987', 28, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (51, N'2065551003', 29, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (53, N'2065554710', 30, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (55, N'2065553478', 31, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (57, N'3065551277', 32, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (58, N'3065551008', 32, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (59, N'2065557102', 33, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (60, N'2065559381', 34, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (61, N'2065556842', 35, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (62, N'2065557046', 36, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (64, N'2065550065', 37, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (65, N'2065559603', 38, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (66, N'4255551234', 39, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (67, N'2065551113', 40, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (68, N'2065552224', 41, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (70, N'2065552354', 42, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (71, N'3605558886', 43, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (73, N'2065555060', 44, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (74, N'2065550033', 45, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (76, N'2065550853', 46, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (78, N'2065550706', 47, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (79, N'4235551423', 48, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (80, N'2065550006', 48, 2)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (82, N'2065557543', 49, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (83, N'2065558206', 50, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (84, N'2065557102', 51, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (87, N'2065559823', 51, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (89, N'2065559823', 53, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (91, N'2065559723', 54, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (92, N'2065559082', 55, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (93, N'2535551002', 55, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (94, N'2065553297', 56, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (95, N'2535552754', 56, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (96, N'2065553222', 57, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (97, N'3605559001', 57, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (98, N'3605551298', 58, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (99, N'3605558708', 58, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (100, N'2065554343', 59, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (102, N'2065552021', 60, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (103, N'2535557676', 60, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (105, N'2535558731', 61, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (106, N'3605556983', 62, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (107, N'2065554342', 63, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (108, N'2065551254', 64, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (109, N'3605552100', 64, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (110, N'2525554009', 65, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (111, N'2535557812', 66, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (112, N'3605552170', 67, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (113, N'3605552100', 67, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (114, N'2065552301', 68, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (115, N'3605558021', 69, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (116, N'2535559010', 69, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (117, N'2065553278', 70, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (118, N'2065559801', 71, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (119, N'2065554803', 72, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (120, N'3605558715', 73, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (121, N'2535552988', 74, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (122, N'2065551067', 75, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (123, N'2535552968', 75, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (124, N'3605559000', 76, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (125, N'2065552579', 77, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (126, N'3605559809', 78, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (127, N'2065552975', 79, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (128, N'2535556757', 79, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (129, N'2535559802', 80, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (130, N'2535554209', 81, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (131, N'2065552950', 82, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (132, N'3605553421', 83, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (133, N'2065552197', 84, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (134, N'2535558631', 84, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (135, N'2065552910', 85, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (136, N'2065552198', 86, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (137, N'3605559999', 86, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (138, N'2065558134', 87, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (139, N'3605555742', 88, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (140, N'2065553030', 89, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (141, N'2535551209', 89, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (142, N'2065552017', 90, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (143, N'2535550065', 91, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (144, N'2065552132', 92, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (145, N'2535557722', 93, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (146, N'2065550091', 94, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (147, N'2065554444', 95, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (148, N'3695551010', 95, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (149, N'2065553399', 96, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (150, N'2535551000', 96, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (151, N'3605552188', 97, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (152, N'3605556689', 98, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (153, N'2535551069', 99, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (154, N'3605552449', 100, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (155, N'2065552245', 101, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (156, N'2535550087', 101, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (157, N'2065558856', 102, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (158, N'2065553002', 103, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (159, N'2065553021', 104, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (160, N'2065557772', 105, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (161, N'2065558981', 106, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (162, N'3605551821', 106, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (163, N'2535559011', 107, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (164, N'2065559975', 108, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (165, N'3605552112', 108, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (166, N'2535556809', 109, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (167, N'3605551558', 110, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (168, N'3605557766', 111, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (169, N'2965552200', 112, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (170, N'3605552111', 113, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (171, N'3605552398', 114, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (172, N'2065563014', 115, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (173, N'3605552111', 115, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (174, N'2535552009', 116, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (175, N'2065557788', 117, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (176, N'3685553298', 117, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (177, N'2065550087', 118, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (178, N'3635559001', 118, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (179, N'2065556665', 119, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (180, N'2065550000', 120, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (181, N'1005552367', 121, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (182, N'2065558884', 122, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (183, N'3605553212', 122, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (184, N'3605552323', 123, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (185, N'2535557811', 124, 3)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (186, N'2065554499', 125, 1)
GO
INSERT [dbo].[PersonContact] ([ContactKey], [ContactInfo], [PersonKey], [ContactTypeKey]) VALUES (187, N'2535550091', 126, 3)
GO
SET IDENTITY_INSERT [dbo].[PersonContact] OFF
GO
SET IDENTITY_INSERT [dbo].[ServiceGrant] ON 

GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (1, 75.0000, CAST(0x0000A2150103563C AS DateTime), 4, 1, 2, CAST(0x71370B00 AS Date), N'Approved', N'We have two children and are running low of money for groceries this month', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (2, 180.0000, CAST(0x0000A2150103563C AS DateTime), 14, 3, 2, CAST(0x71370B00 AS Date), N'approved', N'We can''t afford childcare this month, but need to use it if we are going to work', 180.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (3, 300.0000, CAST(0x0000A2150103563C AS DateTime), 27, 7, 2, CAST(0x71370B00 AS Date), N'denied', N'Our Utilities bills have been extra high this month because of the excessive heat', 300.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (4, 75.0000, CAST(0x0000A2150103563C AS DateTime), 9, 1, 1, CAST(0x71370B00 AS Date), N'approved', N'Our food stamps have been reduced and we can''t afford basic groceries', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (5, 200.0000, CAST(0x0000A2150103563C AS DateTime), 39, 10, 3, CAST(0x71370B00 AS Date), N'Approved', N'The kids need clothes for the upcoming school year', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (6, 75.0000, CAST(0x0000A2150103563C AS DateTime), 25, 1, 4, CAST(0x71370B00 AS Date), N'approved', N'We have run short of food money', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (7, 500.0000, CAST(0x0000A2150103563C AS DateTime), 25, 8, 4, CAST(0x71370B00 AS Date), N'approved', N'The pipe in our bathroom broke and ruined the floor', 500.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (8, 100.0000, CAST(0x0000A2150103563C AS DateTime), 1, 4, 6, CAST(0x71370B00 AS Date), N'Approved', N'I just got a new job and need a bus pass. After I have gotten a paycheck I can afford my own.', 100.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (9, 75.0000, CAST(0x0000A2150103563C AS DateTime), 1, 1, 6, CAST(0x71370B00 AS Date), N'approved', N'Food money is short and we don''t qualify for food stamps', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (10, 800.0000, CAST(0x0000A2150103563C AS DateTime), 16, 2, 5, CAST(0x71370B00 AS Date), N'denied', N'I need to have a treatment for skin condition', 800.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (11, 600.0000, CAST(0x0000A2150103563C AS DateTime), 20, 1, 5, CAST(0x71370B00 AS Date), N'approved', N'We are going to be short of rent this coming month because of some unexpected bills. We have talked to the landlord but he is unwilling to let us pay late.', 600.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (12, 75.0000, CAST(0x0000A2150103563C AS DateTime), 25, 1, 4, CAST(0xAF370B00 AS Date), N'approved', N'Kids need food.', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (13, 75.0000, CAST(0x0000A2150103563C AS DateTime), 39, 1, 3, CAST(0x72370B00 AS Date), N'approved', N'Food stamps have run out, but still need to feed the kids', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (14, 475.0000, CAST(0x0000A2150103563C AS DateTime), 17, 6, 1, CAST(0x72370B00 AS Date), N'denied', N'I need to have several fillings. I have insurance, but can''t afford the part I have to pay.', 475.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (15, 100.0000, CAST(0x0000A2150103563C AS DateTime), 49, 10, 4, CAST(0x72370B00 AS Date), N'approved', N'Need clothes for school', 100.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (16, 133.0000, CAST(0x0000A2150103563C AS DateTime), 45, 7, 3, CAST(0x72370B00 AS Date), N'approved', N'Our landlord requires us to maintain the lawn, but we can''t afford the water bill.', 133.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (17, 500.0000, CAST(0x0000A2150103563C AS DateTime), 37, 9, 4, CAST(0x72370B00 AS Date), N'denied', N'Need Help paying tuition for Fall classes', 500.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (18, 75.0000, CAST(0x0000A2150103563C AS DateTime), 34, 1, 4, CAST(0x72370B00 AS Date), N'approved', N'Empty cupboards', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (19, 850.0000, CAST(0x0000A2150103563C AS DateTime), 34, 2, 5, CAST(0x72370B00 AS Date), N'approved', N'We are short of our rent payment this month', 850.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (20, 500.0000, CAST(0x0000A2150103563C AS DateTime), 16, 2, 5, CAST(0x72370B00 AS Date), N'approved', N'The rent payment has gone up and we weren''t prepared for the increase in expenses.', 500.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (21, 75.0000, CAST(0x0000A2150103563C AS DateTime), 25, 1, 4, CAST(0x72370B00 AS Date), N'approved', N'Food prices have gone up. Our budget won''t stretch through the month.', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (22, 75.0000, CAST(0x0000A2150103563C AS DateTime), 27, 1, 1, CAST(0x72370B00 AS Date), N'approved', N'Can''t afford food this month', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (23, 200.0000, CAST(0x0000A2150103563C AS DateTime), 27, 3, 2, CAST(0x72370B00 AS Date), N'approved', N'Have a new job and need child care until I can get a paycheck or two', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (24, 500.0000, CAST(0x0000A2150103563C AS DateTime), 21, 9, 3, CAST(0x72370B00 AS Date), N'denied', N'Need help with Fall Tuition', 500.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (25, 197.0000, CAST(0x0000A2150103563C AS DateTime), 9, 7, 4, CAST(0x72370B00 AS Date), N'approved', N'Utilities were unexpectedly high this month', 197.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (26, 75.0000, CAST(0x0000A2150103563C AS DateTime), 43, 1, 1, CAST(0x72370B00 AS Date), N'Approved', N'Kids need Food', 75.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (27, 475.0000, CAST(0x0000A2150103563C AS DateTime), 24, 8, 2, CAST(0x72370B00 AS Date), N'approved', N'Roof is leaking need to repair before Autumn', 475.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (28, 250.0000, CAST(0x0000A2150103563C AS DateTime), 22, 3, 2, CAST(0x72370B00 AS Date), N'approved', N'Need child care while training for my job', 250.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (29, 1200.0000, CAST(0x0000A2150103563C AS DateTime), 45, 2, 5, CAST(0x72370B00 AS Date), N'Denied', N'Can''t pay rent', 1200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (30, 1200.0000, CAST(0x0000A2150103563C AS DateTime), 46, 9, 3, CAST(0x72370B00 AS Date), N'denied', N'Need Help with Fall Tuition', 1200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (31, 400.0000, CAST(0x0000A2150103563C AS DateTime), 39, 5, 4, CAST(0x72370B00 AS Date), N'denied', N'My Doctor says I must have a colonoscopy. I have some insurance but cannot pay the deducttable.', 400.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (32, 175.0000, CAST(0x0000A2150103563C AS DateTime), 32, 10, 2, CAST(0x72370B00 AS Date), N'approved', N'We need school clothes for three elementary school students', 175.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (33, 367.0000, CAST(0x0000A2150103563C AS DateTime), 26, 8, 3, CAST(0x72370B00 AS Date), N'approved', N'Need plumming repairs in the Kitchen', 367.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (34, 475.0000, CAST(0x0000A2150103563C AS DateTime), 36, 6, 1, CAST(0x72370B00 AS Date), N'denied', N'I need a tooth extraction and can''t afford it', 475.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (35, 65.0000, CAST(0x0000A21C00ADB650 AS DateTime), 59, 4, 4, CAST(0x77370B00 AS Date), N'Approved', N'I need a bus pass to get me to work until I can get my first pay check', 65.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (36, 200.0000, CAST(0x0000A21C00BD897C AS DateTime), 60, 7, 4, CAST(0x77370B00 AS Date), N'approved', N'I just need a one time grant to cover an unexpected water bill--the result of a leak', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (37, 125.0000, CAST(0x0000A21C00BE2FE4 AS DateTime), 61, 9, 4, CAST(0x77370B00 AS Date), N'approved', N'Need to buy supplies for three elementary school students', 125.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (38, 500.0000, CAST(0x0000A21C00C020C4 AS DateTime), 62, 13, 4, CAST(0x77370B00 AS Date), N'approved', N'I need money to go to a one time training to keep my job', 500.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (39, 85.5000, CAST(0x0000A21C00C27540 AS DateTime), 63, 3, 4, CAST(0x77370B00 AS Date), N'approved', N'Need childcare for short term while Training for job', 85.5000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (40, 450.0000, CAST(0x0000A21C00C32058 AS DateTime), 64, 5, 4, CAST(0x77370B00 AS Date), N'Reduced', N'Need to pay an emergency room bill from three months ago', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (41, 345.6600, CAST(0x0000A21C00C3ABCC AS DateTime), 65, 8, 4, CAST(0x77370B00 AS Date), N'Approved', N'Floor in kitchen ruined by a bad dishwasher', 345.6600)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (42, 200.0000, CAST(0x0000A21C00C4BBAC AS DateTime), 66, 2, 4, CAST(0x77370B00 AS Date), N'approved', N'One of my roommates left without paying his share of the rent. We are getting a new roommate as soon as possible', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (43, 200.0000, CAST(0x0000A21D00C3FF00 AS DateTime), 68, 9, 4, CAST(0x79370B00 AS Date), N'approved', N'Need supplies and clothes for 2 children  in Elementary school', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (44, 250.0000, CAST(0x0000A21D00C57F60 AS DateTime), 70, 3, 4, CAST(0x79370B00 AS Date), N'approved', N'I need child care for a couple of days while I go in for surgery', 250.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (45, 200.0000, CAST(0x0000A21E00AEC3D8 AS DateTime), 72, 9, 4, CAST(0x7A370B00 AS Date), N'approved', N'My financial aid doesn''t cover text books', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (46, 120.0000, CAST(0x0000A21E00AF7F58 AS DateTime), 73, 1, 4, CAST(0x79370B00 AS Date), N'approved', N'I have no money left for food after college and room expenses', 120.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (47, 300.0000, CAST(0x0000A21E00B0511C AS DateTime), 74, 13, 4, CAST(0x7A370B00 AS Date), N'approved', N'My father has become quite ill. I don''t have the money to go visit him', 300.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (48, 200.0000, CAST(0x0000A21F0104B11C AS DateTime), 80, 13, 4, CAST(0x7A370B00 AS Date), N'approved', N'I need a little extra to fly home to visit my father in Vietnam', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (49, 320.0000, CAST(0x0000A21F01055C34 AS DateTime), 81, 9, 4, CAST(0x7A370B00 AS Date), N'Approved', N'I need money for books. I have paid for all the rest', 320.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (50, 150.0000, CAST(0x0000A21F0105FB94 AS DateTime), 82, 10, 4, CAST(0x7A370B00 AS Date), N'denied', N'Need clothes to attend a wedding', 150.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (51, 356.9000, CAST(0x0000A21F0106FD64 AS DateTime), 83, 8, 4, CAST(0x0D360B00 AS Date), N'Approved', N'Roof sprang a leak. This is amount is the difference between what I can afford and what it will cost', 356.9000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (52, 250.0000, CAST(0x0000A21F01079DF0 AS DateTime), 84, 3, 4, CAST(0x7A370B00 AS Date), N'approved', N'Need temporary childcare while I look for work', 250.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (53, 345.2100, CAST(0x0000A21F010876BC AS DateTime), 85, 6, 4, CAST(0x7A370B00 AS Date), N'approved', N'I need a filling and have no dental insurance. This would be the down payment. I would make monthly payments after that', 345.2100)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (54, 255.5000, CAST(0x0000A22400C5AABC AS DateTime), 86, 4, 4, CAST(0x7F370B00 AS Date), N'Approved', N'I need a one month buss pass until I start getting paychecks', 255.5000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (55, 432.7500, CAST(0x0000A22400D00584 AS DateTime), 87, 5, 4, CAST(0x81370B00 AS Date), N'Approved', N'Had foot surgery. Paid for all I could', 432.7500)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (56, 450.7500, CAST(0x0000A22400D09350 AS DateTime), 88, 13, 4, CAST(0x81370B00 AS Date), N'Approved', N'I need money to travel to a job interview', 450.7500)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (57, 150.6600, CAST(0x0000A22400D13E68 AS DateTime), 89, 7, 4, CAST(0x74370B00 AS Date), N'Reduced', N'Need to pay electricity or they will shut it off', 50.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (58, 689.9900, CAST(0x0000A22400D1D33C AS DateTime), 90, 6, 4, CAST(0x81370B00 AS Date), N'Reduced', N'I have no insurance and need a crown badly', 189.9900)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (59, 300.0000, CAST(0x0000A22400D25424 AS DateTime), 91, 3, 4, CAST(0x81370B00 AS Date), N'approved', N'I need child care for three weeks while I train for my new job', 300.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (60, 454.5000, CAST(0x0000A22400D2F4B0 AS DateTime), 92, 8, 4, CAST(0x81370B00 AS Date), N'Approved', N'I need emergency roof repair', 454.5000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (61, 550.4400, CAST(0x0000A22400D3DDE4 AS DateTime), 93, 13, 4, CAST(0x81370B00 AS Date), N'Reduced', N'My mother broke her hip and has no one to watch her. I need to fly back to help out for a couple of weeks', 340.9600)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (62, 450.0000, CAST(0x0000A22400D46958 AS DateTime), 94, 8, 4, CAST(0x81370B00 AS Date), N'Reduced', N'The bathroom floor needs serious repair', 300.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (63, 250.0000, CAST(0x0000A22400D56678 AS DateTime), 95, 7, 4, CAST(0x81370B00 AS Date), N'Reduced', N'Because of a broken pipe my water bill is extremely high. I have had the pipe repaired', 100.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (64, 250.0000, CAST(0x0000A22400D6D544 AS DateTime), 97, 9, 4, CAST(0x81370B00 AS Date), N'Denied', N'I need to attend a seminar for my job but the employer won''t pay for it', 0.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (65, 545.5500, CAST(0x0000A22400D7DE1C AS DateTime), 98, 6, 4, CAST(0x81370B00 AS Date), N'Reduced', N'I need to have my wisdom teeth extracted', 145.5500)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (66, 255.0000, CAST(0x0000A2270157A250 AS DateTime), 99, 4, 4, CAST(0x83370B00 AS Date), N'Reduced', N'Need a bus pass for one month to start school', 125.5000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (67, 200.0000, CAST(0x0000A2270158CACC AS DateTime), 100, 1, 4, CAST(0x83370B00 AS Date), N'approved', N'I have run out of foodstamps, and money', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (68, 545.5000, CAST(0x0000A2270159A71C AS DateTime), 101, 9, 4, CAST(0x83370B00 AS Date), N'denied', N'I need to take a class to become certified for employment', 0.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (69, 230.4000, CAST(0x0000A227015AF9C8 AS DateTime), 102, 8, 4, CAST(0x83370B00 AS Date), N'approved', N'Back door broken need it fixed for safety', 230.4000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (70, 234.9900, CAST(0x0000A228012002DC AS DateTime), 103, 9, 4, CAST(0x85370B00 AS Date), N'Reduced', N'This is the cost of books beyond which my financial aide covers', 100.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (71, 300.0000, CAST(0x0000A228014A7F08 AS DateTime), 104, 3, 4, CAST(0x85370B00 AS Date), N'approved', N'I need childcare during my first month of work', 300.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (72, 476.5500, CAST(0x0000A228014BFE3C AS DateTime), 105, 8, 4, CAST(0x85370B00 AS Date), N'approved', N'Need to buy lumber to build a wheelchair rampon the house', 476.5500)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (73, 450.0000, CAST(0x0000A228014C9C70 AS DateTime), 106, 6, 4, CAST(0x85370B00 AS Date), N'Reduced', N'Need a root canal and have no insurance', 200.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (74, 675.0000, CAST(0x0000A228014D8F04 AS DateTime), 107, 13, 4, CAST(0x85370B00 AS Date), N'approved', N'Need to air fair home to help my ailing father', 675.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (75, 230.2000, CAST(0x0000A22A01564C20 AS DateTime), 108, 7, 4, CAST(0x89370B00 AS Date), N'approved', N'I need to fill up the oil tank before winter', 230.2000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (76, 140.0000, CAST(0x0000A22A0156DD70 AS DateTime), 109, 3, 4, CAST(0x89370B00 AS Date), N'approved', N'Need help with childcare', 140.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (77, 136.7700, CAST(0x0000A22C012B89A4 AS DateTime), 110, 9, 4, CAST(0x89370B00 AS Date), N'approve', N'Need graphing calculator for myhigh school student', 136.7700)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (78, 420.0000, CAST(0x0000A22C012C396C AS DateTime), 111, 6, 4, CAST(0x89370B00 AS Date), N'reduced', N'Emergency Dental Care', 120.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (79, 245.5500, CAST(0x0000A22C012CDB24 AS DateTime), 112, 8, 4, CAST(0x89370B00 AS Date), N'approved', N'Porch unsafe needs rebuilt', 245.5500)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (80, 400.0000, CAST(0x0000A22C012DD394 AS DateTime), 113, 2, 4, CAST(0x1C360B00 AS Date), N'approved', N'Because of illness I missed a few days of work and can''t make the rent payment this month', 400.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (81, 324.5500, CAST(0x0000A23000EBCA1C AS DateTime), 116, 4, 4, CAST(0x8C370B00 AS Date), N'approved', N'Need to rent a car to go to my uncle''s funeral', 324.5500)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (82, 400.9000, CAST(0x0000A23000EC87F4 AS DateTime), 117, 5, 4, CAST(0x8C370B00 AS Date), N'approved', N'Need x-rays for possible cancer', 400.9000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (83, 476.9900, CAST(0x0000A23000ED61EC AS DateTime), 118, 8, 4, CAST(0x8C370B00 AS Date), N'approved', N'Need to replace broken front windows', 476.9900)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (84, 285.7700, CAST(0x0000A23000EE0D04 AS DateTime), 119, 8, 4, CAST(0x8C370B00 AS Date), N'Reduced', N'I need a mower to cut my lawn because of city ordinance', 175.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (85, 175.0000, CAST(0x0000A23000EED310 AS DateTime), 120, 10, 4, CAST(0x8C370B00 AS Date), N'denied', N'Need to replace a very long, very rare scarf', 0.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (86, 78.9000, CAST(0x0000A23600D1DEF4 AS DateTime), 123, 4, 4, CAST(0x93370B00 AS Date), N'approved', N'Need a monthly bus pass', 78.9000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (87, 250.0000, CAST(0x0000A23600D29F24 AS DateTime), 124, 3, 4, CAST(0x93370B00 AS Date), N'approved', N'Need childcare while starting new job', 250.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (88, 540.0000, CAST(0x0000A23600D34460 AS DateTime), 125, 9, 4, CAST(0x93370B00 AS Date), N'approved', N'need money for retraining for job hunt', 540.0000)
GO
INSERT [dbo].[ServiceGrant] ([GrantKey], [GrantAmount], [GrantDate], [PersonKey], [ServiceKey], [EmployeeKey], [GrantReviewDate], [GrantApprovalStatus], [GrantNeedExplanation], [GrantAllocation]) VALUES (89, 400.0000, CAST(0x0000A23600D3F428 AS DateTime), 126, 9, 4, CAST(0x93370B00 AS Date), N'approved', N'Shortfall in making my tuition', 400.0000)
GO
SET IDENTITY_INSERT [dbo].[ServiceGrant] OFF
GO
ALTER TABLE [dbo].[Donation]  WITH CHECK ADD FOREIGN KEY([EmployeeKey])
REFERENCES [dbo].[Employee] ([EmployeeKey])
GO
ALTER TABLE [dbo].[Donation]  WITH CHECK ADD  CONSTRAINT [FK__Donation__Person__5CD6CB2B] FOREIGN KEY([PersonKey])
REFERENCES [dbo].[Person] ([PersonKey])
GO
ALTER TABLE [dbo].[Donation] CHECK CONSTRAINT [FK__Donation__Person__5CD6CB2B]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK__Employee__Person__1B0907CE] FOREIGN KEY([PersonKey])
REFERENCES [dbo].[Person] ([PersonKey])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK__Employee__Person__1B0907CE]
GO
ALTER TABLE [dbo].[EmployeeJobTitle]  WITH CHECK ADD  CONSTRAINT [FK__EmployeeJ__JobTi__75A278F5] FOREIGN KEY([EmployeeKey])
REFERENCES [dbo].[Employee] ([EmployeeKey])
GO
ALTER TABLE [dbo].[EmployeeJobTitle] CHECK CONSTRAINT [FK__EmployeeJ__JobTi__75A278F5]
GO
ALTER TABLE [dbo].[EmployeeJobTitle]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeJobTitle_Jobtitle] FOREIGN KEY([JobTitleKey])
REFERENCES [dbo].[Jobtitle] ([JobTitleKey])
GO
ALTER TABLE [dbo].[EmployeeJobTitle] CHECK CONSTRAINT [FK_EmployeeJobTitle_Jobtitle]
GO
ALTER TABLE [dbo].[GrantReview]  WITH CHECK ADD  CONSTRAINT [fk_EmployeeReview] FOREIGN KEY([EmployeeKey])
REFERENCES [dbo].[Employee] ([EmployeeKey])
GO
ALTER TABLE [dbo].[GrantReview] CHECK CONSTRAINT [fk_EmployeeReview]
GO
ALTER TABLE [dbo].[GrantReview]  WITH CHECK ADD  CONSTRAINT [fk_Grant] FOREIGN KEY([GrantKey])
REFERENCES [dbo].[ServiceGrant] ([GrantKey])
GO
ALTER TABLE [dbo].[GrantReview] CHECK CONSTRAINT [fk_Grant]
GO
ALTER TABLE [dbo].[PersonAddress]  WITH CHECK ADD  CONSTRAINT [FK__PersonAdd__Perso__1273C1CD] FOREIGN KEY([PersonKey])
REFERENCES [dbo].[Person] ([PersonKey])
GO
ALTER TABLE [dbo].[PersonAddress] CHECK CONSTRAINT [FK__PersonAdd__Perso__1273C1CD]
GO
ALTER TABLE [dbo].[PersonContact]  WITH CHECK ADD FOREIGN KEY([ContactTypeKey])
REFERENCES [dbo].[ContactType] ([ContactTypeKey])
GO
ALTER TABLE [dbo].[PersonContact]  WITH CHECK ADD  CONSTRAINT [FK__PersonCon__Perso__173876EA] FOREIGN KEY([PersonKey])
REFERENCES [dbo].[Person] ([PersonKey])
GO
ALTER TABLE [dbo].[PersonContact] CHECK CONSTRAINT [FK__PersonCon__Perso__173876EA]
GO
ALTER TABLE [dbo].[ServiceGrant]  WITH CHECK ADD FOREIGN KEY([EmployeeKey])
REFERENCES [dbo].[Employee] ([EmployeeKey])
GO
ALTER TABLE [dbo].[ServiceGrant]  WITH CHECK ADD  CONSTRAINT [FK__ServiceGr__Perso__239E4DCF] FOREIGN KEY([PersonKey])
REFERENCES [dbo].[Person] ([PersonKey])
GO
ALTER TABLE [dbo].[ServiceGrant] CHECK CONSTRAINT [FK__ServiceGr__Perso__239E4DCF]
GO
ALTER TABLE [dbo].[ServiceGrant]  WITH CHECK ADD FOREIGN KEY([ServiceKey])
REFERENCES [dbo].[CommunityService] ([ServiceKey])
GO
USE [master]
GO
ALTER DATABASE [CommunityAssist] SET  READ_WRITE 
GO