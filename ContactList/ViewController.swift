//
//  ViewController.swift
//  ContactList
//
//  Created by Павел on 16.08.2021.
//

import UIKit
import Contacts

struct Contact {
    let name: String
    let phone: String
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var contactTable: UITableView!
    
    let contactCellIdentifier = "ContactCell"
    var contacts = [Contact]()
    var isError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContacts()
        sortContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isError {
            showError()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier, for: indexPath)
        
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = prepareContactTitle(contact: contact)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: "Default")
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        call(phone: contacts[indexPath.row].phone)
    }
    
    private func loadContacts() {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            var cnContacts = [CNContact]()
            try CNContactStore().enumerateContacts(with: request) { cnContact, stop in
                cnContacts.append(cnContact)
            }
            prepareContacts(cnContacts: cnContacts)
        } catch {
            print("Error: \(error.localizedDescription)")
            isError = true
        }
    }
    
    private func prepareContacts(cnContacts: [CNContact]) {
        for cnContact in cnContacts {
            contacts.append(prepareContact(cnContact: cnContact))
        }
    }
    
    private func prepareContact(cnContact: CNContact) -> Contact{
        var name = ""
        if cnContact.givenName != "" && cnContact.familyName != "" {
            name = cnContact.givenName + " " + cnContact.familyName
        } else if cnContact.givenName != "" {
            name = cnContact.givenName
        } else {
            name = cnContact.familyName
        }
        
        var phone = ""
        if cnContact.phoneNumbers.count > 0 {
            phone = cnContact.phoneNumbers[0].value.stringValue
        }
        return Contact(name: name, phone: phone)
    }
    
    private func sortContacts() {
        contacts.sort(by: {$0.name < $1.name})
    }
    
    private func prepareContactTitle(contact: Contact) -> String {
        var contactTitle = ""
        if contact.name != "" && contact.phone != "" {
            contactTitle = contact.name + " / " + contact.phone
        } else if contact.name != "" {
            contactTitle = contact.name
        } else {
            contactTitle = contact.phone
        }
        return contactTitle
    }
    
    private func showError() {
        let alert = UIAlertController(title: NSLocalizedString("Ошибка!", comment: ""), message: "Не удалось получить доступ к контактам :(", preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("ок", comment: ""), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func call(phone: String) {
        let phoneNumber = phone.replacingOccurrences(of: " ", with: "")
        let url = URL(string: "telprompt://\(phoneNumber)")
                
        guard url != nil else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
}
