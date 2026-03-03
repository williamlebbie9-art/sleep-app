import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/referral_service.dart';

class ReferralHubScreen extends StatefulWidget {
  const ReferralHubScreen({super.key});

  @override
  State<ReferralHubScreen> createState() => _ReferralHubScreenState();
}

class _ReferralHubScreenState extends State<ReferralHubScreen> {
  final ReferralService _referralService = ReferralService();

  bool _loading = true;
  bool _creating = false;
  bool _requestingPayout = false;
  String? _code;
  String? _link;
  String _payoutFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await _referralService.getMyCreatorProfile();
      if (!mounted) return;
      setState(() {
        _code = profile?['code'] as String?;
        _link = profile?['link'] as String?;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _becomeCreator() async {
    setState(() => _creating = true);
    try {
      final code = await _referralService.ensureMyCreatorCode();
      if (!mounted) return;
      setState(() {
        _code = code;
        _link = _referralService.buildReferralLink(code);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creator referral code activated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not activate: $error')));
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied.')));
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _formatUsd(dynamic value) {
    final amount = _toDouble(value);
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatCreatedAt(dynamic value) {
    DateTime? dateTime;
    if (value is Timestamp) {
      dateTime = value.toDate();
    } else if (value is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (dateTime == null) return 'Pending date';
    final d = dateTime.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool _isThisMonth(dynamic value) {
    DateTime? dateTime;
    if (value is Timestamp) {
      dateTime = value.toDate();
    } else if (value is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (dateTime == null) return false;

    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  List<Map<String, dynamic>> _applyPayoutFilter(
    List<Map<String, dynamic>> items,
  ) {
    if (_payoutFilter == 'all') {
      return items;
    }
    return items.where((item) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      return status == _payoutFilter;
    }).toList();
  }

  Widget _buildMetricCard(
    String title,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? Colors.white70),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTile(Map<String, dynamic> item) {
    final amount = _formatUsd(item['amountUsd']);
    final status = (item['status'] ?? 'pending').toString();
    final eventType = (item['eventType'] ?? 'EVENT').toString();
    final createdAt = _formatCreatedAt(item['createdAt']);
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            isPending ? Icons.schedule : Icons.check_circle,
            color: isPending ? Colors.orangeAccent : Colors.greenAccent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventType.replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$createdAt • ${status.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutRequestTile(Map<String, dynamic> item) {
    final amount = _formatUsd(item['amountUsd']);
    final status = (item['status'] ?? 'pending').toString().toLowerCase();
    final requestedAt = _formatCreatedAt(item['requestedAt']);

    final Color statusColor;
    final IconData statusIcon;
    switch (status) {
      case 'paid':
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.redAccent;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payout Request',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$requestedAt • ${status.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _requestPayout({
    required double availableBalance,
    required String creatorCode,
  }) async {
    if (availableBalance <= 0 || _requestingPayout) {
      return;
    }

    setState(() => _requestingPayout = true);
    try {
      await _referralService.createPayoutRequest(
        amountUsd: availableBalance,
        creatorCode: creatorCode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payout request sent for ${_formatUsd(availableBalance)}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payout request failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _requestingPayout = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Referral Program')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite paid subscribers and track your creator referrals.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  if (_code == null) ...[
                    const Text('You are not a creator yet.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _creating ? null : _becomeCreator,
                      child: Text(
                        _creating ? 'Activating...' : 'Become a Creator',
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Your Creator Code',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _code!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _copy(_code!, 'Code'),
                          child: const Text('Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Referral Link',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_link ?? ''),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _link == null
                          ? null
                          : () => _copy(_link!, 'Link'),
                      child: const Text('Copy Link'),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<Map<String, dynamic>?>(
                      stream: _referralService.streamMyCreatorProfile(),
                      builder: (context, snapshot) {
                        final creator = snapshot.data;
                        final paidUsers = _toInt(
                          creator?['referredPaidUsersCount'],
                        );
                        final pendingBalance =
                            _formatUsd(creator?['pendingBalanceUsd']);
                        final availableBalance =
                            _formatUsd(creator?['availableBalanceUsd']);
                        final availableBalanceValue =
                          _toDouble(creator?['availableBalanceUsd']);
                        final lifetime =
                            _formatUsd(creator?['lifetimeCommissionUsd']);
                        final recurringRate = paidUsers >= 500 ? '25%' : '20%';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Creator Dashboard',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMetricCard(
                              'Paid Referred Subscribers',
                              paidUsers.toString(),
                              icon: Icons.group,
                              color: Colors.lightBlueAccent,
                            ),
                            const SizedBox(height: 10),
                            _buildMetricCard(
                              'Available Balance',
                              availableBalance,
                              icon: Icons.account_balance_wallet,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(height: 10),
                            _buildMetricCard(
                              'Pending (10-day hold)',
                              pendingBalance,
                              icon: Icons.schedule,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(height: 10),
                            _buildMetricCard(
                              'Lifetime Commission',
                              lifetime,
                              icon: Icons.monetization_on,
                              color: Colors.amberAccent,
                            ),
                            const SizedBox(height: 10),
                            _buildMetricCard(
                              'Recurring Tier',
                              recurringRate,
                              icon: Icons.trending_up,
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (availableBalanceValue <= 0 || _code == null)
                                    ? null
                                    : () => _requestPayout(
                                          availableBalance: availableBalanceValue,
                                          creatorCode: _code!,
                                        ),
                                icon: _requestingPayout
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.payments_outlined),
                                label: Text(
                                  _requestingPayout
                                      ? 'Requesting...'
                                      : 'Request Payout',
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Recent Commissions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _referralService.streamMyRecentCommissions(
                        limit: 20,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final items = snapshot.data ?? const [];
                        final thisMonth = items.where(
                          (item) => _isThisMonth(item['createdAt']),
                        );
                        final thisMonthApprovedTotal = thisMonth
                            .where(
                              (item) =>
                                  (item['status'] ?? '')
                                      .toString()
                                      .toLowerCase() ==
                                  'approved',
                            )
                            .fold<double>(
                              0,
                              (sum, item) => sum + _toDouble(item['amountUsd']),
                            );
                        final thisMonthPendingTotal = thisMonth
                            .where(
                              (item) =>
                                  (item['status'] ?? '')
                                      .toString()
                                      .toLowerCase() ==
                                  'pending',
                            )
                            .fold<double>(
                              0,
                              (sum, item) => sum + _toDouble(item['amountUsd']),
                            );

                        final summary = Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'This Month (Approved)',
                                _formatUsd(thisMonthApprovedTotal),
                                icon: Icons.check_circle,
                                color: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricCard(
                                'This Month (Pending)',
                                _formatUsd(thisMonthPendingTotal),
                                icon: Icons.schedule,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ],
                        );

                        if (items.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              summary,
                              const SizedBox(height: 10),
                              const Text(
                                'No commission records yet. RevenueCat webhook events will appear here.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items
                              .map((item) => _buildCommissionTile(item))
                              .toList()
                            ..insert(0, summary)
                            ..insert(1, const SizedBox(height: 10)),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payout Requests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _referralService.streamMyPayoutRequests(
                        limit: 20,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final allItems = snapshot.data ?? const [];
                        final items = _applyPayoutFilter(allItems);
                        final thisMonthRequestTotal = allItems
                            .where((item) => _isThisMonth(item['requestedAt']))
                            .fold<double>(
                              0,
                              (sum, item) => sum + _toDouble(item['amountUsd']),
                            );

                        final filterRow = Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('All'),
                              selected: _payoutFilter == 'all',
                              onSelected: (_) {
                                setState(() => _payoutFilter = 'all');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Pending'),
                              selected: _payoutFilter == 'pending',
                              onSelected: (_) {
                                setState(() => _payoutFilter = 'pending');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Paid'),
                              selected: _payoutFilter == 'paid',
                              onSelected: (_) {
                                setState(() => _payoutFilter = 'paid');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Rejected'),
                              selected: _payoutFilter == 'rejected',
                              onSelected: (_) {
                                setState(() => _payoutFilter = 'rejected');
                              },
                            ),
                          ],
                        );

                        final thisMonthCard = _buildMetricCard(
                          'Payout Requests This Month',
                          _formatUsd(thisMonthRequestTotal),
                          icon: Icons.request_page,
                          color: Colors.lightBlueAccent,
                        );

                        if (items.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              thisMonthCard,
                              const SizedBox(height: 10),
                              filterRow,
                              const SizedBox(height: 10),
                              const Text(
                                'No payout requests yet for this filter.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items
                              .map((item) => _buildPayoutRequestTile(item))
                              .toList()
                            ..insert(0, thisMonthCard)
                            ..insert(1, const SizedBox(height: 10))
                            ..insert(2, filterRow)
                            ..insert(3, const SizedBox(height: 10)),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Payout policy: $1 initial + 20% recurring, rises to 25% at 500 paid referred subscribers. Commissions confirm after 10 days.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
