/// Centralized app-wide constants.
class AppConstants {
  AppConstants._();

  /// The display name of the application.
  static const String appName = 'MySched';

  /// Default notification lead time in minutes.
  static const int defaultLeadMinutes = 5;

  /// Default snooze duration in minutes.
  static const int defaultSnoozeMinutes = 5;

  /// SharedPreferences keys for settings.
  static const String keyClassAlarms = 'class_alarms';
  static const String keyAppNotifs = 'app_notifs';
  static const String keyQuietWeek = 'quiet_week_enabled';
  static const String keyVerboseLogging = 'alarm_verbose_logging';
  static const String keyLeadMinutes = 'notifLeadMinutes';
  static const String keySnoozeMinutes = 'snoozeMinutes';
  static const String keyAlarmVolume = 'alarm_volume';
  static const String keyAlarmVibration = 'alarm_vibration';
  static const String keyAlarmRingtone = 'alarm_ringtone';
  static const String keyUse24HourFormat = 'use_24_hour_format';
  static const String keyWeekStartDay = 'week_start_day';
  static const String keyHapticFeedback = 'haptic_feedback';
  static const String keyReminderLeadMinutes = 'reminder_lead_minutes';
  static const String keyDndEnabled = 'dnd_enabled';
  static const String keyDndStartTime = 'dnd_start_time';
  static const String keyDndEndTime = 'dnd_end_time';
  static const String keyAutoRefreshMinutes = 'auto_refresh_minutes';

  /// Default alarm settings
  static const int defaultAlarmVolume = 80;
  static const bool defaultAlarmVibration = true;
  static const String defaultAlarmRingtone = 'default';

  /// Default new settings
  static const String defaultWeekStartDay = 'monday';
  static const bool defaultHapticFeedback = true;
  static const int defaultReminderLeadMinutes = 0;
  static const bool defaultDndEnabled = false;
  static const String defaultDndStartTime = '22:00';
  static const String defaultDndEndTime = '07:00';
  static const int defaultAutoRefreshMinutes = 30;

  // ─────────────────────────────────────────────────────────────────────────
  // Validation Constants (non-UI)
  // ─────────────────────────────────────────────────────────────────────────

  /// Minimum password length for registration
  static const int minPasswordLength = 8;

  /// Minimum password length for login (legacy accounts)
  static const int minPasswordLengthLogin = 6;

  // ─────────────────────────────────────────────────────────────────────────
  // Image Upload Constants (non-UI)
  // ─────────────────────────────────────────────────────────────────────────

  /// Maximum width for uploaded images
  static const double imageMaxWidth = 1200;

  /// JPEG quality for uploaded images (0-100)
  static const int imageQuality = 85;

  // ─────────────────────────────────────────────────────────────────────────
  // Welcome Screen Labels
  // ─────────────────────────────────────────────────────────────────────────

  /// Welcome screen headline
  static const String welcomeHeadline = 'You keep forgetting.\nWe won\'t.';

  /// Welcome screen subtitle
  static const String welcomeSubtitle =
      'Scan your class card, get your schedule,\nand never miss a class.';

  /// Log in with email button label
  static const String loginWithEmailLabel = 'Log in with email';

  /// Continue with Google button label
  static const String continueWithGoogleLabel = 'Continue with Google';

  /// Or divider text
  static const String orDividerText = 'or';

  /// Terms agreement prefix
  static const String termsAgreementPrefix = 'By continuing, you agree to MySched';

  /// Terms & Conditions link text
  static const String termsLinkText = 'Terms & Conditions';

  /// Privacy Policy link text
  static const String privacyLinkText = 'Privacy Policy';

  /// And conjunction text
  static const String andText = ' and ';

  /// Welcome illustration asset path
  static const String welcomeIllustrationAsset = 'assets/images/avatar.png';

  /// Welcome illustration dark mode asset path
  static const String welcomeIllustrationDarkAsset = 'assets/images/avatar-darkmode.png';

  /// Login illustration asset path
  static const String loginIllustrationAsset = 'assets/images/ec-notification.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Legal Content
  // ─────────────────────────────────────────────────────────────────────────

