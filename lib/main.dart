import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PosApp());

// ============================================================
// TEMA & WARNA
// ============================================================
const Color kPrimary = Color(0xFF2563EB);
const Color kPrimaryDark = Color(0xFF1E40AF);
const Color kAccent = Color(0xFF60A5FA);
const Color kBg = Color(0xFFF1F5F9);
const Color kSurface = Colors.white;
const Color kTextDark = Color(0xFF0F172A);
const Color kTextMuted = Color(0xFF64748B);
const Color kBorder = Color(0xFFE2E8F0);

const List<String> kCategories = ['Makanan', 'Minuman', 'Snack', 'Dessert'];

const List<Color> kPalette = [
  Color(0xFF2563EB),
  Color(0xFF0D9488),
  Color(0xFFEA580C),
  Color(0xFFDB2777),
  Color(0xFF7C3AED),
  Color(0xFF16A34A),
  Color(0xFF0891B2),
  Color(0xFF6D4C41),
];

// ============================================================
// HELPER
// ============================================================
String two(int n) => n.toString().padLeft(2, '0');

String rupiah(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return 'Rp ${buffer.toString()}';
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatDateTime(DateTime date) {
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year} • '
      '${two(date.hour)}:${two(date.minute)}';
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// ============================================================
// MODEL
// ============================================================
class Product {
  final String id;
  final String nama;
  final int harga;
  final String kategori;
  final IconData icon;
  final Color color;

  const Product({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.icon,
    required this.color,
  });
}

class OrderItem {
  final String nama;
  final int harga;
  final int qty;

  const OrderItem({required this.nama, required this.harga, required this.qty});

  int get subtotal => harga * qty;
}

class Order {
  final String id;
  final List<OrderItem> items;
  final int total;
  final DateTime time;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.time,
  });

  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);
}

// ============================================================
// DATA SEMENTARA (tanpa Firebase — untuk keperluan UI)
// ============================================================
class AppState {
  static String role = 'kasir';

  static final List<Product> products = [
    const Product(
      id: 'p1',
      nama: 'Kopi Susu Gula Aren',
      harga: 18000,
      kategori: 'Minuman',
      icon: Icons.coffee,
      color: Color(0xFF6D4C41),
    ),
    const Product(
      id: 'p2',
      nama: 'Es Teh Manis',
      harga: 8000,
      kategori: 'Minuman',
      icon: Icons.local_drink,
      color: Color(0xFF0D9488),
    ),
    const Product(
      id: 'p3',
      nama: 'Nasi Goreng Spesial',
      harga: 25000,
      kategori: 'Makanan',
      icon: Icons.rice_bowl,
      color: Color(0xFFEA580C),
    ),
    const Product(
      id: 'p4',
      nama: 'Mie Ayam Bakso',
      harga: 22000,
      kategori: 'Makanan',
      icon: Icons.ramen_dining,
      color: Color(0xFF2563EB),
    ),
    const Product(
      id: 'p5',
      nama: 'Ayam Geprek Sambal',
      harga: 20000,
      kategori: 'Makanan',
      icon: Icons.lunch_dining,
      color: Color(0xFFDB2777),
    ),
    const Product(
      id: 'p6',
      nama: 'Kentang Goreng',
      harga: 15000,
      kategori: 'Snack',
      icon: Icons.fastfood,
      color: Color(0xFF7C3AED),
    ),
    const Product(
      id: 'p7',
      nama: 'Roti Bakar Coklat',
      harga: 12000,
      kategori: 'Snack',
      icon: Icons.bakery_dining,
      color: Color(0xFF16A34A),
    ),
    const Product(
      id: 'p8',
      nama: 'Es Krim Coklat',
      harga: 10000,
      kategori: 'Dessert',
      icon: Icons.icecream,
      color: Color(0xFF0891B2),
    ),
  ];

  static final List<Order> orders = [];
  static int _invoiceCounter = 0;

