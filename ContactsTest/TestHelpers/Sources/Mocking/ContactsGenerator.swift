// The Swift Programming Language
// https://docs.swift.org/swift-book

import Contacts
import os
import UIKit
import Utilities

#if targetEnvironment(simulator)
fileprivate let cyrillicGivenNames: [String] = ["Юхим", "Ярослав", "Рустам", "Кирило", "Дарина", "Святослав", "Іраїда", "Олександра", "Павло", "Тарас", "Вероніка", "Ярина", "Ростислав", "Медея", "Матвій", "Каріна", "Люба", "Микита", "Лев", "Лаура", "Христина", "Леонід", "Назар", "Ілона", "Василь", "Борис", "Яна", "Поліна", "Аліса", "Артем", "Іларіон", "Софія", "Роксана", "Юліан", "Тимофій", "Лідія", "Антон", "Матей", "Емілія", "Яромир", "Денис", "Лія", "Інна", "Власта", "Захарко", "Світлана", "Зоряна", "Едуард", "Ніка", "Лілія", "Ольга", "Мар’ян", "Марія", "Мирослава", "Людмила", "Іван", "Платон", "Віктор", "Андрійко", "Ангеліна", "Римма", "Даніїл", "Камілла", "Анастасія", "Чарівна", "Олена", "Єфрем", "Омар", "Гліб", "Мілана", "Ігор", "Зінаїда", "Іванко", "Анна", "Вадим", "Любов", "Надія", "Тетяна", "Таміла", "Давид", "Євгенія", "Любомир", "Аліна", "Мадіна", "Наталія", "Лук’ян", "Микола", "Дмитро", "Макар", "Ясько", "Злата", "Єлисей", "Валерій", "Ігорьок", "Захарій", "Шарлотта", "Володимир", "Марина", "Даниїл", "Ірина", "Євген", "Анатолій", "Віталій", "Аркадій", "Арсен", "Катерина", "Олесь", "Юрій", "Арсеній", "Ілля", "Артемій", "Єлизавета", "Веніамін", "Марко", "Остап", "Маргарита", "Катруся", "Костянтин", "Юлія", "Станіслав", "Слава", "Аврора", "Неля", "Нонна", "Єгор", "Максим", "Жанна", "Галина", "Варвара", "Лариса", "Григорій", "Олег", "Соломія", "Михайло", "Ніна", "Сергій", "Захар", "Тимур", "Валерія", "Дем’ян", "Віра", "Вікторія", "Ельвіра", "Єлисейко", "Олександр", "Фаїна", "Альберт", "Оксана", "Богдан", "Філіп", "Мавра", "Зіновій", "Данило", "Ганна", "Алла", "Валентин", "Петро", "Віолетта", "Федір", "Серафим", "Єва", "Любомира", "Ліна", "Мальвіна", "Яків", "Олексій", "Максимільян", "Влад", "Зіна", "Владислав", "Кіра", "Калерія", "Тамара", "Інеса", "Валентина", "Мирослав", "Ярославна", "Андрій", "Ярослава", "Уляна", "Роман"]

fileprivate let cyrillicFamilyNames: [String] = ["Рибак", "Костюк", "Кіриченко", "Король", "Нікітенко", "Мельничук", "Іванов", "Жук", "Коваленко", "Дорошенко", "Білоконь", "Ткаченко", "Коломієць", "Козаченко", "Сидоренко", "Гордієнко", "Волошин", "Григорчук", "Лисенко", "Іванчук", "Радченко", "Боровик", "Ярошенко", "Колесник", "Кравець", "Грищенко", "Кравців", "Карпенко", "Пономарьов", "Лавренко", "Самойленко", "Поліщук", "Гончаренко", "Соколовський", "Шевчук", "Михайленко", "Морозенко", "Демченко", "Макаренко", "Соколов", "Степаненко", "Зубенко", "Кравченко", "Ніколаєнко", "Горбунов", "Коваль", "Тимченко", "Остапенко", "Іщенко", "Довженко", "Білаш", "Кошовий", "Тищенко", "Юрченко", "Мартинюк", "Нечипоренко", "Мишко", "Петренко", "Григоренко", "Паламарчук", "Литвин", "Куценко", "Ковальчук", "Савченко", "Бондаренко", "Тарасенко", "Громов", "Чорний", "Кучма", "Іванова", "Олійник", "Вовк", "Дяченко", "Боровий", "Холод", "Берез", "Гаврилюк", "Федоренко", "Павлик", "Яременко", "Гуменюк", "Мартин", "Гладкий", "Харченко", "Пономаренко", "Мельник", "Кочерга", "Шевченко", "Бондар", "Семененко", "Бойко", "Мороз", "Бондарчук", "Лукаш", "Романюк", "Хоменко", "Герасименко", "Сидорчук", "Кулинич", "Павленко", "Слободянюк", "Шевцов", "Попович", "Романенко", "Клименко", "Савчук", "Левченко", "Захарченко", "Білоус", "Трохименко", "Миколенко", "Козак", "Лещенко", "Чернявський", "Потоцький", "Марченко", "Шаповалов"]