  /// Terms & Conditions content
  static const String termsAndConditionsContent = '''
TERMS AND CONDITIONS OF USE

Effective Date: December 01, 2025

Welcome to MySched. These Terms and Conditions ("Terms") govern your access to and use of the MySched mobile application ("Application," "App," or "Service"). By downloading, installing, or using MySched, you acknowledge that you have read, understood, and agree to be bound by these Terms in their entirety. If you do not agree with any provision of these Terms, you must discontinue use of the Application immediately.

SECTION 1: ABOUT THE APPLICATION

MySched is an Optical Character Recognition (OCR)-based mobile application developed specifically for students of the College of Computer Studies and Information Technology (CCSIT) at Immaculate Conception I-College of Arts and Technology (ICI), located in Sta. Maria, Bulacan, Philippines. The Application is designed to automate the process of class schedule generation and provide timely notification reminders to help students manage their academic responsibilities more effectively.

The Application utilizes the following technologies:
• Google ML Kit Text Recognition for optical character recognition and text extraction from student account cards
• Supabase for secure cloud-based data storage, user authentication, and real-time synchronization
• Flutter Local Notifications with timezone support for delivering accurate and timely class reminders

SECTION 2: USER ELIGIBILITY AND ACCOUNT RESPONSIBILITIES

To use MySched, you must be a currently enrolled student at Immaculate Conception I-College of Arts and Technology or an authorized user with valid credentials. By creating an account, you represent and warrant that all information you provide is accurate, complete, and current.

You are solely responsible for:
• Maintaining the confidentiality and security of your account credentials, including your password
• All activities that occur under your account, whether or not authorized by you
• Notifying us immediately of any unauthorized access to or use of your account
• Ensuring that you log out of your account at the end of each session when accessing the Application from a shared or public device

SECTION 3: PERMITTED USE AND RESTRICTIONS

You agree to use the Application solely for lawful purposes and in accordance with these Terms. You are expressly prohibited from:
• Using the Application for any purpose that is illegal, fraudulent, or harmful
• Attempting to gain unauthorized access to any portion of the Application, other users' accounts, or any systems or networks connected to the Application
• Interfering with or disrupting the integrity or performance of the Application or the data contained therein
• Reproducing, duplicating, copying, selling, reselling, or exploiting any portion of the Application without express written permission
• Using any automated means, including bots, scrapers, or data mining tools, to access the Application

SECTION 4: DATA COLLECTION AND USAGE

By using MySched, you consent to the collection and processing of certain information necessary for the Application to function properly. This includes, but is not limited to:
• Personal identification information such as your name, email address, and student identification number
• Academic schedule data extracted from your student account card through OCR technology
• Device information and usage analytics to improve Application performance

All data collected is processed in accordance with our Privacy Policy and the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines.

SECTION 5: INTELLECTUAL PROPERTY RIGHTS

All content, features, functionality, design elements, source code, and documentation associated with MySched are the exclusive property of the developers and are protected by applicable copyright, trademark, and other intellectual property laws. This Application was developed as part of an academic thesis project at Immaculate Conception I-College of Arts and Technology.

You are granted a limited, non-exclusive, non-transferable, revocable license to use the Application for personal, non-commercial purposes in accordance with these Terms.

SECTION 6: DISCLAIMER OF WARRANTIES

THE APPLICATION IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, WE DISCLAIM ALL WARRANTIES, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

We do not warrant that:
• The Application will be uninterrupted, secure, or error-free
• The results obtained from using the Application will be accurate or reliable
• Any defects in the Application will be corrected

SECTION 7: LIMITATION OF LIABILITY

IN NO EVENT SHALL THE DEVELOPERS, THEIR AFFILIATES, OR THEIR RESPECTIVE OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATED TO YOUR USE OF THE APPLICATION, INCLUDING BUT NOT LIMITED TO MISSED CLASSES, SCHEDULING CONFLICTS, OR ANY OTHER DAMAGES ARISING FROM RELIANCE ON THE APPLICATION.

SECTION 8: MODIFICATIONS TO TERMS

We reserve the right to modify, amend, or update these Terms at any time without prior notice. Any changes will be effective immediately upon posting the revised Terms within the Application. Your continued use of the Application following the posting of revised Terms constitutes your acceptance of such changes.

SECTION 9: GOVERNING LAW

These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines, without regard to its conflict of law provisions.

SECTION 10: CONTACT INFORMATION

If you have any questions, concerns, or feedback regarding these Terms and Conditions, please contact us through the in-app feedback feature.

Developed by Neil T. Daquioag and Raymond A. Zabiaga
Bachelor of Science in Computer Science
Immaculate Conception I-College of Arts and Technology
November 2025
''';

