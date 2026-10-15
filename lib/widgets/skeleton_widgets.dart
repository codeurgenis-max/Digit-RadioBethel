import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';

class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class VerseSkeleton extends StatelessWidget {
  const VerseSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonContainer(width: 20, height: 20, borderRadius: 10),
              SizedBox(width: 8),
              SkeletonContainer(width: 100, height: 16),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonContainer(width: double.infinity, height: 20),
          const SizedBox(height: 8),
          const SkeletonContainer(width: 200, height: 20),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.bottomRight,
            child: SkeletonContainer(width: 80, height: 16),
          ),
        ],
      ),
    );
  }
}

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          const SkeletonContainer(width: 80, height: 80, borderRadius: 20),
          const SizedBox(height: 8),
          const SkeletonContainer(width: 60, height: 12),
        ],
      ),
    );
  }
}

class LiveSkeleton extends StatelessWidget {
  const LiveSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          const SkeletonContainer(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonContainer(width: 80, height: 12),
                SizedBox(height: 8),
                SkeletonContainer(width: 150, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventSkeleton extends StatelessWidget {
  const EventSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          const SkeletonContainer(width: 50, height: 50, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonContainer(width: 120, height: 16),
                SizedBox(height: 8),
                SkeletonContainer(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PodcastSkeleton extends StatelessWidget {
  const PodcastSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SkeletonContainer(width: 80, height: 80, borderRadius: 16),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonContainer(width: double.infinity, height: 18),
                SizedBox(height: 8),
                SkeletonContainer(width: 120, height: 14),
                SizedBox(height: 8),
                SkeletonContainer(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SkeletonContainer(width: 40, height: 40, borderRadius: 20),
        ],
      ),
    );
  }
}

class ReplaySkeleton extends StatelessWidget {
  const ReplaySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonContainer(width: 280, height: 157, borderRadius: 24), // 16:9 aspect ratio
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonContainer(width: 200, height: 16),
                SizedBox(height: 8),
                SkeletonContainer(width: 100, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
