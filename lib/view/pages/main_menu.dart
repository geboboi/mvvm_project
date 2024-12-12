part of 'pages.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;
  final HomeViewmodel homeViewModel = HomeViewmodel();

  // Define pages as a getter to ensure they have access to the same viewModel instance
  List<Widget> get _pages => <Widget>[
        const HomePage(),
        const CostPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    // Initialize province list when the app starts
    homeViewModel.getProvinceList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewmodel>(
      create: (context) => homeViewModel,
      child: Scaffold(
        body: DoubleBack(
          waitForSecondBackPress: 4,
          onFirstBackPress: () {
            return Fluttertoast.showToast(
              msg: "Press back again to close app!",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 14,
            );
          },
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Cost Info',
            ),
          ],
        ),
      ),
    );
  }
}
