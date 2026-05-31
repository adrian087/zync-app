import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ZyncSkeletonCard extends StatelessWidget {
  const ZyncSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 14, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 80, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(width: double.infinity, height: 14, color: Colors.white),
              const SizedBox(height: 6),
              Container(width: MediaQuery.of(context).size.width * 0.7, height: 14, color: Colors.white),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Container(width: 24, height: 24, color: Colors.white),
                  const SizedBox(width: 8),
                  Container(width: 20, height: 14, color: Colors.white),
                  const SizedBox(width: 16),
                  Container(width: 24, height: 24, color: Colors.white),
                  const SizedBox(width: 8),
                  Container(width: 20, height: 14, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}