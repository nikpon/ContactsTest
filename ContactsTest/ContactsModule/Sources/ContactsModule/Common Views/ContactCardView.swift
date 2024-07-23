//
//  ContactCardView.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 06.07.2024.
//

import SwiftUI
import Models

struct ContactCardView: View {
    private let contact: Contact
    private let displayMode: DisplayMode
    
    init(contact: Contact, displayMode: DisplayMode) {
        self.contact = contact
        self.displayMode = displayMode
    }
    
    var body: some View {
        HStack {
            avatarView
            
            VStack(alignment: .leading) {
                switch displayMode {
                case .standard: contactInfoView(emphasisRanges: nil)
                case .emphasized(let contactMatchRanges): contactInfoView(emphasisRanges: contactMatchRanges)
                }
            }
            .frame(height: 60)
        }
    }
    
    @ViewBuilder
    private var avatarView: some View {
        if let avatarData = contact.avatarData, let uiimage = UIImage(data: avatarData) {
            Image(uiImage: uiimage)
                .resizable()
                .frame(width: 40, height: 40)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
        } else {
            Circle()
                .frame(width: 40, height: 40)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray)
                .overlay {
                    Text((contact.givenName.first.map { String($0) } ?? "") + (contact.familyName.first.map { String($0) } ?? ""))
                        .foregroundStyle(Color.white)
                }
        }
    }
    
    private func contactInfoView(emphasisRanges: ContactMatchRanges?) -> some View {
        Group {
            if contact.fullName.trimmingCharacters(in: .whitespaces).isEmpty == false {
                fullNameText(emphasisRanges: emphasisRanges)
                    .lineLimit(2)
            }
            
            if let phoneNumber = contact.phoneNumber {
                phoneNumberText(phoneNumber, emphasisRanges: emphasisRanges)
            }
        }
    }
    
    private func fullNameText(emphasisRanges: ContactMatchRanges?) -> Text {
        if let emphasisRanges {
            return Text(emphasizedAttributedFullName(contact: contact, ranges: emphasisRanges))
        } else {
            return Text(contact.fullName)
        }
    }
    
    private func phoneNumberText(_ phoneNumber: String, emphasisRanges: ContactMatchRanges?) -> Text {
        if let phoneNumberRange = emphasisRanges?.phoneNumberRange {
            return Text(emphasizedAttributedString(text: phoneNumber, range: phoneNumberRange))
        } else {
            return Text(phoneNumber)
        }
    }
    
    // MARK: Helper methods
    private func emphasizedAttributedFullName(contact: Contact, ranges: ContactMatchRanges?) -> AttributedString {
        // TODO: given name not always first?
        return if let fullNameRange = ranges?.fullNameRange {
            emphasizedAttributedString(text: contact.fullName, range: fullNameRange)
        } else if !contact.givenName.isEmpty, let givenNameRange = ranges?.givenNameRange {
            emphasizedAttributedString(text: contact.givenName, range: givenNameRange) + AttributedString(!contact.familyName.isEmpty ? contact.familyName + " " : "")
        } else if !contact.familyName.isEmpty, let familyNameRange = ranges?.familyNameRange {
            AttributedString(!contact.givenName.isEmpty ? contact.givenName + " " : "") + emphasizedAttributedString(text: contact.familyName, range: familyNameRange)
        } else {
            AttributedString(contact.fullName)
        }
    }
    
    private func emphasizedAttributedString(text: String, range: Range<String.Index>) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let lowerBound = AttributedString.Index(range.lowerBound, within: attributedString), let upperBound = AttributedString.Index(range.upperBound, within: attributedString) {
            attributedString[lowerBound..<upperBound].foundation.inlinePresentationIntent = .stronglyEmphasized
        }
        
        return attributedString
    }
}

// MARK: - DisplayMode
extension ContactCardView {
    enum DisplayMode {
        case standard
        case emphasized(contactMatchRanges: ContactMatchRanges)
    }
}
