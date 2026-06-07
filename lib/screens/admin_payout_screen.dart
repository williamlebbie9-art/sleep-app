import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/referral_service.dart';

class AdminPayoutScreen extends StatefulWidget {
  const AdminPayoutScreen({super.key});

  @override
  State<AdminPayoutScreen> createState() => _AdminPayoutScreenState();
}

class _AdminPayoutScreenState extends State<AdminPayoutScreen> {
  final ReferralService _referralService = ReferralService();
  final Set<String> _processingRequests = {};

  String _formatUsd(dynamic value) {
    final amount = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatCreatedAt(dynamic value) {
    if (value is DateTime) {
      final d = value.toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    if (value is Timestamp) {
      final d = value.toDate().toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    if (value is int) {
      final d = DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return 'Unknown date';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.greenAccent;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    setState(() {
      _processingRequests.add(requestId);
    });

    try {
      await _referralService.updatePayoutRequestStatus(
        requestId: requestId,
        status: status,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'paid'
                ? 'Payout marked as paid.'
                : 'Payout request rejected.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _referralService.friendlyErrorMessage(
                error,
                action: 'update payout request',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingRequests.remove(requestId);
        });
      }
    }
  }

  Widget _buildRequestTile(Map<String, dynamic> item) {
    final requestId = item['id']?.toString() ?? '';
    final amount = _formatUsd(item['amountUsd']);
    final status = (item['status'] ?? 'pending').toString();
    final requestedAt = _formatCreatedAt(item['requestedAt']);
    final creatorCode = (item['creatorCode'] ?? '').toString();
    final payoutMethod = (item['payoutMethod'] ?? '').toString();
    final payoutDetails = (item['payoutDetails'] ?? '').toString();
    final creatorUid = (item['creatorUid'] ?? '').toString();
    final isPending = status.toLowerCase() == 'pending';
    final processing = _processingRequests.contains(requestId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromRGBO(255, 255, 255, 0.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withAlpha(46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Creator: $creatorCode', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            'Creator UID: $creatorUid',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (payoutMethod.isNotEmpty) _buildTag('Method', payoutMethod),
              if (payoutDetails.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildTag('Details', payoutDetails),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Requested: $requestedAt',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: processing
                        ? null
                        : () => _updateRequestStatus(requestId, 'paid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: processing && _processingRequests.contains(requestId)
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mark Paid'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: processing
                        ? null
                        : () => _updateRequestStatus(requestId, 'rejected'),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Payouts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review creator payout requests and mark them as paid or rejected. '
              'This screen is intended for authorized staff only. Actual transfer must be completed outside the app.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _referralService.streamAllPayoutRequests(limit: 200),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _referralService.friendlyErrorMessage(
                          snapshot.error!,
                          action: 'load payout requests',
                        ),
                      ),
                    );
                  }

                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No payout requests found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildRequestTile(items[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
