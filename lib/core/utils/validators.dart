bool isValidEmail(String value) {
  final email = value.trim();
  if (email.isEmpty || email.contains(RegExp(r'\s'))) return false;

  final atIndex = email.indexOf('@');
  if (atIndex <= 0 || atIndex != email.lastIndexOf('@')) return false;

  final domain = email.substring(atIndex + 1);
  if (domain.isEmpty || !domain.contains('.')) return false;

  final domainParts = domain.split('.');
  return domainParts.every((part) => part.isNotEmpty);
}
