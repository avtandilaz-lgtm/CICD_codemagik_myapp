//
//  SecondChanceView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData

struct SecondChanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<AlmostMoment> { $0.secondChanceActive == true })
    private var activeSecondChances: [AlmostMoment]
    
    @State private var showManualSelection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let secondChance = activeSecondChances.first,
                       let daysRemaining = SecondChanceManager.shared.daysRemaining(for: secondChance) {
                        
                        // Countdown Timer with Circular Progress
                        ZStack {
                            Circle()
                                .stroke(Color.orange.opacity(0.2), lineWidth: 20)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(daysRemaining) / 30.0)
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.orange, .yellow]),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: daysRemaining)
                            
                            VStack(spacing: 8) {
                                Text("\(daysRemaining)")
                                    .font(.system(size: 64, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("days left")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                if daysRemaining == 1 {
                                    Text("Last chance!")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        
                        // Motivational Quote
                        Text("\"It's not over until you win.\"")
                            .font(.headline)
                            .italic()
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        // Moment Details
                        SecondChanceCard(moment: secondChance, daysRemaining: daysRemaining)
                            .padding(.horizontal)
                        
                        // Actions
                        NavigationLink(destination: AlmostDetailView(moment: secondChance, context: modelContext)) {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("View Details")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Manual Add Button (to replace current)
                        Button(action: {
                            showManualSelection = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Manually")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Active Second Chance")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("A second chance will be automatically selected based on your settings, or you can manually activate one from any 'almost' moment.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Manual Add Button
                            Button(action: {
                                showManualSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Manually")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        .padding(.vertical, 60)
                    }
                }
                .padding(.vertical)
            }
            .scrollContentBackground(.hidden)
            .withAppBackground()
            .navigationTitle("Second Chance")
            .sheet(isPresented: $showManualSelection) {
                ManualSecondChanceView(context: modelContext)
            }
        }
    }
}

// Manual Second Chance Selection View
struct ManualSecondChanceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\AlmostMoment.timestamp, order: .reverse)])
    private var allMoments: [AlmostMoment]
    
    private var availableMoments: [AlmostMoment] {
        allMoments.filter { !$0.isVictory && !$0.secondChanceActive }
    }
    
    let context: ModelContext
    
    var body: some View {
        NavigationStack {
            if availableMoments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Available Moments")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("All your 'almost' moments are either victories or already have active second chances.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 60)
                .navigationTitle("Select Moment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            } else {
                List {
                    ForEach(availableMoments) { moment in
                        Button(action: {
                            // If there's an active second chance, deactivate it first
                            if let active = SecondChanceManager.shared.getActiveSecondChance(context: context) {
                                SecondChanceManager.shared.deactivateSecondChance(moment: active, context: context)
                                NotificationService.shared.cancelSecondChanceReminders(for: active)
                            }
                            
                            // Activate new second chance
                            SecondChanceManager.shared.activateSecondChance(moment: moment, context: context)
                            NotificationService.shared.scheduleSecondChanceReminders(for: moment, context: context)
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                // Category Icon
                                CategoryIconView(category: moment.categoryEnum, size: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(moment.categoryEnum.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let text = moment.text, !text.isEmpty {
                                        Text(text)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    HStack {
                                        Text("\(moment.closenessPercentage)% close")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("•")
                                            .foregroundColor(.secondary)
                                        
                                        Text(moment.timestamp, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .navigationTitle("Select Moment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

