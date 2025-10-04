enum Hedef {
  kiloVer('Kilo Ver'),
  kiloAl('Kilo Al'),
  formdaKal('Formda Kal'),
  kasKazanKiloAl('Kas Kazan + Kilo Al'),
  kasKazanKiloVer('Kas Kazan + Kilo Ver');

  final String aciklama;
  const Hedef(this.aciklama);
}

enum AktiviteSeviyesi {
  hareketsiz('Hareketsiz (Ofis işi)'),
  hafifAktif('Hafif Aktif (Haftada 1-3 gün)'),
  ortaAktif('Orta Aktif (Haftada 3-5 gün)'),
  cokAktif('Çok Aktif (Haftada 6-7 gün)'),
  ekstraAktif('Ekstra Aktif (Günde 2 antrenman)');

  final String aciklama;
  const AktiviteSeviyesi(this.aciklama);
}

enum Cinsiyet {
  erkek('Erkek'),
  kadin('Kadın');

  final String aciklama;
  const Cinsiyet(this.aciklama);
}

enum DiyetTipi {
  normal('Normal'),
  vejetaryen('Vejetaryen'),
  vegan('Vegan');

  final String aciklama;
  const DiyetTipi(this.aciklama);

  // ⭐ Her diyet tipinin varsayılan kısıtlamaları
  List<String> get varsayilanKisitlamalar {
    switch (this) {
      case DiyetTipi.vejetaryen:
        return ['Et', 'Tavuk', 'Balık', 'Deniz Ürünleri'];
      case DiyetTipi.vegan:
        return [
          'Et',
          'Tavuk',
          'Balık',
          'Deniz Ürünleri',
          'Süt',
          'Peynir',
          'Yoğurt',
          'Yumurta',
          'Bal'
        ];
      case DiyetTipi.normal:
        return [];
    }
  }
}