  static Product? byId(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  static String nextInvoice() {
    final now = DateTime.now();
    _invoiceCounter++;
    final date = '${now.year}${two(now.month)}${two(now.day)}';
    return 'INV-$date-${_invoiceCounter.toString().padLeft(3, '0')}';
  }

  static int get totalRevenue =>
      orders.fold(0, (sum, order) => sum + order.total);
}

// ============================================================
// ROOT APP
// ============================================================
class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Kasir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        scaffoldBackgroundColor: kBg,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
          labelStyle: const TextStyle(color: kTextMuted, fontSize: 14),
          floatingLabelStyle: const TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w600,
          ),
          prefixIconColor: kTextMuted,
          suffixIconColor: kTextMuted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kPrimary, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kTextDark,
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  String _role = 'kasir';
  bool _obscure = true;
  bool _loading = false;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      if (_role == 'admin') {
        _email.text = 'admin@pos.id';
        _pass.text = 'admin123';
      } else {
        _email.text = 'kasir@pos.id';
        _pass.text = 'kasir123';
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    AppState.role = _role;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) =>
            _role == 'admin' ? const AdminPage() : const KasirPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), kPrimary, kAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -90, right: -70, child: _bubble(250, 0.07)),
            Positioned(bottom: -110, left: -80, child: _bubble(280, 0.05)),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _brand(),
                            const SizedBox(height: 26),
                            _loginCard(),
                            const SizedBox(height: 20),
                            Text(
                              'Mode demo • data tersimpan sementara',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _brand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Icon(
            Icons.point_of_sale_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'POS Kasir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Point of Sale Sederhana',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih role lalu masukkan akun kamu',
              style: TextStyle(color: kTextMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _roleSwitcher(),
            const SizedBox(height: 18),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'nama@email.com',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!value.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi';
                }
                if (value.length < 5) return 'Minimal 5 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _demoHint(),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _roleTab('kasir', 'Kasir', Icons.point_of_sale_rounded),
          _roleTab('admin', 'Admin', Icons.admin_panel_settings_rounded),
        ],
      ),
    );
  }

  Widget _roleTab(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? kPrimary : kTextMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? kPrimaryDark : kTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _demoHint() {
    final hint = _role == 'admin'
        ? 'admin@pos.id / admin123'
        : 'kasir@pos.id / kasir123';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: kPrimary, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo: $hint',
              style: const TextStyle(color: kTextMuted, fontSize: 11.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: _fillDemo,
            style: TextButton.styleFrom(
              foregroundColor: kPrimary,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Isi'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET BERSAMA
// ============================================================
class GradientHeader extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? bottom;

  const GradientHeader({
    super.key,
    this.leading,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryDark, kPrimary, kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        14,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
          if (bottom != null) ...[const SizedBox(height: 18), bottom!],
        ],
      ),
    );
  }
}

class HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final int badge;

  const HeaderAction({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: IconButton(
            onPressed: onTap,
            tooltip: tooltip,
            visualDensity: VisualDensity.compact,
            icon: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 17),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.4),
              ),
              child: Text(
                '$badge',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class GlassStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const GlassStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 17),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarBadge extends StatelessWidget {
  final IconData icon;
  const AvatarBadge({super.key, this.icon = Icons.person_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const SearchBox({super.key, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 21),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () => controller.clear(),
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: 'Hapus pencarian',
              ),
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = categories[index];
          final active = label == selected;
          return GestureDetector(
            onTap: () => onSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? kPrimary : kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: active ? kPrimary : kBorder),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : kTextMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: kPrimary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: kTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}

Color colorForCategory(String kategori) {
  switch (kategori) {
    case 'Makanan':
      return const Color(0xFFEA580C);
    case 'Minuman':
      return const Color(0xFF0D9488);
    case 'Snack':
      return const Color(0xFFDB2777);
    case 'Dessert':
      return const Color(0xFF7C3AED);
    default:
      return kPrimary;
  }
}

// ============================================================
// DIALOG TAMBAH / EDIT MENU
// ============================================================
class MenuFormDialog extends StatefulWidget {
  final Product? existing;
  const MenuFormDialog({super.key, this.existing});

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _harga;
  late String _kategori;
  late IconData _icon;

  static const List<IconData> _iconChoices = [
    Icons.rice_bowl,
    Icons.lunch_dining,
    Icons.ramen_dining,
    Icons.fastfood,
    Icons.coffee,
    Icons.local_cafe,
    Icons.local_drink,
    Icons.icecream,
    Icons.cake,
    Icons.bakery_dining,
    Icons.emoji_food_beverage,
    Icons.soup_kitchen,
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nama = TextEditingController(text: existing?.nama ?? '');
    _harga = TextEditingController(
      text: existing == null ? '' : existing.harga.toString(),
    );
    _kategori = existing?.kategori ?? kCategories.first;
    _icon = existing?.icon ?? Icons.fastfood;
  }

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existing;
    final product = Product(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      nama: _nama.text.trim(),
      harga: int.parse(_harga.text),
      kategori: _kategori,
      icon: _icon,
      color: existing?.color ?? colorForCategory(_kategori),
    );
    Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.existing == null
                            ? Icons.add_rounded
                            : Icons.edit_rounded,
                        color: kPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existing == null
                                ? 'Tambah Menu'
                                : 'Edit Menu',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextDark,
                            ),
                          ),
                          const Text(
                            'Lengkapi detail menu di bawah',
                            style: TextStyle(fontSize: 11.5, color: kTextMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      visualDensity: VisualDensity.compact,
                      color: kTextMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nama,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama Menu',
                    hintText: 'Contoh: Nasi Goreng Spesial',
                    prefixIcon: Icon(Icons.restaurant_menu_rounded, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama menu wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _harga,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    hintText: '15000',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga wajib diisi';
                    }
                    final price = int.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Harga harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCategories.map((category) {
                    final active = _kategori == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: active,
                      onSelected: (_) => setState(() {
                        _kategori = category;
                        if (widget.existing == null) {
                          _icon = _iconForCategory(category);
                        }
                      }),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active ? Colors.white : kTextMuted,
                      ),
                      selectedColor: kPrimary,
                      backgroundColor: kSurface,
                      side: BorderSide(color: active ? kPrimary : kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ikon Menu',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconChoices.map((icon) {
                    final active = _icon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => _icon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: active
                              ? kPrimary
                              : kPrimary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active ? kPrimary : kBorder,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 21,
                          color: active ? Colors.white : kTextMuted,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: kBorder),
                          foregroundColor: kTextMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.rice_bowl;
      case 'Minuman':
        return Icons.local_drink;
      case 'Snack':
        return Icons.fastfood;
      case 'Dessert':
        return Icons.icecream;
      default:
        return Icons.fastfood;
    }
  }
}

// ============================================================
// ADMIN PAGE — KELOLA MENU
// ============================================================
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _search = TextEditingController();
  String _query = '';
  String _kategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() => _query = _search.text);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final set = <String>{
      for (final product in AppState.products) product.kategori,
    };
    return ['Semua', ...set];
  }

  List<Product> get _filtered {
    final keyword = _query.trim().toLowerCase();
    return AppState.products.where((product) {
      final matchCategory =
          _kategori == 'Semua' || product.kategori == _kategori;
      final matchQuery =
          keyword.isEmpty || product.nama.toLowerCase().contains(keyword);
      return matchCategory && matchQuery;
    }).toList();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openForm({Product? existing}) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => MenuFormDialog(existing: existing),
    );
    if (result == null || !mounted) return;

    setState(() {
      final index = AppState.products.indexWhere(
        (product) => product.id == result.id,
      );
      if (index == -1) {
        AppState.products.add(result);
      } else {
        AppState.products[index] = result;
      }
    });

    showToast(
      context,
      existing == null
          ? 'Menu "${result.nama}" berhasil ditambahkan'
          : 'Menu "${result.nama}" berhasil diperbarui',
    );
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hapus menu ini?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"${product.nama}" akan dihapus dari daftar menu.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: kTextMuted),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: kBorder),
                          foregroundColor: kTextMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() {
      AppState.products.removeWhere((item) => item.id == product.id);
    });
    showToast(context, 'Menu "${product.nama}" dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            leading: const AvatarBadge(
              icon: Icons.admin_panel_settings_rounded,
            ),
            title: 'Halo, Admin 👋',
            subtitle: 'Kelola menu dan harga jualan',
            actions: [
              HeaderAction(
                icon: Icons.logout_rounded,
                tooltip: 'Keluar',
                onTap: _logout,
              ),
            ],
            bottom: Row(
              children: [
                Expanded(
                  child: GlassStat(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Total Menu',
                    value: '${AppState.products.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassStat(
                    icon: Icons.category_outlined,
                    label: 'Kategori',
                    value: '${_categories.length - 1}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassStat(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transaksi',
                    value: '${AppState.orders.length}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: SearchBox(controller: _search, hint: 'Cari menu...'),
          ),
          CategoryChips(
            categories: _categories,
            selected: _kategori,
            onSelected: (value) => setState(() => _kategori = value),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: AppState.products.isEmpty
                        ? Icons.restaurant_menu_rounded
                        : Icons.search_off_rounded,
                    title: AppState.products.isEmpty
                        ? 'Belum ada menu'
                        : 'Menu tidak ditemukan',
                    subtitle: AppState.products.isEmpty
                        ? 'Tekan tombol "Tambah Menu" untuk mulai.'
                        : 'Coba kata kunci atau kategori lain.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _menuCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Menu',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _menuCard(Product product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: product.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(product.icon, color: product.color, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _categoryPill(product),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        rupiah(product.harga),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openForm(existing: product),
            tooltip: 'Edit menu',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: kPrimary.withValues(alpha: 0.08),
              foregroundColor: kPrimary,
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            onPressed: () => _delete(product),
            tooltip: 'Hapus menu',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.08),
              foregroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _categoryPill(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: product.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        product.kategori,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: product.color,
        ),
      ),
    );
  }
}

// ============================================================
// KASIR PAGE — TRANSAKSI POS
// ============================================================
class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final Map<String, int> _cart = {};
  final _search = TextEditingController();
  String _query = '';
  String _kategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() => _query = _search.text);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final set = <String>{
      for (final product in AppState.products) product.kategori,
    };
    return ['Semua', ...set];
  }

  List<Product> get _filtered {
    final keyword = _query.trim().toLowerCase();
    return AppState.products.where((product) {
      final matchCategory =
          _kategori == 'Semua' || product.kategori == _kategori;
      final matchQuery =
          keyword.isEmpty || product.nama.toLowerCase().contains(keyword);
      return matchCategory && matchQuery;
    }).toList();
  }

  int get _totalQty {
    var total = 0;
    _cart.forEach((id, qty) {
      if (AppState.byId(id) != null) total += qty;
    });
    return total;
  }

  int get _total {
    var total = 0;
    _cart.forEach((id, qty) {
      final product = AppState.byId(id);
      if (product != null) total += product.harga * qty;
    });
    return total;
  }

  void _add(String id) {
    HapticFeedback.lightImpact();
    setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
  }

  void _decrease(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      final qty = _cart[id] ?? 0;
      if (qty <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = qty - 1;
      }
    });
  }

  void _clearCart() {
    setState(() => _cart.clear());
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _confirmCheckout() async {
    final lines = <OrderItem>[];
    var total = 0;
    _cart.forEach((id, qty) {
      final product = AppState.byId(id);
      if (product == null) return;
      lines.add(OrderItem(nama: product.nama, harga: product.harga, qty: qty));
      total += product.harga * qty;
    });
    if (lines.isEmpty) return;

    final totalQty = lines.fold(0, (sum, item) => sum + item.qty);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: kPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selesaikan pesanan?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalQty item akan diproses',
                  style: const TextStyle(fontSize: 12.5, color: kTextMuted),
                ),
                const SizedBox(height: 14),
                Text(
                  rupiah(total),
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryDark,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: kBorder),
                          foregroundColor: kTextMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Konfirmasi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final order = Order(
      id: AppState.nextInvoice(),
      items: lines,
      total: total,
      time: DateTime.now(),
    );
    AppState.orders.insert(0, order);
    HapticFeedback.mediumImpact();
    setState(() => _cart.clear());

    await showDialog<void>(
      context: context,
      builder: (_) => OrderDetailDialog(order: order, success: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            leading: const AvatarBadge(icon: Icons.storefront_rounded),
            title: 'Kasir POS',
            subtitle: 'Pilih menu untuk pesanan baru',
            actions: [
              HeaderAction(
                icon: Icons.history_rounded,
                tooltip: 'Riwayat transaksi',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TransactionHistoryPage(),
                    ),
                  );
                },
              ),
              HeaderAction(
                icon: Icons.logout_rounded,
                tooltip: 'Keluar',
                onTap: _logout,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: SearchBox(controller: _search, hint: 'Cari menu...'),
          ),
          CategoryChips(
            categories: _categories,
            selected: _kategori,
            onSelected: (value) => setState(() => _kategori = value),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Menu tidak ditemukan',
                    subtitle: 'Coba kata kunci atau kategori lain.',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 620
                          ? 3
                          : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 178,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return _productCard(product, _cart[product.id] ?? 0);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _productCard(Product product, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: qty > 0 ? kPrimary.withValues(alpha: 0.5) : kBorder,
          width: qty > 0 ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _add(product.id),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: product.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(product.icon, color: product.color, size: 24),
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: qty > 0
                          ? Container(
                              key: ValueKey(qty),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [kPrimary, kPrimaryDark],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'x$qty',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  product.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.kategori,
                  style: const TextStyle(fontSize: 10.5, color: kTextMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rupiah(product.harga),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final empty = _totalQty == 0;
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: empty ? null : _openCart,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: kPrimary,
                      size: 22,
                    ),
                  ),
                  if (!empty)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                        child: Text(
                          '$_totalQty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 10.5, color: kTextMuted),
                  ),
                  Text(
                    rupiah(_total),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: empty
                        ? [Colors.grey.shade300, Colors.grey.shade400]
                        : [kPrimary, kPrimaryDark],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: empty
                      ? null
                      : [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: ElevatedButton.icon(
                  onPressed: empty ? null : _openCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  icon: Icon(
                    Icons.shopping_cart_checkout_rounded,
                    size: 19,
                    color: empty ? Colors.white70 : Colors.white,
                  ),
                  label: Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: empty ? Colors.white70 : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            void add(String id) {
              _add(id);
              setSheet(() {});
            }

            void decrease(String id) {
              _decrease(id);
              setSheet(() {});
            }

            void clear() {
              _clearCart();
              setSheet(() {});
            }

            final entries = _cart.entries
                .where((entry) => AppState.byId(entry.key) != null)
                .toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.84,
              ),
              decoration: const BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: kPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: kPrimary,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kTextDark,
                                  ),
                                ),
                                Text(
                                  '$_totalQty item dipilih',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: kTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (entries.isNotEmpty)
                            TextButton(
                              onPressed: clear,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('Kosongkan'),
                            ),
                        ],
                      ),
                    ),
                    if (entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: kBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 34,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Keranjang masih kosong',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Pilih menu terlebih dahulu.',
                              style: TextStyle(fontSize: 12, color: kTextMuted),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  side: const BorderSide(color: kBorder),
                                  foregroundColor: kTextMuted,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: const Text('Tutup'),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 18,
                            color: kBorder.withValues(alpha: 0.6),
                          ),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final product = AppState.byId(entry.key)!;
                            return Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: product.color.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    product.icon,
                                    color: product.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: kTextDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rupiah(product.harga),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: kTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _stepper(
                                  qty: entry.value,
                                  onMinus: () => decrease(entry.key),
                                  onPlus: () => add(entry.key),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    rupiah(product.harga * entry.value),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: kTextDark,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      decoration: BoxDecoration(
                        color: kSurface,
                        border: Border(
                          top: BorderSide(
                            color: kBorder.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Total tagihan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: kTextMuted,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                rupiah(_total),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: entries.isEmpty
                                      ? [
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ]
                                      : [kPrimary, kPrimaryDark],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: entries.isEmpty
                                    ? null
                                    : () {
                                        Navigator.of(sheetContext).pop();
                                        _confirmCheckout();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 19,
                                  color: entries.isEmpty
                                      ? Colors.white70
                                      : Colors.white,
                                ),
                                label: Text(
                                  'Bayar Sekarang',
                                  style: TextStyle(
                                    color: entries.isEmpty
                                        ? Colors.white70
                                        : Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepper({
    required int qty,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            borderRadius: BorderRadius.circular(9),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove_rounded, size: 15, color: kPrimary),
            ),
          ),
          SizedBox(
            width: 18,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
          ),
          InkWell(
            onTap: onPlus,
            borderRadius: BorderRadius.circular(9),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add_rounded, size: 15, color: kPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL / STRUK PESANAN
// ============================================================
class OrderDetailDialog extends StatelessWidget {
  final Order order;
  final bool success;

  const OrderDetailDialog({
    super.key,
    required this.order,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (success)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.elasticOut,
                  builder: (_, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF16A34A),
                      size: 42,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: kPrimary,
                    size: 36,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                success ? 'Transaksi Berhasil' : 'Detail Transaksi',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: kPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDateTime(order.time),
                style: const TextStyle(fontSize: 11, color: kTextMuted),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < order.items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 9),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${order.items[i].qty}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: kPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              order.items[i].nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rupiah(order.items[i].subtotal),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Divider(
                        height: 1,
                        color: kBorder.withValues(alpha: 0.8),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${order.totalQty} item',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: kTextMuted,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          rupiah(order.total),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RIWAYAT TRANSAKSI
// ============================================================
class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = AppState.orders;
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            leading: HeaderAction(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Kembali',
              onTap: () => Navigator.of(context).pop(),
            ),
            title: 'Riwayat Transaksi',
            subtitle: '${orders.length} transaksi tersimpan',
            bottom: Row(
              children: [
                Expanded(
                  child: GlassStat(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transaksi',
                    value: '${orders.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassStat(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Pendapatan',
                    value: rupiah(AppState.totalRevenue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'Belum ada transaksi',
                    subtitle: 'Transaksi yang selesai akan muncul di sini.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _orderCard(context, order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, Order order) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => OrderDetailDialog(order: order, success: false),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: kPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.totalQty} item • ${formatDateTime(order.time)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rupiah(order.total),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Berhasil',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
