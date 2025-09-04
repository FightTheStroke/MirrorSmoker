//
//  PurchaseHistoryView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 04/09/25.
//

import SwiftUI
import SwiftData

struct PurchaseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Purchase.timestamp, order: .reverse) private var allPurchases: [Purchase]
    @Query private var userProfiles: [UserProfile]
    
    @State private var selectedTimeRange: TimeRange = .all
    @State private var searchText = ""
    
    enum TimeRange: String, CaseIterable {
        case week = "week"
        case month = "month"
        case threeMonths = "threeMonths"
        case all = "all"
        
        var displayName: String {
            switch self {
            case .week:
                return "purchase.history.week".local()
            case .month:
                return "purchase.history.month".local()
            case .threeMonths:
                return "purchase.history.three.months".local()
            case .all:
                return "purchase.history.all".local()
            }
        }
    }
    
    private var preferredCurrency: String {
        return userProfiles.first?.preferredCurrency ?? "EUR"
    }
    
    private var filteredPurchases: [Purchase] {
        var purchases = allPurchases
        
        // Filter by time range
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date? = {
            switch selectedTimeRange {
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: now)
            case .all:
                return nil
            }
        }()
        
        if let startDate = startDate {
            purchases = purchases.filter { $0.timestamp >= startDate }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            purchases = purchases.filter { purchase in
                purchase.productName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return purchases
    }
    
    private var totalSpent: Double {
        filteredPurchases.reduce(0) { total, purchase in
            total + (purchase.amountInCurrency * Double(purchase.quantity))
        }
    }
    
    private var groupedByMonth: [(String, [Purchase])] {
        let groupedDict = Dictionary(grouping: filteredPurchases) { purchase in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: purchase.timestamp)
        }
        
        return groupedDict.sorted { $0.key > $1.key }.map { (key, purchases) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            let date = formatter.date(from: key) ?? Date()
            formatter.dateFormat = "MMMM yyyy"
            return (formatter.string(from: date), purchases.sorted { $0.timestamp > $1.timestamp })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Time range picker
                timeRangePickerSection
                
                // Search bar
                searchSection
                
                // Purchase list
                purchaseListSection
            }
            .navigationTitle("purchase.history.title".local())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".local()) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DS.Space.md) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("purchase.history.total.spent".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Text(formatCurrency(totalSpent, preferredCurrency))
                        .font(DS.Text.title)
                        .fontWeight(.bold)
                        .foregroundColor(DS.Colors.danger)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DS.Space.xs) {
                    Text("purchase.history.total.purchases".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Text("\(filteredPurchases.count)")
                        .font(DS.Text.title)
                        .fontWeight(.bold)
                        .foregroundColor(DS.Colors.primary)
                }
            }
            .padding(DS.Space.lg)
            .background(DS.Colors.backgroundSecondary)
        }
    }
    
    private var timeRangePickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.sm) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedTimeRange = range
                    }) {
                        Text(range.displayName)
                            .font(DS.Text.caption)
                            .fontWeight(selectedTimeRange == range ? .semibold : .regular)
                            .foregroundColor(selectedTimeRange == range ? .white : DS.Colors.textPrimary)
                            .padding(.horizontal, DS.Space.md)
                            .padding(.vertical, DS.Space.xs)
                            .background(selectedTimeRange == range ? DS.Colors.primary : DS.Colors.backgroundSecondary)
                            .cornerRadius(DS.Size.cardRadiusSmall)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .padding(.vertical, DS.Space.sm)
    }
    
    private var searchSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DS.Colors.textSecondary)
                
                TextField("purchase.history.search.placeholder".local(), text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                }
            }
            .padding(DS.Space.md)
            .background(DS.Colors.backgroundSecondary)
            .cornerRadius(DS.Size.cardRadiusSmall)
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.md)
            
            Divider()
                .background(DS.Colors.textTertiary.opacity(0.3))
        }
    }
    
    private var purchaseListSection: some View {
        ScrollView {
            LazyVStack(spacing: DS.Space.md) {
                if filteredPurchases.isEmpty {
                    EmptyPurchaseHistoryView()
                } else {
                    ForEach(groupedByMonth, id: \.0) { (month, purchases) in
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            // Month header
                            HStack {
                                Text(month)
                                    .font(DS.Text.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DS.Colors.textPrimary)
                                
                                Spacer()
                                
                                let monthTotal = purchases.reduce(0) { total, purchase in
                                    total + (purchase.amountInCurrency * Double(purchase.quantity))
                                }
                                
                                Text(formatCurrency(monthTotal, preferredCurrency))
                                    .font(DS.Text.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(DS.Colors.danger)
                            }
                            .padding(.horizontal, DS.Space.lg)
                            
                            // Purchases for this month
                            ForEach(purchases, id: \.id) { purchase in
                                PurchaseRowView(
                                    purchase: purchase,
                                    preferredCurrency: preferredCurrency
                                )
                                .padding(.horizontal, DS.Space.lg)
                            }
                        }
                    }
                }
            }
            .padding(.top, DS.Space.md)
        }
    }
    
    private func formatCurrency(_ amount: Double, _ currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(String(format: "%.2f", amount)) \(currencyCode)"
    }
}

struct PurchaseRowView: View {
    let purchase: Purchase
    let preferredCurrency: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(purchase.productName)
                    .font(DS.Text.body)
                    .fontWeight(.medium)
                    .foregroundColor(DS.Colors.textPrimary)
                
                HStack(spacing: DS.Space.xs) {
                    Text(purchase.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    if purchase.quantity > 1 {
                        Text("• \(purchase.quantity)x")
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DS.Space.xs) {
                let totalAmount = purchase.amountInCurrency * Double(purchase.quantity)
                Text(formatCurrency(totalAmount, preferredCurrency))
                    .font(DS.Text.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DS.Colors.danger)
                
                if purchase.currencyCode != preferredCurrency {
                    Text("(\(formatCurrency(purchase.amountInCurrency, purchase.currencyCode)))")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
        .padding(DS.Space.md)
        .background(DS.Colors.backgroundSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
    }
    
    private func formatCurrency(_ amount: Double, _ currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(String(format: "%.2f", amount)) \(currencyCode)"
    }
}

struct EmptyPurchaseHistoryView: View {
    var body: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textSecondary)
            
            VStack(spacing: DS.Space.xs) {
                Text("purchase.history.empty.title".local())
                    .font(DS.Text.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text("purchase.history.empty.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DS.Space.xl)
    }
}

#Preview {
    PurchaseHistoryView()
        .modelContainer(for: [Purchase.self, UserProfile.self], inMemory: true)
}