fileprivate let latinGivenNames: [String] = ["Logan", "Benjamin", "Jeremy", "Dennis", "Gary", "Jack", "Roy", "Steven", "Bradley", "Jose", "William", "Eugene", "Jason", "George", "Daniel", "Kyle", "Bruce", "Willie", "Frank", "Jacob", "Richard", "Donald", "Kenneth", "Justin", "Christian", "Terry", "Russell", "Douglas", "Jordan", "Paul", "Ronald", "Keith", "Timothy", "Gerald", "Peter", "Patrick", "Edward", "Brandon", "Nicholas", "Henry", "Juan", "Christopher", "Gabriel", "Nathan", "Matthew", "Philip", "Johnny", "Ethan", "Vincent", "Noah", "Kevin", "Gregory", "Albert", "Dylan", "Walter", "Alan", "Thomas", "Roger", "Sean", "Aaron", "Austin", "Stephen", "Larry", "Louis", "Ryan", "Randy", "Raymond", "Robert", "Arthur", "Michael", "John", "Anthony", "Bryan", "David", "Zachary", "Eric", "Wayne", "Joseph", "Jonathan", "Brian", "Adam", "Andrew", "Alexander", "Joshua", "Samuel", "Charles", "Jesse", "Jeffrey", "Harold", "Jerry", "Tyler", "Carl", "Ralph", "Joe", "Mark", "Scott", "Bobby", "James", "Billy", "Ruth", "Sarah", "Donna", "Janice", "Melissa", "Cynthia", "Sara", "Susan", "Sharon", "Linda", "Deborah", "Lauren", "Carol", "Diana", "Isabella", "Grace", "Mary", "Nicole", "Katherine", "Gloria", "Julie", "Christina", "Kimberly", "Cheryl", "Doris", "Charlotte", "Jennifer", "Karen", "Amanda", "Betty", "Sandra", "Emily", "Abigail", "Theresa", "Ashley", "Emma", "Joan", "Teresa", "Amy", "Pamela", "Rose", "Margaret", "Amber", "Diane", "Brenda", "Danielle", "Joyce", "Evelyn", "Shirley", "Megan", "Andrea", "Martha", "Anna", "Angela", "Debra", "Maria", "Hannah", "Stephanie", "Olivia", "Patricia", "Carolyn", "Janet", "Lisa", "Nancy", "Jacqueline", "Barbara", "Jean", "Julia", "Denise", "Sophia", "Victoria", "Judy", "Heather", "Kathryn", "Elizabeth", "Rachel", "Natalie", "Marie", "Christine", "Judith", "Ann", "Virginia", "Michelle", "Alice", "Marilyn", "Kelly", "Frances", "Brittany", "Beverly", "Catherine", "Kathleen", "Dorothy", "Jessica", "Helen", "Laura", "Madison", "Rebecca", "Samantha"]

fileprivate let latinFamilyNames: [String] = ["Black", "Gibson", "Hudson", "Ellis", "Tucker", "Hart", "Gomez", "Shaw", "Mcdonald", "Dixon", "Watkins", "Mills", "Ruiz", "Gardner", "Burns", "Hunter", "Gordon", "West", "Owens", "Webb", "Morales", "Spencer", "Bradley", "Reynolds", "Hawkins", "Simpson", "Mason", "Holmes", "Rice", "Reyes", "Graham", "Sullivan", "Stevens", "Ray", "Andrews", "Warren", "Cole", "Nichols", "Matthews", "Diaz", "Armstrong", "Stone", "Rose", "Perkins", "Weaver", "Cunningham", "Stephens", "Pierce", "Myers", "Kennedy", "Hicks", "Harper", "Ferguson", "Russell", "Jordan", "Freeman", "Knight", "Palmer", "Dunn", "Ortiz", "Robertson", "Lane", "Hamilton", "Berry", "Greene", "Arnold", "Fisher", "Daniels", "Wells", "Griffin", "Fox", "Wagner", "Crawford", "Boyd", "Wallace", "Olson", "Cruz", "Carpenter", "Hayes", "Riley", "Woods", "Marshall", "Willis", "Harrison", "Bryant", "Carroll", "Alexander", "Porter", "Henry", "Duncan", "Snyder", "Hunt", "Murray", "Ramos", "Tran", "Ford", "Payne", "Grant"]

