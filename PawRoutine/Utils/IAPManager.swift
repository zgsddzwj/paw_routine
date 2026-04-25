//
//  IAPManager.swift
//  PawRoutine
//
//  StoreKit 2 应用内购买管理器
//

import StoreKit
import SwiftData

@Observable
final class IAPManager {
    static let shared = IAPManager()
    static let productID = "com.furrynote.pro.unlock"
    
    var product: Product?
    var isPro: Bool = false
    var isLoading = false
    var errorMessage: String?
    
    private init() {}
    
    /// 请求产品信息
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            await MainActor.run {
                self.product = products.first
            }
        } catch {
            await MainActor.run {
                self.errorMessage = NSLocalizedString("Unable to load product info", comment: "")
            }
        }
    }
    
    /// 执行购买
    func purchase() async -> Bool {
        guard let product else {
            await MainActor.run {
                self.errorMessage = NSLocalizedString("Product not loaded", comment: "")
            }
            return false
        }
        
        await MainActor.run { self.isLoading = true }
        defer { Task { @MainActor in self.isLoading = false } }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await MainActor.run { self.isPro = true }
                    // 触发 App Store 同步，确保 entitlement 立即生效
                    try? await AppStore.sync()
                    return true
                case .unverified(_, let error):
                    await MainActor.run {
                        self.errorMessage = String(format: NSLocalizedString("交易验证失败: %@", comment: ""), error.localizedDescription)
                    }
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                await MainActor.run {
                    self.errorMessage = NSLocalizedString("Waiting for payment confirmation", comment: "")
                }
                return false
            @unknown default:
                await MainActor.run {
                    self.errorMessage = NSLocalizedString("Purchase Failed", comment: "")
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    /// 恢复购买
    func restorePurchases() async {
        await MainActor.run { self.isLoading = true }
        defer { Task { @MainActor in self.isLoading = false } }
        
        // 触发 App Store 同步，刷新所有交易
        try? await AppStore.sync()
        
        for await entitlement in Transaction.currentEntitlements {
            switch entitlement {
            case .verified(let transaction):
                if transaction.productID == Self.productID {
                    await MainActor.run { self.isPro = true }
                    return
                }
            case .unverified(_, _):
                continue
            }
        }
        await MainActor.run { self.isPro = false }
    }
    
    /// 监听交易更新（购买完成、退款、家庭共享变更等）
    func observeTransactions() {
        Task(priority: .background) {
            for await verification in Transaction.updates {
                switch verification {
                case .verified(let transaction):
                    if transaction.productID == Self.productID {
                        // 检查是否被退款/撤销
                        if transaction.revocationDate != nil || transaction.revocationReason != nil {
                            await MainActor.run { self.isPro = false }
                        } else {
                            await MainActor.run { self.isPro = true }
                        }
                    }
                    await transaction.finish()
                case .unverified(_, _):
                    break
                }
            }
        }
    }
    
    /// 同步当前授权状态（启动时调用）
    func syncEntitlements() async {
        for await entitlement in Transaction.currentEntitlements {
            switch entitlement {
            case .verified(let transaction):
                if transaction.productID == Self.productID {
                    // 检查是否被退款
                    if transaction.revocationDate != nil || transaction.revocationReason != nil {
                        await MainActor.run { self.isPro = false }
                    } else {
                        await MainActor.run { self.isPro = true }
                    }
                    return
                }
            case .unverified(_, _):
                continue
            }
        }
        await MainActor.run { self.isPro = false }
    }
    
    /// 格式化产品价格显示
    var formattedPrice: String {
        product?.displayPrice ?? ""
    }
}
