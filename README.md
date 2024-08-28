# iOS Contacts Test Task Implementation

## Requirements

### Overview

This iOS application allows users to interact with their device's address book. The app's primary functionality is to enable the selection of one or more contacts and display them on a separate screen.


#### 1. Contact Selection Feature
The app must implement the following features:
- **Contact Display:**
  - Display a list of contacts from the address book, sorted alphabetically.
  - For each contact, display:
    - Avatar (if available) or initials
    - First and last name
    - Phone number (optional)
  - Include a checkbox next to each contact for selection.
- **Multi-Selection:**
  - Allow users to select zero, one, or multiple contacts.
  - Indicate selected contacts with a checkmark in the checkbox.
- **Search Functionality:**
  - Provide a search field to filter contacts by first name, last name, or phone number.
  - Support transliteration search.
  - Optional: Highlight matching characters in names or phone numbers.

#### 2. Technical Specifications
- **Architecture:** MVVM (Model-View-ViewModel), Coordinator pattern
- **Frameworks:** SwiftUI, Combine
- **Programming Language:** Swift
- **Supported Device:** iPhone only
- **Minimum iOS Version:** 16
- **Orientation:** Portrait mode only

#### 3. User Interface Guidelines
- **Layout:**
  - Search field at the top of the screen.
  - Scrollable contact list.
  - "Add Participant" button, inactive if no contacts are selected.
- **Design:**
  - Use system fonts and colors.
  - Ensure responsive design for various screen sizes.
  - Leverage iOS Native Components & SF Symbols for UI elements.

#### 4. Performance Requirements
- Ensure smooth operation even with a large number of contacts in the address book.