final public class ContactsGenerator {
    static private func randomPhoneNumber() -> String {
        var result: String = "+380"
        let numberOfDigits: UInt8 = 10
        
        for _ in 0..<numberOfDigits {
            result += String(Int.random(in: 0...9))
        }
        return result
    }
    
    static private var authorizationStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    // MARK: Public
    static public func requestAccessAndCreateRandomContacts(_ count: UInt, completion: (() -> Void)? = nil) {
        guard count > 0 else { return }
        
        guard authorizationStatus != .denied && authorizationStatus != .restricted else {
            CustomLogger.error("No access.")
            return
        }
        
        guard authorizationStatus == .authorized else {
            let store = CNContactStore()
            
            store.requestAccess(for: .contacts) { granted, error in
                guard granted && error == nil else { return }
                
                DispatchQueue.main.async {
                    createRandomContacts(count: count, completion: completion)
                }
            }
            
            return
        }
        
        createRandomContacts(count: count, completion: completion)
    }
    
    static public func deleteRandomContacts() {
        guard authorizationStatus != .denied && authorizationStatus != .restricted else { return }
        
        guard authorizationStatus == .authorized else {
            let store = CNContactStore()
            
            store.requestAccess(for: .contacts) { granted, error in
                guard granted && error == nil else { return }
                
                DispatchQueue.main.async {
                    deleteContactsWith(filter: { $0.familyName.hasPrefix("Random-") })
                }
            }
            
            return
        }
        
        deleteContactsWith(filter: { $0.familyName.hasPrefix("Random-") })
    }
    
    // MARK: Private
    private static func createRandomContacts(count: UInt, completion: (() -> Void)?) {
        CustomLogger.log("\(#function): \(count)")
        
        var contacts = [CNContact]()
        let saveRequest = CNSaveRequest()
        
        for i in 0..<count {
            autoreleasepool {
                let contact = CNMutableContact()
                
                if Bool.random() {
                    contact.familyName = "Random-" + cyrillicFamilyNames[Int.random(in: 0...cyrillicFamilyNames.count - 1)]
                    contact.givenName = cyrillicGivenNames[Int.random(in: 0...cyrillicGivenNames.count - 1)]
                } else {
                    contact.familyName = "Random-" + latinFamilyNames[Int.random(in: 0...latinFamilyNames.count - 1)]
                    contact.givenName = latinGivenNames[Int.random(in: 0...latinGivenNames.count - 1)]
                }
                
                let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: randomPhoneNumber()))
                contact.phoneNumbers = [homePhone]
                
                if let image = getImage(for: i), let avatarImageData = image.jpegData(compressionQuality: 0.9) {
                    contact.imageData = avatarImageData
                }
                
                contacts.append(contact)
                saveRequest.add(contact, toContainerWithIdentifier: nil)
            }
        }
        
        CustomLogger.log("Saving mock contacts: \(contacts.count)")
        
        do {
            try CNContactStore().execute(saveRequest)
        } catch {
            CustomLogger.log("Error saving mock contacts: \(error)")
        }
        
        completion?()
    }
    
    static private func getImage(for number: UInt) -> UIImage? {
        return UIImage(named: "random_user_images/user_\(number).jpg")
    }
    
    static private func deleteContactsWith(filter: (CNContact) -> Bool) {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName) as CNKeyDescriptor
        ]
        
        let contactStore = CNContactStore()
        let saveRequest = CNSaveRequest()
        
        do {
            try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keysToFetch)) { contact, _ in
                if filter(contact) {
                    saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
                }
            }
            
            try contactStore.execute(saveRequest)
        } catch {
            CustomLogger.error("\(error)")
        }
    }
}

#endif
