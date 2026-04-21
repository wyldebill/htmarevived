import 'package:flutter/material.dart';

import '../domain/business.dart';

class BusinessListPage extends StatefulWidget {
  const BusinessListPage({
    required this.businesses,
    required this.onBusinessSelected,
    super.key,
  });

  final List<Business> businesses;
  final ValueChanged<Business> onBusinessSelected;

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends State<BusinessListPage> {
  String _query = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final categories = {
      'All',
      ...widget.businesses.map((business) => business.category),
    }.toList()..sort();

    final filtered = widget.businesses.where((business) {
      final categoryMatches =
          _selectedCategory == 'All' || business.category == _selectedCategory;
      if (!categoryMatches) {
        return false;
      }

      if (normalized.isEmpty) {
        return true;
      }
      return business.name.toLowerCase().contains(normalized) ||
          business.category.toLowerCase().contains(normalized);
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by name or category',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      labelStyle: TextStyle(
                        fontWeight: _selectedCategory == category
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'No businesses match your current filters.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final business = filtered[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        title: Text(
                          business.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${business.category}\n${business.address}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => widget.onBusinessSelected(business),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
