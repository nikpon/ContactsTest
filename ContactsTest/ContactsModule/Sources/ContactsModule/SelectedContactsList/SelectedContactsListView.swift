//
//  SelectedContactsListView.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import SwiftUI

public struct SelectedContactsListView: View {
    @ObservedObject private var viewModel: SelectedContactsListViewModel
    @State private var showingSettingsAlert = false
    
    public init(viewModel: SelectedContactsListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            content
            
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .navigationTitle("Saved contacts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.showContactsSearch()
                }, label: {
                    Image(systemName: "magnifyingglass")
                })
                .disabled(viewModel.contactsAccessAuthStatus != .granted)
            }
        }
        .onAppear {
            withAnimation {
                viewModel.load()
            }
        }
        .alert(isPresented: $showingSettingsAlert) {
            Alert(
                title: Text("Contacts Access Required"),
                message: Text("Please grant access to your contacts in Settings."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let error = viewModel.error {
            Text("Failed to fetch saved contacts: \(error.localizedDescription)")
                .foregroundColor(.red)
                .padding()
        } else {
            contactsListView
        }
    }
    
    @ViewBuilder
    private var contactsListView: some View {
        VStack {
            if viewModel.contacts.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.contacts) { contact in
                        ContactCardView(contact: contact, displayMode: .standard)
                    }
                    .onDelete(perform: viewModel.deleteContacts(at:))
                }
                .listStyle(.plain)
            }
            
            if viewModel.contactsAccessAuthStatus == .denied || viewModel.contactsAccessAuthStatus == .failed {
                authorizationDeniedView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Text("No saved contacts")
                .font(.headline)
            
            if viewModel.contactsAccessAuthStatus == .granted {
                Text("Tap the search icon to add contacts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var authorizationDeniedView: some View {
        VStack {
            Text("Contacts Access Denied")
                .font(.headline)
            
            Text("To add new contacts, please allow access in Settings")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Open Settings") {
                showingSettingsAlert = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(10)
        .padding()
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