  /// Privacy Policy content
  static const String privacyPolicyContent = '''
PRIVACY POLICY

Effective Date: December 01, 2025

Immaculate Conception I-College of Arts and Technology and the developers of MySched ("we," "us," or "our") are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application MySched ("Application"). This policy is designed to comply with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines and other applicable data protection regulations.

By using the Application, you consent to the data practices described in this Privacy Policy. If you do not agree with the terms of this Privacy Policy, please do not access or use the Application.

SECTION 1: INFORMATION WE COLLECT

We collect information that you provide directly to us and information that is collected automatically when you use the Application.

1.1 Information You Provide
• Account Registration Information: When you create an account, we collect your full name, email address, and student identification number.
• Profile Information: Any additional information you choose to add to your profile, such as your course, year level, or section.
• Schedule Data: Class schedule information extracted from your student account card through our OCR scanning feature, including subject names, class times, room assignments, and instructor names.

1.2 Information Collected Automatically
• Device Information: We collect information about the device you use to access the Application, including the device model, operating system version, unique device identifiers, and mobile network information.
• Usage Data: We collect information about your interactions with the Application, including features used, pages viewed, and the time and date of your activities.
• Log Data: Our servers automatically record certain log information when you use the Application, which may include your IP address, browser type, and referring/exit pages.

SECTION 2: HOW WE USE YOUR INFORMATION

We use the information we collect for the following purposes:

2.1 To Provide and Maintain Our Services
• To create and manage your user account
• To generate your personalized class schedule based on scanned student account card data
• To synchronize your schedule data across devices in real-time
• To send you timely class reminders and notifications

2.2 To Improve Our Services
• To understand how users interact with the Application and identify areas for improvement
• To develop new features and functionality based on user needs
• To perform data analysis and research to enhance the user experience

2.3 To Communicate With You
• To send you important notices regarding your account or changes to our policies
• To respond to your inquiries, comments, or feedback
• To provide customer support and technical assistance

SECTION 3: DATA STORAGE AND SECURITY

We take the security of your personal information seriously and implement appropriate technical and organizational measures to protect your data against unauthorized access, alteration, disclosure, or destruction.

3.1 Data Storage
• All personal information and schedule data are stored securely in Supabase, a cloud-based database platform with enterprise-grade security features.
• Data is encrypted both in transit and at rest using industry-standard encryption protocols.
• Access to your data is restricted to authenticated users only through secure authentication mechanisms.

3.2 Security Measures
• We implement access controls to ensure that only authorized personnel can access personal information.
• Regular security assessments and updates are performed to maintain the integrity of our systems.
• Personal identifiers are handled with strict confidentiality in accordance with applicable data protection laws.

SECTION 4: DATA SHARING AND DISCLOSURE

We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:

4.1 With Your Consent
We may share your information with third parties when you have given us explicit consent to do so.

4.2 For Legal Compliance
We may disclose your information if required to do so by law or in response to valid requests by public authorities, such as a court order or government agency.

4.3 To Protect Rights and Safety
We may disclose your information when we believe in good faith that disclosure is necessary to protect our rights, protect your safety or the safety of others, investigate fraud, or respond to a government request.

SECTION 5: YOUR RIGHTS AND CHOICES

Under the Data Privacy Act of 2012 and other applicable laws, you have certain rights regarding your personal information:

5.1 Right to Access
You have the right to request a copy of the personal information we hold about you.

5.2 Right to Correction
You have the right to request that we correct any inaccurate or incomplete personal information.

5.3 Right to Erasure
You have the right to request the deletion of your personal information and account data. Upon account deletion, your data will be permanently removed within thirty (30) days.

5.4 Right to Data Portability
You have the right to request a copy of your schedule data in a commonly used, machine-readable format.

5.5 Right to Object
You have the right to object to the processing of your personal information in certain circumstances.

SECTION 6: DATA RETENTION

We retain your personal information for as long as your account is active or as needed to provide you with our services. If you choose to delete your account, we will delete your personal information within thirty (30) days, except where we are required to retain certain information for legal, regulatory, or legitimate business purposes.

SECTION 7: THIRD-PARTY SERVICES

Our Application integrates with the following third-party services:

7.1 Google Sign-In
If you choose to sign in using your Google account, your use of Google Sign-In is subject to Google's Privacy Policy. We receive only the information you authorize Google to share with us.

7.2 Google ML Kit
We use Google ML Kit for on-device optical character recognition. Text recognition is performed locally on your device, and scanned images are not transmitted to Google servers.

7.3 Supabase
We use Supabase as our cloud database provider for data storage and user authentication. Supabase maintains enterprise-level security standards and complies with industry best practices for data protection.

SECTION 8: CHILDREN'S PRIVACY

MySched is intended for use by college students and is not directed at children under the age of thirteen (13). We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information promptly.

SECTION 9: CHANGES TO THIS PRIVACY POLICY

We may update this Privacy Policy from time to time to reflect changes in our practices or for other operational, legal, or regulatory reasons. We will notify you of any material changes by posting the updated Privacy Policy within the Application and updating the "Effective Date" at the top of this policy. Your continued use of the Application after any changes constitutes your acceptance of the revised Privacy Policy.

SECTION 10: CONTACT US

If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us through the in-app feedback feature. We are committed to addressing your inquiries and resolving any issues in a timely manner.

Developed at Immaculate Conception I-College of Arts and Technology
Sta. Maria, Bulacan, Philippines
''';
}


