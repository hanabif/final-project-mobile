import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  final String name;
  final String logo;
  final VoidCallback onTap;

  const OrganizationCard({
    super.key,
    required this.name,
    required this.logo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (logo.isEmpty)
                const Icon(
                  Icons.business,
                  size: 60,
                  color: Colors.grey,
                )
              else if (logo.startsWith('http'))
                Image.network(
                  logo,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.business,
                    size: 60,
                    color: Colors.grey,
                  ),
                )
              else
                Image.asset(
                  logo,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.business,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
