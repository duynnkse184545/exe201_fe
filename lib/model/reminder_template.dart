class ReminderTemplate {
  String templateId;
  String templateName;
  String triggerType;
  int? triggerValue;

  ReminderTemplate({
    required this.templateId,
    required this.templateName,
    required this.triggerType,
    this.triggerValue,
  });

  factory ReminderTemplate.fromJson(Map<String, dynamic> json) {
    return ReminderTemplate(
      templateId: json['templateId'],
      templateName: json['templateName'],
      triggerType: json['triggerType'],
      triggerValue: json['triggerValue'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'templateName': templateName,
      'triggerType': triggerType,
      'triggerValue': triggerValue,
    };
  }
}