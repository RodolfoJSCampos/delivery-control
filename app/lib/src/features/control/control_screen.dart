import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

// Placeholder for a Delivery class
class Delivery {
  final String id;
  final DateTime dispatchDateTime;
  final List<String> orderNumbers;
  final List<DeliveryTeamMember> team;

  Delivery({
    required this.id,
    required this.dispatchDateTime,
    required this.orderNumbers,
    required this.team,
  });
}

class DeliveryTeamMember {
  final String name;
  final String imageUrl; // Path to avatar image

  DeliveryTeamMember({required this.name, required this.imageUrl});
}

class _ControlScreenState extends State<ControlScreen> {
  final CollectionReference _orders = FirebaseFirestore.instance.collection(
    'orders',
  );
  late StreamSubscription<QuerySnapshot> _ordersSubscription;

  List<DocumentSnapshot> _allOrders = [];
  List<DocumentSnapshot> _availableOrders = [];
  final List<DocumentSnapshot> _ordersInTruck = [];

  Timer? _timer; // Declare the timer

  final List<Delivery> _unfinalizedDeliveries = [
    Delivery(
      id: '1',
      dispatchDateTime: DateTime.now().subtract(const Duration(hours: 2)),
      orderNumbers: ['P123', 'P456'],
      team: [
        DeliveryTeamMember(
          name: 'João',
          imageUrl: 'assets/avatar1.png',
        ), // Placeholder avatar
        DeliveryTeamMember(
          name: 'Maria',
          imageUrl: 'assets/avatar2.png',
        ), // Placeholder avatar
      ],
    ),
    Delivery(
      id: '2',
      dispatchDateTime: DateTime.now().subtract(const Duration(hours: 1)),
      orderNumbers: ['P789', 'P101'],
      team: [
        DeliveryTeamMember(
          name: 'Pedro',
          imageUrl: 'assets/avatar3.png',
        ), // Placeholder avatar
      ],
    ),
    Delivery(
      id: '3',
      dispatchDateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      orderNumbers: [
        'P1001',
        'P1002',
        'P1003',
        'P1004',
        'P1005',
        'P1006',
        'P1007',
        'P1008',
      ],
      team: [
        DeliveryTeamMember(name: 'Ana', imageUrl: 'assets/avatar4.png'),
        DeliveryTeamMember(name: 'Carlos', imageUrl: 'assets/avatar5.png'),
      ],
    ),
    Delivery(
      id: '4',
      dispatchDateTime: DateTime.now().subtract(const Duration(minutes: 15)),
      orderNumbers: ['O1', 'O2', 'O3', 'O4', 'O5', 'O6', 'O7'],
      team: [
        DeliveryTeamMember(name: 'Lucas', imageUrl: 'assets/avatar6.png'),
        DeliveryTeamMember(name: 'Sofia', imageUrl: 'assets/avatar7.png'),
        DeliveryTeamMember(name: 'Miguel', imageUrl: 'assets/avatar8.png'),
        DeliveryTeamMember(name: 'Laura', imageUrl: 'assets/avatar9.png'),
        DeliveryTeamMember(name: 'Daniel', imageUrl: 'assets/avatar10.png'),
        DeliveryTeamMember(name: 'Isabela', imageUrl: 'assets/avatar11.png'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ordersSubscription = _orders.snapshots().listen((snapshot) {
      setState(() {
        _allOrders = snapshot.docs;
        _rebuildAvailableOrders();
      });
    });

    // Initialize timer to update elapsed time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        // Trigger rebuild to update elapsed times
      });
    });
  }

  @override
  void dispose() {
    _ordersSubscription.cancel();
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _rebuildAvailableOrders() {
    final truckOrderIds = _ordersInTruck.map((o) => o.id).toSet();
    _availableOrders =
        _allOrders.where((o) => !truckOrderIds.contains(o.id)).toList();
  }

  String _formatElapsedTime(DateTime dispatchTime) {
    final now = DateTime.now();
    final difference = now.difference(dispatchTime);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    const buttonSize = Size(86, 34.4);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          SizedBox(
            width: 580.0, // Fixed width for the first column (increased)
            child: Column(
              children: [
                Expanded(
                  child: DragTarget<DocumentSnapshot>(
                    builder: (context, candidateData, rejectedData) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 2.5,
                              ),
                          itemCount: _availableOrders.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _availableOrders.length) {
                              return OutlinedButton(
                                onPressed: () {
                                  _orders.add({
                                    'orderNumber':
                                        'Pedido ${_allOrders.length + 1}',
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.add),
                              );
                            }
                            final order = _availableOrders[index];
                            return Draggable<DocumentSnapshot>(
                              data: order,
                              feedback: Opacity(
                                opacity: 0.5,
                                child: SizedBox.fromSize(
                                  size: buttonSize,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.center,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(order['orderNumber']),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.center,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(order['orderNumber']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    onAccept: (data) {
                      setState(() {
                        _ordersInTruck.removeWhere((o) => o.id == data.id);
                        _rebuildAvailableOrders();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280.0, // Fixed width for Caixa 2 (increased)
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          // Image takes available space
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: 0.25,
                                child: Image.asset(
                                  'assets/truck.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity, // Added width
                                ),
                              ),
                              DragTarget<DocumentSnapshot>(
                                builder: (
                                  BuildContext context,
                                  List<dynamic> accepted,
                                  List<dynamic> rejected,
                                ) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          accepted.isNotEmpty
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.transparent,
                                    ),
                                    child: Transform.translate(
                                      offset: const Offset(59, -35),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 410,
                                          height: 120,
                                          decoration: const BoxDecoration(
                                            // Removed border
                                          ),
                                          child: SingleChildScrollView(
                                            reverse: true,
                                            child: Wrap(
                                              verticalDirection:
                                                  VerticalDirection.up,
                                              spacing:
                                                  9.0, // Reduced horizontal spacing
                                              runSpacing:
                                                  0.0, // Reduced vertical spacing
                                              children:
                                                  _ordersInTruck.map((order) {
                                                    return Draggable<
                                                      DocumentSnapshot
                                                    >(
                                                      data: order,
                                                      feedback: Opacity(
                                                        opacity: 0.5,
                                                        child: SizedBox.fromSize(
                                                          size: buttonSize,
                                                          child: ElevatedButton(
                                                            onPressed: () {},
                                                            style: ElevatedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              order['orderNumber'],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      childWhenDragging: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4.0,
                                                            ),
                                                        child:
                                                            SizedBox.fromSize(
                                                              size: buttonSize,
                                                            ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4.0,
                                                            ),
                                                        child: SizedBox.fromSize(
                                                          size: buttonSize,
                                                          child: ElevatedButton(
                                                            onPressed: () {},
                                                            style: ElevatedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              order['orderNumber'],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onAccept: (data) {
                                  setState(() {
                                    if (!_ordersInTruck.any(
                                      (o) => o.id == data.id,
                                    )) {
                                      _ordersInTruck.add(data);
                                      _rebuildAvailableOrders();
                                    }
                                  });
                                },
                              ),
                              Positioned(
                                left: 56.0,
                                top: 66.0,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Add functionality for adding new orders to the truck
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(70, 70),
                                  ),
                                  child: const Icon(Icons.add, size: 32.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ), // Reverted padding
                          child: SizedBox(
                            // Added SizedBox to expand button horizontally
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                if (_ordersInTruck.isEmpty) return;

                                final batch =
                                    FirebaseFirestore.instance.batch();
                                for (final order in _ordersInTruck) {
                                  batch.delete(order.reference);
                                }
                                await batch.commit();

                                setState(() {
                                  _ordersInTruck.clear();
                                  _rebuildAvailableOrders();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.only(
                                  right: 5.0,
                                ), // Reduced right padding
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Expanded(
                                    child: Center(child: Text('Despachar')),
                                  ),
                                  Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: ListView.builder(
                itemCount: _unfinalizedDeliveries.length,
                itemBuilder: (context, index) {
                  final delivery = _unfinalizedDeliveries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Truck Image and Elapsed Time
                          Column(
                            children: [
                              Image.asset(
                                'assets/truck.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatElapsedTime(
                                      delivery.dispatchDateTime,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 12), // Spacing between columns
                          // Right Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First Row: Title, Subtitle (left), Members (right)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title and Subtitle
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Entrega #${delivery.id}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Despachado: ${delivery.dispatchDateTime.day}/${delivery.dispatchDateTime.month} ${delivery.dispatchDateTime.hour}:${delivery.dispatchDateTime.minute.toString().padLeft(2, '0')}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    // Delivery Team (right-aligned)
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 240.0), // Limit max width for 5 members
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: () {
                                              List<Widget> memberWidgets = [];
                                              int maxDisplayedMembers = 5;

                                              int actualMembersToDisplay = delivery.team.length > maxDisplayedMembers
                                                  ? maxDisplayedMembers - 1
                                                  : delivery.team.length;

                                              for (int i = 0; i < actualMembersToDisplay; i++) {
                                                final member = delivery.team[i];
                                                memberWidgets.add(
                                                  SizedBox(
                                                    width: 50.0, // Fixed width for each member
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      child: Column(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 20,
                                                            backgroundImage: member.imageUrl.isNotEmpty
                                                                ? AssetImage(member.imageUrl)
                                                                : null,
                                                            child: member.imageUrl.isEmpty
                                                                ? const Icon(Icons.person, size: 25)
                                                                : null,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            member.name,
                                                            style: Theme.of(context).textTheme.bodySmall,
                                                            textAlign: TextAlign.center,
                                                            overflow: TextOverflow.ellipsis, // Handle long names
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              if (delivery.team.length >= maxDisplayedMembers) {
                                                int remainingMembers = delivery.team.length - (maxDisplayedMembers - 1);
                                                memberWidgets.add(
                                                  SizedBox(
                                                    width: 60.0, // Fixed width for each member
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Column(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 20,
                                                            child: Text(
                                                              '+$remainingMembers',
                                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            'Membros', // "Membros" text
                                                            style: Theme.of(context).textTheme.bodySmall,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return memberWidgets;
                                            }(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ), // Spacing between rows
                                // Second Row: Order Chips
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children:
                                      delivery.orderNumbers.map((orderNum) {
                                        return OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: Size(40, 16),
                                            padding: EdgeInsets.zero,
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.outline,
                                              width: 0.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            orderNum,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(fontSize: 8.0),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
