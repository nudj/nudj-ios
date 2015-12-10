//
// Autogenerated by Laurine - by Jiri Trecak ( http://jiritrecak.com, @jiritrecak )
// Do not change this file manually!
//
// 2015-12-10 at 1:20 pm
//


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Imports

import Foundation


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Extensions

extension String {

    var localized: String {

        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }

    func localizedWithComment(comment:String) -> String {

        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Localizations


struct Localizations {


    struct Jobs {

    
        struct Salary {

                    /// Base translation: Salary: %@
            static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.salary.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        struct Bonus {

                    /// Base translation: Referral Bonus: %@
            static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.bonus.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        struct Location {

                    /// Base translation: Location: %@
            static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.location.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        struct Delete {

        
            struct Error {

                            /// Base translation: Error
                static var Title : String = "jobs.delete.error.title".localized

                /// Base translation: There was an error deleting this job.
                static var Body : String = "jobs.delete.error.body".localized

            }

            struct Alert {

                            /// Base translation: Delete job
                static var Title : String = "jobs.delete.alert.title".localized

                /// Base translation: Are you sure you want to delete this job?
                static var Body : String = "jobs.delete.alert.body".localized

            }
        }

        struct Update {

        
            struct Error {

                            /// Base translation: Failed to update
                static var Title : String = "jobs.update.error.title".localized

                /// Base translation: There was an error updating the job details.
                static var Body : String = "jobs.update.error.body".localized

            }
        }

        struct Button {

                    /// Base translation: Ask for Referral
            static var AskForReferral : String = "jobs.button.ask-for-referral".localized

            /// Base translation: Edit
            static var Edit : String = "jobs.button.edit".localized

            /// Base translation: INTERESTED
            static var Interested : String = "jobs.button.interested".localized

            /// Base translation: Saved
            static var Saved : String = "jobs.button.saved".localized

            /// Base translation: Save
            static var Save : String = "jobs.button.save".localized

        }

        struct Validation {

        
            struct Error {

                            /// Base translation: Missing information
                static var Title : String = "jobs.validation.error.title".localized

                /// Base translation: Please fill in the fields marked with *
                static var Body : String = "jobs.validation.error.body".localized

            }

            struct Required {

                            /// Base translation: %@ (Required)
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("jobs.validation.required.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        struct Employer {

                    /// Base translation: Employer: %@
            static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("jobs.employer.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }

        }

        struct Interested {

        
            struct Alert {

                            /// Base translation: Are you sure?
                static var Title : String = "jobs.interested.alert.title".localized

                /// Base translation: This will send a notification to the Hirer that you are interested in this position.
                static var Body : String = "jobs.interested.alert.body".localized

            }

            struct Confirmation {

                            /// Base translation: The hirer has been notified.
                static var Body : String = "jobs.interested.confirmation.body".localized

            }
        }

        struct Add {

        
            struct Button {

                            /// Base translation: Edit Job
                static var Edit : String = "jobs.add.button.edit".localized

                /// Base translation: Update
                static var Update : String = "jobs.add.button.update".localized

            }
        }
    }

    struct Profile {

    
        struct Linkedin {

        
            struct Failed {

                            /// Base translation: LinkedIn was not connected.
                static var Title : String = "profile.linkedin.failed.title".localized

            }
        }

        struct New {

                    /// Base translation: Choose Image Source
            static var ImageSource : String = "profile.new.image-source".localized

        }

        struct Facebook {

        
            struct Failed {

                            /// Base translation: Facebook was not connected.
                static var Title : String = "profile.facebook.failed.title".localized

            }
        }

        struct ImageSource {

                    /// Base translation: Camera
            static var Camera : String = "profile.image-source.camera".localized

            /// Base translation: Library
            static var Library : String = "profile.image-source.library".localized

        }
    }

    struct Phone {

    
        struct Unavailable {

                    /// Base translation: Phone unavailable
            static var Title : String = "phone.unavailable.title".localized

            /// Base translation: This device cannot make phone calls.
            static var Body : String = "phone.unavailable.body".localized

        }
    }

    struct Login {

    
        struct PhoneNumber {

                    /// Base translation: You must supply a phone number to log in.
            static var Required : String = "login.phone-number.required".localized

        }
    }

    struct Server {

    
        struct Error {

                    /// Base translation: There was an unexpected error communicating with the server.
            static var Unknown : String = "server.error.unknown".localized

        }
    }

    struct Settings {

    
        struct Linkedin {

        
            struct Connected {

                            /// Base translation: LinkedIn Connected
                static var Title : String = "settings.linkedin.connected.title".localized

                /// Base translation: You have successfully connected your LinkedIn account.
                static var Body : String = "settings.linkedin.connected.body".localized

            }

            struct Disconnected {

                            /// Base translation: LinkedIn Disconnected
                static var Title : String = "settings.linkedin.disconnected.title".localized

                /// Base translation: You have successfully disconnected your LinkedIn account.
                static var Body : String = "settings.linkedin.disconnected.body".localized

            }
        }

        struct Title {

                    /// Base translation: Archived Chats
            static var Chats : String = "settings.title.chats".localized

            /// Base translation: Your Status
            static var Status : String = "settings.title.status".localized

            /// Base translation: Saved Jobs
            static var SavedJobs : String = "settings.title.saved-jobs".localized

            /// Base translation: Privacy Policy
            static var Privacy : String = "settings.title.privacy".localized

            /// Base translation: Send Feedback
            static var Feedback : String = "settings.title.feedback".localized

            /// Base translation: Facebook
            static var Facebook : String = "settings.title.facebook".localized

            /// Base translation: Posted Jobs
            static var PostedJobs : String = "settings.title.posted-jobs".localized

            /// Base translation: Your Profile
            static var Profile : String = "settings.title.profile".localized

            /// Base translation: Delete Your Account
            static var DeleteAccount : String = "settings.title.delete-account".localized

            /// Base translation: Terms of Use
            static var Terms : String = "settings.title.terms".localized

        }

        struct Facebook {

        
            struct Connected {

                            /// Base translation: Facebook Connected
                static var Title : String = "settings.facebook.connected.title".localized

                /// Base translation: You have successfully connected your Facebook account.
                static var Body : String = "settings.facebook.connected.body".localized

            }

            struct Disconnected {

                            /// Base translation: Facebook Disconnected
                static var Title : String = "settings.facebook.disconnected.title".localized

                /// Base translation: You have successfully disconnected your Facebook account.
                static var Body : String = "settings.facebook.disconnected.body".localized

            }
        }

        struct Disconnect {

                    /// Base translation: Disconnect
            static var Button : String = "settings.disconnect.button".localized


            struct Title {

                            /// Base translation: Disconnect %@
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("settings.disconnect.title.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

                /// Base translation: Are you sure you want to disconnect %@?
                static func Body(value1 : String) -> String {
                    return String(format: NSLocalizedString("settings.disconnect.title.body", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        struct Delete {

                    /// Base translation: Delete Account
            static var Title : String = "settings.delete.title".localized

            /// Base translation: Delete Account
            static var Button : String = "settings.delete.button".localized

            /// Base translation: Are you sure you want to permanently delete your account information, including jobs and chats?
            static var Body : String = "settings.delete.body".localized

        }
    }

    struct Notification {

    
        struct Button {

                    /// Base translation: Message
            static var Message : String = "notification.button.message".localized

            /// Base translation: Details
            static var Details : String = "notification.button.details".localized

            /// Base translation: NUDJ
            static var Nudj : String = "notification.button.nudj".localized

        }
    }

    struct General {

            /// Base translation: Pull to refresh
        static var PullToRefresh : String = "general.pull-to-refresh".localized


        struct Button {

                    /// Base translation: Done
            static var Done : String = "general.button.done".localized

            /// Base translation: Not Now
            static var Notnow : String = "general.button.notnow".localized

            /// Base translation: Send
            static var Send : String = "general.button.send".localized

            /// Base translation: Cancel
            static var Cancel : String = "general.button.cancel".localized

            /// Base translation: OK
            static var Ok : String = "general.button.ok".localized

            /// Base translation: Delete
            static var Delete : String = "general.button.delete".localized

        }
    }

    struct Userstatus {

            /// Base translation: Do Not Disturb
        static var DoNotDisturb : String = "userstatus.do-not-disturb".localized

        /// Base translation: Hiring
        static var Hiring : String = "userstatus.hiring".localized

        /// Base translation: SELECT STATUS
        static var Unknown : String = "userstatus.unknown".localized

        /// Base translation: Available
        static var Available : String = "userstatus.available".localized

    }

    struct Referral {

            /// Base translation: Refer Someone
        static var Title : String = "referral.title".localized


        struct Message {

                    /// Base translation: Enter your personalised message
            static var Placeholder : String = "referral.message.placeholder".localized

        }

        struct Nudge {

        
            struct Sent {

            
                struct Plural {

                                    /// Base translation: You have successfully nudged %@ and %d others.
                    static func Format(value1 : String, _ value2 : Int) -> String {
                        return String(format: NSLocalizedString("referral.nudge.sent.plural.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1, value2)
                    }

                }

                struct Singular {

                                    /// Base translation: You have successfully nudged %@.
                    static func Format(value1 : String) -> String {
                        return String(format: NSLocalizedString("referral.nudge.sent.singular.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                    }

                }
            }
        }

        struct Ask {

                    /// Base translation: Ask
            static var Button : String = "referral.ask.button".localized

            /// Base translation: Select contacts to ask for referrals for the %@ position.
            static func Format(value1 : String) -> String {
                return String(format: NSLocalizedString("referral.ask.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
            }


            struct Sent {

            
                struct Singular {

                                    /// Base translation: You have successfully asked %@ for a referral.
                    static func Format(value1 : String) -> String {
                        return String(format: NSLocalizedString("referral.ask.sent.singular.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                    }

                }

                struct Plural {

                                    /// Base translation: You have successfully asked %@ and %d others for a referral.
                    static func Format(value1 : String, _ value2 : Int) -> String {
                        return String(format: NSLocalizedString("referral.ask.sent.plural.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1, value2)
                    }

                }
            }
        }
    }

    struct Invitation {

    
        struct Successful {

                    /// Base translation: Invitation Sent
            static var Title : String = "invitation.successful.title".localized


            struct Body {

                            /// Base translation: %@ has been invited.
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("invitation.successful.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        struct Failed {

                    /// Base translation: Invitation Failed
            static var Title : String = "invitation.failed.title".localized


            struct Body {

                            /// Base translation: There was a problem inviting %@.
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("invitation.failed.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }

        struct Send {

                    /// Base translation: Invite
            static var Button : String = "invitation.send.button".localized

            /// Base translation: Invite Contact
            static var Title : String = "invitation.send.title".localized


            struct Body {

                            /// Base translation: Would you like to tell %@ about Nudj?
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("invitation.send.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }
    }

    struct Sms {

    
        struct Failed {

                    /// Base translation: Text message failed
            static var Title : String = "sms.failed.title".localized

            /// Base translation: Your message could not be sent. Please try again.
            static var Body : String = "sms.failed.body".localized

        }

        struct Unavailable {

                    /// Base translation: Text messages unavailable
            static var Title : String = "sms.unavailable.title".localized

            /// Base translation: This device cannot send text messages.
            static var Body : String = "sms.unavailable.body".localized

        }
    }

    struct Verification {

    
        struct Code {

                    /// Base translation: That verification code is invalid.
            static var Invalid : String = "verification.code.invalid".localized

            /// Base translation: There was an error in code verification, please try again.
            static var Error : String = "verification.code.error".localized


            struct Alert {

                            /// Base translation: Your verification code is %@.
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("verification.code.alert.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }
    }

    struct Account {

    
        struct Delete {

        
            struct Error {

                            /// Base translation: Error Deleting Account
                static var Title : String = "account.delete.error.title".localized

                /// Base translation: There was an error deleting your account. Please try again.
                static var Body : String = "account.delete.error.body".localized

            }
        }
    }

    struct Country {

    
        struct Default {

                    /// Base translation: United Kingdom
            static var Name : String = "country.default.name".localized

            /// Base translation: +44
            static var Dialcode : String = "country.default.dialcode".localized

            /// Base translation: GB
            static var Code : String = "country.default.code".localized

        }

        struct Choose {

                    /// Base translation: Choose your country
            static var Label : String = "country.choose.label".localized

        }
    }

    struct Contacts {

    
        struct Access {

        
            struct Request {

                            /// Base translation: Nudj would like to access your address book
                static var Title : String = "contacts.access.request.title".localized

                /// Base translation: This will let you send texts and job referrals to anyone in your address book.Nudj will never send messages without your explicit permission.
                static var Body : String = "contacts.access.request.body".localized

            }
        }
    }

    struct Chat {

    
        struct Archived {

                    /// Base translation: Chat Archived
            static var Title : String = "chat.archived.title".localized

            /// Base translation: Archived chats are stored in Settings.
            static var Body : String = "chat.archived.body".localized

        }

        struct Restored {

                    /// Base translation: Chat Restored
            static var Title : String = "chat.restored.title".localized

        }

        struct Connection {

        
            struct Error {

                            /// Base translation: Error
                static var Title : String = "chat.connection.error.title".localized


                struct Body {

                                    /// Base translation: Can't connect to the chat server. %@
                    static func Format(value1 : String) -> String {
                        return String(format: NSLocalizedString("chat.connection.error.body.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                    }

                }
            }
        }

        struct Contact {

        
            struct Success {

                            /// Base translation: You have successfully contacted %@
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("chat.contact.success.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }

            struct Send {

                            /// Base translation: Contact %@
                static func Format(value1 : String) -> String {
                    return String(format: NSLocalizedString("chat.contact.send.format", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), value1)
                }

            }
        }
    }
}