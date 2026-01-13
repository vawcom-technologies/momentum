import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/power_up.dart';

class PowerUpCard extends StatelessWidget {
  final PowerUp powerUp;
  final VoidCallback? onActivate;
  final bool isActive;

  const PowerUpCard({
    super.key,
    required this.powerUp,
    this.onActivate,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (powerUp.type) {
      case PowerUpType.doubleXP:
        color = const Color(0xFFEF4444);
        break;
      case PowerUpType.shieldDecay:
        color = const Color(0xFF3B82F6);
        break;
      case PowerUpType.comboBoost:
        color = const Color(0xFFF59E0B);
        break;
      case PowerUpType.questRefresh:
        color = const Color(0xFF22C55E);
        break;
      case PowerUpType.luckBoost:
        color = const Color(0xFF8B5CF6);
        break;
    }

    return GestureDetector(
      onTap: isActive ? null : onActivate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isActive ? 0.3 : 0.2),
              color.withOpacity(isActive ? 0.15 : 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(isActive ? 0.8 : 0.5),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  powerUp.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            )
                .animate(
                  target: isActive ? 1 : 0,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scaleXY(end: 1.1, duration: 800.ms),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        powerUp.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? color : Colors.white,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${powerUp.remainingMinutes}m',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    powerUp.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive
                        ? 'Active for ${powerUp.remainingMinutes} min'
                        : 'Duration: ${powerUp.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (!isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'USE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PowerUpInventory extends StatelessWidget {
  final List<PowerUp> powerUps;
  final List<PowerUp> activePowerUps;
  final Function(String) onActivate;

  const PowerUpInventory({
    super.key,
    required this.powerUps,
    required this.activePowerUps,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    if (powerUps.isEmpty && activePowerUps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            const Text(
              '🎁',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'No Power-ups yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Spin the wheel to earn power-ups!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activePowerUps.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.bolt,
                size: 18,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Power-ups',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activePowerUps
              .where((p) => !p.isExpired)
              .map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PowerUpCard(powerUp: p, isActive: true),
                  )),
          const SizedBox(height: 16),
        ],
        if (powerUps.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.inventory_2,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              const Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${powerUps.length} items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...powerUps.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PowerUpCard(
                  powerUp: p,
                  onActivate: () => onActivate(p.id),
                ),
              )),
        ],
      ],
    );
  }
}
