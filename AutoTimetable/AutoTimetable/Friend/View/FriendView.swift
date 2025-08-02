//
//  SwiftUIView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct FriendView: View {
    @State var selectedTab: Tab = .friend
    @StateObject var friendViewModel: FriendViewModel
    
    @State var editMode = false
    
    init(authViewModel: AuthViewModel) {
        _friendViewModel = StateObject(wrappedValue: FriendViewModel(viewModel: authViewModel))
    }
    
    var body: some View {
        
        ZStack {
            
            if(friendViewModel.isLoading) {
                ProgressView()
            }
            
            ScrollView {
                VStack {
                    HStack {
                        
                        NavigationLink(destination: FriendSelectorView(friendViewModel: friendViewModel), label: {
                            VStack {
                                Image(systemName: "rectangle.split.3x3")
                                    .font(.title)
                                    .foregroundColor(Color.blue)
                                Text("시간표 비교")
                                    .foregroundColor(.primary)
                                    .padding(.top, 2)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        })
                        
                        NavigationLink(destination: FriendSelectorView2(friendViewModel: friendViewModel), label: {
                            VStack {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.title)
                                    .foregroundColor(Color.green)
                                Text("공강 비교")
                                    .foregroundColor(.primary)
                                    .padding(.top, 2)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        })
                    }
                    
                    HStack {
                        Spacer()
                        
                        NavigationLink(destination: FriendSearchView(friendViewModel: friendViewModel), label: {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                        })
                        
                    }
                    .padding(.vertical)
                    
                    Picker("탭 선택", selection: $selectedTab) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // 왜 있지?
                    Spacer()
                    
                    switch selectedTab {
                    case .friend:
                        FriendListView(friendViewModel: friendViewModel)
                    case .pending:
                        PendingListView(friendViewModel: friendViewModel)
                    }
                    
                    // 왜 있지?
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
//            if(friendViewModel.isLoading) {
//                loadingView()
//            }
        }
    }
    
    enum Tab: String, CaseIterable {
        case friend = "친구"
        case pending = "대기"
    }
}

