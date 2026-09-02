import 'dart:async';

class ProdukTidakAda implements Exception {
  final String message;
  ProdukTidakAda(this.message);

  @override
  String toString() => 'Error: $message';
}

class StokHabisException implements Exception {
  final String message;
  StokHabisException(this.message);

  @override
  String toString() => 'Error: $message';
}

mixin BisaDiskon {
  bool validasiDiskon(double persen) => persen >= 0 && persen <= 100;

  double hitungDiskon(double harga, double persen) {
    if (!validasiDiskon(persen)) return harga;
    return harga - (harga * persen / 100);
  }
}

abstract class Produk {
  String id, nama;
  double harga;
  int stok;

  Produk(this.id, this.nama, this.harga, this.stok);
  String deskripsi();
}

class ProdukDigital extends Produk with BisaDiskon {
  double ukuranMB;
  String formatFile;

  ProdukDigital(
    super.id,
    super.nama,
    super.harga,
    super.stok,
    this.ukuranMB,
    this.formatFile,
  );

  @override
  String deskripsi() =>
      '[Digital]: $nama ($ukuranMB MB, $formatFile) - Rp $harga | Stok: $stok';
}

class ProdukFisik extends Produk with BisaDiskon {
  double beratGram;
  String dimensi;

  ProdukFisik(
    super.id,
    super.nama,
    super.harga,
    super.stok,
    this.beratGram,
    this.dimensi,
  );

  @override
  String deskripsi() =>
      '[Fisik]: $nama ($beratGram)g, $dimensi) - Rp $harga | Stok: $stok';
}

class Keranjang {
  final List<Produk> items = [];

  void tambah(Produk p) {
    if (p.stok <= 0) throw StokHabisException('Stok  "${p.nama}" habis.');
    items.add(p);
    print('Added to cart: ${p.nama}');
  }

  void hapus(Produk p) {
    if (!items.contains(p))
      throw ProdukTidakAda('Produk "${p.nama}" tidak ada di keranjang.');
    items.remove(p);
    print('Removed from cart: ${p.nama}');
  }

  double totalHarga() => items.fold(0, (sum, p) => sum + p.harga);
}

class TokoService {
  final List<Produk> katalog = [];

  Future<Produk> cariProduk(String nama) async {
    print('\nMencari "$nama"...');
    await Future.delayed(const Duration(seconds: 1));
    return katalog.firstWhere(
      (p) => p.nama.toLowerCase().contains(nama.toLowerCase()),
      orElse: () => throw ProdukTidakAda('Produk "$nama" tidak ditemukan.'),
    );
  }

  Future<void> prosesCheckout(Keranjang k) async {
    print('\nMemproses checkout...');
    await Future.delayed(const Duration(seconds: 1));
    if (k.items.isEmpty) throw StateError('Keranjang kosong.');

    for (var p in k.items) {
      if (p.stok <= 0) throw StokHabisException('Stok "${p.nama}" habis.');
      p.stok--;
    }
    print('Checkout berhasil! Total: Rp ${k.totalHarga()}');
  }
}

void main() async {
  print('=== SISTEM MENEJEMEN TOKO ONLINE ===');
  final toko = TokoService();
  final keranjang = Keranjang();

  var eBook = ProdukDigital('D01', 'E-Book Flutter', 50000, 3, 12.5, 'PDF');
  var mouse = ProdukFisik('F01', 'Mouse Gaming', 120000, 0, 150, '10x5 cm');
  toko.katalog.addAll([eBook, mouse]);

  try {
    var p1 = await toko.cariProduk('Flutter');
    print(p1.deskripsi());
    print(
      'Harga setelah diskon 20%: Rp ${eBook.hitungDiskon(eBook.harga, 20)}',
    );
    keranjang.tambah(p1);
  } catch (e) {
    print('Error: $e');
  }

  try {
    var p2 = await toko.cariProduk('Mouse');
    keranjang.tambah(p2);
  } catch (e) {
    print('Error: $e');
  }

  try {
    await toko.cariProduk('Laptop');
  } catch (e) {
    print('Error: $e');
  }

  try {
    await toko.prosesCheckout(keranjang);
  } catch (e) {
    print('Error: $e');
  } finally {
    print('\n=== Selesai ===');
  }
}
