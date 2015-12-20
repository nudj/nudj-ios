//
// Autogenerated by Laurine - by Jiri Trecak ( http://jiritrecak.com, @jiritrecak )
// Do not change this file manually!
//


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Imports

import Foundation


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Extensions

private extension String {

    var localized: String {

        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }

    func localizedWithComment(comment:String) -> String {

        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Localizations


public struct Localizations {


    public struct Jobs {

    
        public struct Salary {

                    /// Base translation: Salary: %@
            public static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.salary.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        public struct Bonus {

                    /// Base translation: Referral Bonus: %@
            public static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.bonus.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        public struct Location {

                    /// Base translation: Location: %@
            public static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.location.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        public struct Delete {

        
            public struct Error {

                            /// Base translation: Error
                public static var Title : String = "jobs.delete.error.title".localized

                /// Base translation: There was an error deleting this job.
                public static var Body : String = "jobs.delete.error.body".localized

            }

            public struct Alert {

                            /// Base translation: Delete job
                public static var Title : String = "jobs.delete.alert.title".localized

                /// Base translation: Are you sure you want to delete this job?
                public static var Body : String = "jobs.delete.alert.body".localized

            }
        }

        public struct Update {

        
            public struct Error {

                            /// Base translation: Failed to update
                public static var Title : String = "jobs.update.error.title".localized

                /// Base translation: There was an error updating the job details.
                public static var Body : String = "jobs.update.error.body".localized

            }
        }

        public struct Button {

                    /// Base translation: Ask for Referral
            public static var AskForReferral : String = "jobs.button.ask-for-referral".localized

            /// Base translation: Edit
            public static var Edit : String = "jobs.button.edit".localized

            /// Base translation: INTERESTED
            public static var Interested : String = "jobs.button.interested".localized

            /// Base translation: Saved
            public static var Saved : String = "jobs.button.saved".localized

            /// Base translation: Save
            public static var Save : String = "jobs.button.save".localized

        }

        public struct Validation {

        
            public struct Error {

                            /// Base translation: Missing information
                public static var Title : String = "jobs.validation.error.title".localized

                /// Base translation: Please fill in the fields marked with *
                public static var Body : String = "jobs.validation.error.body".localized

            }

            public struct Required {

                            /// Base translation: %@ (Required)
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("jobs.validation.required.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        public struct Employer {

                    /// Base translation: Employer: %@
            public static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.employer.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        public struct Interested {

        
            public struct Alert {

                            /// Base translation: Are you sure?
                public static var Title : String = "jobs.interested.alert.title".localized

                /// Base translation: This will send a notification to the Hirer that you are interested in this position.
                public static var Body : String = "jobs.interested.alert.body".localized

            }

            public struct Confirmation {

                            /// Base translation: The hirer has been notified.
                public static var Body : String = "jobs.interested.confirmation.body".localized

            }
        }

        public struct Add {

        
            public struct Button {

                            /// Base translation: Edit Job
                public static var Edit : String = "jobs.add.button.edit".localized

                /// Base translation: Update
                public static var Update : String = "jobs.add.button.update".localized

            }
        }
    }

    public struct Profile {

    
        public struct ImageSource {

                    /// Base translation: Camera
            public static var Camera : String = "profile.image-source.camera".localized

            /// Base translation: Library
            public static var Library : String = "profile.image-source.library".localized

        }

        public struct New {

                    /// Base translation: Choose Image Source
            public static var ImageSource : String = "profile.new.image-source".localized

        }

        public struct Facebook {

        
            public struct Failed {

                            /// Base translation: Facebook was not connected.
                public static var Title : String = "profile.facebook.failed.title".localized

            }
        }
    }

    public struct Phone {

    
        public struct Unavailable {

                    /// Base translation: Phone unavailable
            public static var Title : String = "phone.unavailable.title".localized

            /// Base translation: This device cannot make phone calls.
            public static var Body : String = "phone.unavailable.body".localized

        }
    }

    public struct Login {

    
        public struct PhoneNumber {

                    /// Base translation: You must supply a phone number to log in.
            public static var Required : String = "login.phone-number.required".localized

        }
    }

    public struct Server {

    
        public struct Error {

                    /// Base translation: There was an unexpected error communicating with the server.
            public static var Unknown : String = "server.error.unknown".localized

        }
    }

    public struct Settings {

    
        public struct Title {

                    /// Base translation: Archived Chats
            public static var Chats : String = "settings.title.chats".localized

            /// Base translation: Your Status
            public static var Status : String = "settings.title.status".localized

            /// Base translation: Saved Jobs
            public static var SavedJobs : String = "settings.title.saved-jobs".localized

            /// Base translation: Privacy Policy
            public static var Privacy : String = "settings.title.privacy".localized

            /// Base translation: Send Feedback
            public static var Feedback : String = "settings.title.feedback".localized

            /// Base translation: Facebook
            public static var Facebook : String = "settings.title.facebook".localized

            /// Base translation: Posted Jobs
            public static var PostedJobs : String = "settings.title.posted-jobs".localized

            /// Base translation: Your Profile
            public static var Profile : String = "settings.title.profile".localized

            /// Base translation: Delete Your Account
            public static var DeleteAccount : String = "settings.title.delete-account".localized

            /// Base translation: Terms of Use
            public static var Terms : String = "settings.title.terms".localized

        }

        public struct Facebook {

        
            public struct Connected {

                            /// Base translation: Facebook Connected
                public static var Title : String = "settings.facebook.connected.title".localized

                /// Base translation: You have successfully connected your Facebook account.
                public static var Body : String = "settings.facebook.connected.body".localized

            }

            public struct Disconnected {

                            /// Base translation: Facebook Disconnected
                public static var Title : String = "settings.facebook.disconnected.title".localized

                /// Base translation: You have successfully disconnected your Facebook account.
                public static var Body : String = "settings.facebook.disconnected.body".localized

            }
        }

        public struct Disconnect {

                    /// Base translation: Disconnect
            public static var Button : String = "settings.disconnect.button".localized


            public struct Title {

                            /// Base translation: Disconnect %@
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("settings.disconnect.title.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

                /// Base translation: Are you sure you want to disconnect %@?
                public static func Body(value1 : String) -> String {
                    return String(format: NSLocalizedString("settings.disconnect.title.body", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        public struct Delete {

                    /// Base translation: Delete Account
            public static var Title : String = "settings.delete.title".localized

            /// Base translation: Delete Account
            public static var Button : String = "settings.delete.button".localized

            /// Base translation: Are you sure you want to permanently delete your account information, including jobs and chats?
            public static var Body : String = "settings.delete.body".localized

        }
    }

    public struct Notification {

    
        public struct Button {

                    /// Base translation: Message
            public static var Message : String = "notification.button.message".localized

            /// Base translation: Details
            public static var Details : String = "notification.button.details".localized

            /// Base translation: NUDJ
            public static var Nudj : String = "notification.button.nudj".localized

        }
    }

    public struct General {

            /// Base translation: Pull to refresh
        public static var PullToRefresh : String = "general.pull-to-refresh".localized


        public struct Button {

                    /// Base translation: Done
            public static var Done : String = "general.button.done".localized

            /// Base translation: Not Now
            public static var Notnow : String = "general.button.notnow".localized

            /// Base translation: Send
            public static var Send : String = "general.button.send".localized

            /// Base translation: Cancel
            public static var Cancel : String = "general.button.cancel".localized

            /// Base translation: OK
            public static var Ok : String = "general.button.ok".localized

            /// Base translation: Delete
            public static var Delete : String = "general.button.delete".localized

        }
    }

    public struct Userstatus {

            /// Base translation: Do Not Disturb
        public static var DoNotDisturb : String = "userstatus.do-not-disturb".localized

        /// Base translation: Hiring
        public static var Hiring : String = "userstatus.hiring".localized

        /// Base translation: SELECT STATUS
        public static var Unknown : String = "userstatus.unknown".localized

        /// Base translation: Available
        public static var Available : String = "userstatus.available".localized

    }

    public struct Referral {

            /// Base translation: Refer Someone
        public static var Title : String = "referral.title".localized


        public struct Message {

                    /// Base translation: Enter your personalised message
            public static var Placeholder : String = "referral.message.placeholder".localized

        }

        public struct Nudge {

        
            public struct Sent {

            
                public struct Plural {

                                    /// Base translation: You have successfully nudged %@ and %d others.
                    public static func Format(value1 : String, _ value2 : Int) -> String {
                        return String(format: NSLocalizedString("referral.nudge.sent.plural.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1, value2)
                    }

                }

                public struct Singular {

                                    /// Base translation: You have successfully nudged %@.
                    public static func Format(value1 : String) -> String {
                        return String(format: NSLocalizedString("referral.nudge.sent.singular.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                    }

                }
            }
        }

        public struct Ask {

                    /// Base translation: Ask
            public static var Button : String = "referral.ask.button".localized

            /// Base translation: Select contacts to ask for referrals for the %@ position.
            public static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("referral.ask.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }


            public struct Sent {

            
                public struct Singular {

                                    /// Base translation: You have successfully asked %@ for a referral.
                    public static func Format(value1 : String) -> String {
                        return String(format: NSLocalizedString("referral.ask.sent.singular.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                    }

                }

                public struct Plural {

                                    /// Base translation: You have successfully asked %@ and %d others for a referral.
                    public static func Format(value1 : String, _ value2 : Int) -> String {
                        return String(format: NSLocalizedString("referral.ask.sent.plural.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1, value2)
                    }

                }
            }
        }
    }

    public struct Invitation {

    
        public struct Successful {

                    /// Base translation: Invitation Sent
            public static var Title : String = "invitation.successful.title".localized


            public struct Body {

                            /// Base translation: %@ has been invited.
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("invitation.successful.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        public struct Failed {

                    /// Base translation: Invitation Failed
            public static var Title : String = "invitation.failed.title".localized


            public struct Body {

                            /// Base translation: There was a problem inviting %@.
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("invitation.failed.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        public struct Send {

                    /// Base translation: Invite
            public static var Button : String = "invitation.send.button".localized

            /// Base translation: Invite Contact
            public static var Title : String = "invitation.send.title".localized


            public struct Body {

                            /// Base translation: Would you like to tell %@ about Nudj?
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("invitation.send.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }
    }

    public struct Sms {

    
        public struct Failed {

                    /// Base translation: Text message failed
            public static var Title : String = "sms.failed.title".localized

            /// Base translation: Your message could not be sent. Please try again.
            public static var Body : String = "sms.failed.body".localized

        }

        public struct Unavailable {

                    /// Base translation: Text messages unavailable
            public static var Title : String = "sms.unavailable.title".localized

            /// Base translation: This device cannot send text messages.
            public static var Body : String = "sms.unavailable.body".localized

        }
    }

    public struct Verification {

    
        public struct Code {

                    /// Base translation: That verification code is invalid.
            public static var Invalid : String = "verification.code.invalid".localized

            /// Base translation: There was an error in code verification, please try again.
            public static var Error : String = "verification.code.error".localized


            public struct Alert {

                            /// Base translation: Your verification code is %@.
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("verification.code.alert.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }
    }

    public struct Account {

    
        public struct Delete {

        
            public struct Error {

                            /// Base translation: Error Deleting Account
                public static var Title : String = "account.delete.error.title".localized

                /// Base translation: There was an error deleting your account. Please try again.
                public static var Body : String = "account.delete.error.body".localized

            }
        }
    }

    public struct Country {

    
        public struct Default {

                    /// Base translation: United Kingdom
            public static var Name : String = "country.default.name".localized

            /// Base translation: +44
            public static var Dialcode : String = "country.default.dialcode".localized

            /// Base translation: GB
            public static var Code : String = "country.default.code".localized

        }

        public struct Choose {

                    /// Base translation: Choose your country
            public static var Label : String = "country.choose.label".localized

        }
    }

    public struct Contacts {

    
        public struct Access {

        
            public struct Request {

                            /// Base translation: Nudj would like to access your address book
                public static var Title : String = "contacts.access.request.title".localized

                /// Base translation: This will let you send texts and job referrals to anyone in your address book.Nudj will never send messages without your explicit permission.
                public static var Body : String = "contacts.access.request.body".localized

            }
        }
    }

    public struct Chat {

    
        public struct Archived {

                    /// Base translation: Chat Archived
            public static var Title : String = "chat.archived.title".localized

            /// Base translation: Archived chats are stored in Settings.
            public static var Body : String = "chat.archived.body".localized

        }

        public struct Restored {

                    /// Base translation: Chat Restored
            public static var Title : String = "chat.restored.title".localized

        }

        public struct Connection {

        
            public struct Error {

                            /// Base translation: Error
                public static var Title : String = "chat.connection.error.title".localized


                public struct Body {

                                    /// Base translation: Can't connect to the chat server. %@
                    public static func Format(value1 : String) -> String {
                        return String(format: NSLocalizedString("chat.connection.error.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                    }

                }
            }
        }

        public struct Contact {

        
            public struct Success {

                            /// Base translation: You have successfully contacted %@
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("chat.contact.success.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }

            public struct Send {

                            /// Base translation: Contact %@
                public static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("chat.contact.send.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }
    }
}