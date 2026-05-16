// Hive Type Adapters for Campaign and TargetAudience
import 'package:hive/hive.dart';
import 'campaign.dart';

class TargetAudienceAdapter extends TypeAdapter<TargetAudience> {
  @override
  final int typeId = 1;

  @override
  TargetAudience read(BinaryReader reader) {
    return TargetAudience(
      ageRange: reader.readString(),
      regions: reader.readStringList(),
      interests: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, TargetAudience obj) {
    writer.writeString(obj.ageRange ?? '');
    writer.writeStringList(obj.regions ?? []);
    writer.writeStringList(obj.interests ?? []);
  }
}

class CampaignAdapter extends TypeAdapter<Campaign> {
  @override
  final int typeId = 0;

  @override
  Campaign read(BinaryReader reader) {
    return Campaign(
      id: reader.readString(),
      name: reader.readString(),
      status: reader.readString(),
      objective: reader.readString(),
      channel: reader.readString(),
      totalSpend: reader.readDouble(),
      budget: reader.readDouble(),
      impressions: reader.readInt(),
      clicks: reader.readInt(),
      startDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      currency: reader.readString(),
      budgetUtilization: reader.readDouble(),
      thumbnail: reader.readString(),
      conversions: reader.readInt(),
      costPerClick: reader.readDouble(),
      costPerConversion: reader.readDouble(),
      dailyBudget: reader.readDouble(),
      targetAudience: reader.read() as TargetAudience?,
    );
  }

  @override
  void write(BinaryWriter writer, Campaign obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.status);
    writer.writeString(obj.objective);
    writer.writeString(obj.channel);
    writer.writeDouble(obj.totalSpend);
    writer.writeDouble(obj.budget);
    writer.writeInt(obj.impressions);
    writer.writeInt(obj.clicks);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeInt(obj.endDate.millisecondsSinceEpoch);
    writer.writeString(obj.currency);
    writer.writeDouble(obj.budgetUtilization);
    writer.writeString(obj.thumbnail ?? '');
    writer.writeInt(obj.conversions ?? 0);
    writer.writeDouble(obj.costPerClick ?? 0.0);
    writer.writeDouble(obj.costPerConversion ?? 0.0);
    writer.writeDouble(obj.dailyBudget ?? 0.0);
    writer.write(obj.targetAudience);
  }
}
