enum ServiceBoundary {
  platform(
    serviceName: 'synapse-platform-svc',
    domains: ['auth', 'billing', 'notifications', 'settings', 'admin'],
  ),
  engagement(
    serviceName: 'synapse-engagement-svc',
    domains: ['community', 'gamification'],
  ),
  knowledge(
    serviceName: 'synapse-knowledge-svc',
    domains: ['notes', 'graph', 'search'],
  ),
  learning(serviceName: 'synapse-learning-svc', domains: ['cards']);

  const ServiceBoundary({required this.serviceName, required this.domains});

  final String serviceName;
  final List<String> domains;
}
