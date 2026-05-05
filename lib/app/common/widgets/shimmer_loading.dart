import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable shimmer loading widgets for different screens
class ShimmerLoading {
  ShimmerLoading._();

  static Widget _shimmerBase(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade300,
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade100,
      child: child,
    );
  }

  static Widget _box({
    double? width,
    double height = 16,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ─── Dashboard Shimmer ───
  static Widget dashboard(BuildContext context) {
    return _shimmerBase(
      context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Month selector
            _box(height: 48, radius: 14),
            const SizedBox(height: 20),
            // Balance card
            _box(height: 170, radius: 20),
            const SizedBox(height: 16),
            // Income / Expense row
            Row(
              children: [
                Expanded(child: _box(height: 100, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _box(height: 100, radius: 16)),
              ],
            ),
            const SizedBox(height: 24),
            // Pie chart section
            _box(height: 320, radius: 20),
            const SizedBox(height: 24),
            // Section title
            _box(width: 150, height: 20, radius: 6),
            const SizedBox(height: 12),
            // Budget items
            _box(height: 90, radius: 14),
            const SizedBox(height: 10),
            _box(height: 90, radius: 14),
            const SizedBox(height: 24),
            // Section title
            _box(width: 180, height: 20, radius: 6),
            const SizedBox(height: 12),
            // Transaction list
            _box(height: 280, radius: 16),
          ],
        ),
      ),
    );
  }

  // ─── Transaction List Shimmer ───
  static Widget transactionList(BuildContext context) {
    return _shimmerBase(
      context,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: 8,
        itemBuilder: (_, __) => _transactionItem(),
      ),
    );
  }

  static Widget _transactionItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _box(width: 48, height: 48, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 140, height: 14, radius: 6),
                const SizedBox(height: 8),
                _box(width: 90, height: 10, radius: 4),
              ],
            ),
          ),
          _box(width: 70, height: 16, radius: 6),
        ],
      ),
    );
  }

  // ─── Budget List Shimmer ───
  static Widget budgetList(BuildContext context) {
    return _shimmerBase(
      context,
      child: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _box(height: 48, radius: 14),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: 4,
              itemBuilder: (_, __) => _budgetItem(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _budgetItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(width: 44, height: 44, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 120, height: 14, radius: 6),
                    const SizedBox(height: 6),
                    _box(width: 80, height: 10, radius: 4),
                  ],
                ),
              ),
              _box(width: 50, height: 24, radius: 8),
            ],
          ),
          const SizedBox(height: 14),
          _box(height: 8, radius: 6),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(width: 100, height: 10, radius: 4),
              _box(width: 80, height: 10, radius: 4),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Category List Shimmer ───
  static Widget categoryList(BuildContext context) {
    return _shimmerBase(
      context,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _box(width: 44, height: 44, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 120, height: 14, radius: 6),
                    const SizedBox(height: 6),
                    _box(width: 60, height: 10, radius: 4),
                  ],
                ),
              ),
              _box(width: 60, height: 24, radius: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Profile Shimmer ───
  static Widget profile(BuildContext context) {
    return _shimmerBase(
      context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile card
            _box(height: 220, radius: 20),
            const SizedBox(height: 28),
            // Section
            Align(
              alignment: Alignment.centerLeft,
              child: _box(width: 80, height: 12, radius: 4),
            ),
            const SizedBox(height: 8),
            _box(height: 180, radius: 16),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: _box(width: 80, height: 12, radius: 4),
            ),
            const SizedBox(height: 8),
            _box(height: 60, radius: 16),
            const SizedBox(height: 20),
            _box(height: 56, radius: 16),
          ],
        ),
      ),
    );
  }
}


