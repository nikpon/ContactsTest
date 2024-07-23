//
//  ContactsSearchView.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import SwiftUI

public struct ContactsSearchView: View {
    @ObservedObject private var viewModel: ContactsSearchViewModel
    
    public init(viewModel: ContactsSearchViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        switch viewModel.state {
        case .idle: Color.clear.onAppear(perform: viewModel.load)
        case .loading: ProgressView().controlSize(.large)
        case .failed: EmptyView()
        case .loaded:
            VStack {
                contactsList
                
                Button("Add", action: {
                    viewModel.saveContactsAndClose()
                })
                .disabled(viewModel.selectedContacts.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .padding(.vertical)
            }
            .navigationTitle("Search contacts")
            .ignoresSafeArea(.keyboard)
        }
    }
    
    @ViewBuilder
    private var contactsList: some View {
        List {
            ForEach(viewModel.filteredContactsAndRanges, id: \.contact.id) { contactAndRanges in
                HStack {
                    ContactCardView(contact: contactAndRanges.contact, displayMode: contactAndRanges.matchRanges.map { .emphasized(contactMatchRanges: $0) } ?? .standard)
                    
                    Spacer()
                    
                    Image(systemName: viewModel.selectedContacts.contains(where: { $0 == contactAndRanges.contact }) ? "checkmark.square" : "square")
                        .foregroundStyle(Color.blue)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        viewModel.toggleSelection(for: contactAndRanges.contact)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter name")
        .autocorrectionDisabled(true)
        .overlay {
            if viewModel.filteredContactsAndRanges.isEmpty, !viewModel.searchQuery.isEmpty {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView.search(text: viewModel.searchQuery)
                } else {
                    Text("No results")
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}
