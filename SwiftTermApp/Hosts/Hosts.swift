//
//  Hosts.swift
//  testMasterDetail
//
//  Created by Miguel de Icaza on 4/26/20.
//  Copyright © 2020 Miguel de Icaza. All rights reserved.
//

import SwiftUI

func getImage (for host: Host) -> some View
{
    if host.hostKindGuess == "" {
        return Image (systemName: "desktopcomputer")
        .scaledToFit()
        .frame(width: 28, height: 28)
    } else {
        return Image (host.hostKindGuess)
        .resizable()
        .scaledToFit()
        .frame(width: 28, height: 28)
    }
}

struct SwiftUITerminalWrapper: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var host: Host
    var createNew: Bool
    
    var body: some View {
        VStack {
            HStack (alignment: .center) {
                Spacer ().frame (maxWidth: 10)
                Image (systemName: "lessthan")
                Text ("Back")
                    .font(.footnote)
                Spacer ()
            }.onTapGesture {
                self.presentationMode.wrappedValue.dismiss()
            }

            SwiftUITerminal(host: host, createNew: createNew)
        }
        
    }
}

struct HostSummaryView: View {
    @Binding var host: Host
    @State var showingModal = false
    
    var body: some View {
        NavigationLink (destination:
            // Solution might be to use an external host UIViewController:
            // https://gist.github.com/timothycosta/a43dfe25f1d8a37c71341a1ebaf82213
            // https://stackoverflow.com/questions/56756318/swiftui-presentationbutton-with-modal-that-is-full-screen
            SwiftUITerminalWrapper(host: self.host, createNew: false)
                .navigationBarTitle("")
                .navigationBarHidden(true)
        ) {
            HStack (spacing: 12){
                getImage (for: host)
                    .font (.system(size: 28))
                    .brightness(Connections.lookupActive(host: self.host) != nil ? 0 : 0.6)
                    .colorMultiply(host.hostKindGuess == "" ? Color.black : Color.white)
                VStack (alignment: .leading, spacing: 4) {
                    HStack {
                        Text ("\(host.alias)")
                            .bold()
                        Spacer ()
                    }
                    Text (host.summary ())
                        .brightness(0.4)
                        .font(.footnote)
                }
                Button (action: {
                    print ("Hello")
                }) {
                    Image (systemName: "ellipsis.circle")
                        .font(.system(size: 24))
                }
                .onTapGesture {
                    self.showingModal = true
                }
            }.sheet(isPresented: $showingModal) {
                HostEditView(host: self.host, showingModal: self.$showingModal)
            }
            .contextMenu {
                NavigationLink(destination: SwiftUITerminal(host: self.host, createNew: true)){
                    Text("New Connection")
                    Image(systemName: "plus.circle")
                }
            
                Button(action: {
                    // enable geolocation
                }) {
                    Text("Close Connection")
                    Image(systemName: "minus.circle")
                }
            }
        }
    }
}


struct HostsView : View {
    @State var showHostEdit: Bool = false
    @ObservedObject var store: DataStore = DataStore.shared
    @State private var editMode = EditMode.inactive

    func delete (at offsets: IndexSet)
    {
        store.hosts.remove(atOffsets: offsets)
        store.saveState()
    }
    
    private func move(source: IndexSet, destination: Int)
    {
        store.hosts.move (fromOffsets: source, toOffset: destination)
        store.saveState()
    }
    
    var body: some View {
        List {
            STButton (text: "Add Host", icon: "plus.circle")
                .onTapGesture { self.showHostEdit = true }

            Section {
                ForEach(self.store.hosts.indices, id: \.self) { idx in
                    HostSummaryView (host: self.$store.hosts [idx])
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
                .environment(\.editMode, $editMode)
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle(Text("Hosts"))
        .navigationBarItems(trailing: HStack {
            Button (action: { self.showHostEdit = true }) {
                Image (systemName: "plus")
            }
            EditButton()
        })
        .sheet (isPresented: $showHostEdit) {
            HostEditView(host: Host(), showingModal: self.$showHostEdit)
        }
    }
}

struct PrimaryLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
        // content.frame (width: 100, alignment: .leading)
    }
}

struct Hosts_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HostsView()
        }
    }
}
