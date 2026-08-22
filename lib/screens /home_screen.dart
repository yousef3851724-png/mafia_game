// جایگزین TextButton تاریخچه با این:
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    TextButton.icon(
      onPressed: () => context.push('/history'),
      icon: const Icon(Icons.history),
      label: const Text('تاریخچه'),
    ),
    TextButton.icon(
      onPressed: () => context.push('/settings'),
      icon: const Icon(Icons.settings),
      label: const Text('تنظیمات'),
    ),
  ],
),
