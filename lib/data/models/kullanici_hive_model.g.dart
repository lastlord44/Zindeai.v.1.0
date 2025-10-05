// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kullanici_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KullaniciHiveModelAdapter extends TypeAdapter<KullaniciHiveModel> {
  @override
  final int typeId = 0;

  @override
  KullaniciHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KullaniciHiveModel(
      id: fields[0] as String?,
      ad: fields[1] as String?,
      soyad: fields[2] as String?,
      yas: fields[3] as int?,
      boy: fields[4] as double?,
      mevcutKilo: fields[5] as double?,
      hedefKilo: fields[6] as double?,
      cinsiyet: fields[7] as String?,
      aktiviteSeviyesi: fields[8] as String?,
      hedef: fields[9] as String?,
      diyetTipi: fields[10] as String?,
      manuelAlerjiler: (fields[11] as List?)?.cast<String>(),
      kayitTarihi: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, KullaniciHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ad)
      ..writeByte(2)
      ..write(obj.soyad)
      ..writeByte(3)
      ..write(obj.yas)
      ..writeByte(4)
      ..write(obj.boy)
      ..writeByte(5)
      ..write(obj.mevcutKilo)
      ..writeByte(6)
      ..write(obj.hedefKilo)
      ..writeByte(7)
      ..write(obj.cinsiyet)
      ..writeByte(8)
      ..write(obj.aktiviteSeviyesi)
      ..writeByte(9)
      ..write(obj.hedef)
      ..writeByte(10)
      ..write(obj.diyetTipi)
      ..writeByte(11)
      ..write(obj.manuelAlerjiler)
      ..writeByte(12)
      ..write(obj.kayitTarihi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KullaniciHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
