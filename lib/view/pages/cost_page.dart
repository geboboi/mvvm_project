part of 'pages.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  final TextEditingController weightController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String? selectedCourier;
  Province? selectedOriginProvince;
  City? selectedOriginCity;
  Province? selectedDestProvince;
  City? selectedDestCity;
  List<City> originCities = [];
  List<City> destinationCities = [];
  List<Costs>? shippingCosts;
  bool isLoading = false;
  bool isLoadingOriginCities = false;
  bool isLoadingDestCities = false;

  final List<String> courierList = ['JNE', 'POS', 'TIKI'];

  bool get _isInputEnabled => !isLoading;

  @override
  void initState() {
    super.initState();
    weightController.text = '2000';
  }

  void _showErrorMessage(String message) {
    _scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadCities(bool isOrigin, Province province) async {
    try {
      setState(() {
        if (isOrigin) {
          isLoadingOriginCities = true;
        } else {
          isLoadingDestCities = true;
        }
      });

      final viewModel = Provider.of<HomeViewmodel>(context, listen: false);
      final cities = await viewModel.getCityList(province.provinceId);

      if (!mounted) return;

      setState(() {
        if (isOrigin) {
          originCities = cities;
          selectedOriginCity = null;
          isLoadingOriginCities = false;
        } else {
          destinationCities = cities;
          selectedDestCity = null;
          isLoadingDestCities = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (isOrigin) {
          isLoadingOriginCities = false;
        } else {
          isLoadingDestCities = false;
        }
      });
      _showErrorMessage('Error loading cities: ${e.toString()}');
    }
  }

  Future<void> _calculateShippingCost() async {
    if (selectedCourier == null ||
        selectedOriginCity == null ||
        selectedDestCity == null) {
      _showErrorMessage('Mohon lengkapi semua data terlebih dahulu');
      return;
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final viewModel = Provider.of<HomeViewmodel>(context, listen: false);
      final costs = await viewModel.calculateShippingCost(
        origin: selectedOriginCity!.cityId ?? '',
        destination: selectedDestCity!.cityId ?? '',
        weight: int.parse(weightController.text),
        courier: selectedCourier!.toLowerCase(),
      );

      if (!mounted) return;

      setState(() {
        shippingCosts = costs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      _showErrorMessage('Error calculating shipping cost: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Hitung Ongkir'),
          centerTitle: true,
        ),
        body: Consumer<HomeViewmodel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Courier Selection
                  DropdownButtonFormField<String>(
                    value: selectedCourier,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Kurir',
                      border: OutlineInputBorder(),
                    ),
                    items: courierList.map((String courier) {
                      return DropdownMenuItem(
                        value: courier,
                        child: Text(courier.toLowerCase()),
                      );
                    }).toList(),
                    onChanged: _isInputEnabled
                        ? (String? value) {
                            setState(() {
                              selectedCourier = value;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Weight Input
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    enabled: _isInputEnabled,
                    decoration: const InputDecoration(
                      labelText: 'Berat (gr)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Origin Section
                  const Text(
                    'Origin',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Origin Province Dropdown
                  if (viewModel.provinceList.status == Status.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.provinceList.status == Status.error)
                    Center(
                        child: Text(viewModel.provinceList.message ?? 'Error'))
                  else
                    DropdownButtonFormField<Province>(
                      value: selectedOriginProvince,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Provinsi',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.provinceList.data?.map((province) {
                        return DropdownMenuItem(
                          value: province,
                          child: Text(province.province ?? ''),
                        );
                      }).toList(),
                      onChanged: _isInputEnabled
                          ? (Province? province) async {
                              setState(() {
                                selectedOriginProvince = province;
                                selectedOriginCity = null;
                              });
                              if (province != null) {
                                await _loadCities(true, province);
                              }
                            }
                          : null,
                    ),
                  const SizedBox(height: 8),

                  // Origin City Dropdown
                  if (selectedOriginProvince != null)
                    if (isLoadingOriginCities)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ))
                    else
                      DropdownButtonFormField<City>(
                        value: selectedOriginCity,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kota',
                          border: OutlineInputBorder(),
                        ),
                        items: originCities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city.cityName ?? ''),
                          );
                        }).toList(),
                        onChanged: _isInputEnabled
                            ? (City? city) {
                                setState(() {
                                  selectedOriginCity = city;
                                });
                              }
                            : null,
                      ),
                  const SizedBox(height: 24),

                  // Destination Section
                  const Text(
                    'Destination',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Destination Province Dropdown
                  if (viewModel.provinceList.status == Status.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.provinceList.status == Status.error)
                    Center(
                        child: Text(viewModel.provinceList.message ?? 'Error'))
                  else
                    DropdownButtonFormField<Province>(
                      value: selectedDestProvince,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Provinsi',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.provinceList.data?.map((province) {
                        return DropdownMenuItem(
                          value: province,
                          child: Text(province.province ?? ''),
                        );
                      }).toList(),
                      onChanged: _isInputEnabled
                          ? (Province? province) async {
                              setState(() {
                                selectedDestProvince = province;
                                selectedDestCity = null;
                              });
                              if (province != null) {
                                await _loadCities(false, province);
                              }
                            }
                          : null,
                    ),
                  const SizedBox(height: 8),

                  // Destination City Dropdown
                  if (selectedDestProvince != null)
                    if (isLoadingDestCities)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ))
                    else
                      DropdownButtonFormField<City>(
                        value: selectedDestCity,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kota',
                          border: OutlineInputBorder(),
                        ),
                        items: destinationCities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city.cityName ?? ''),
                          );
                        }).toList(),
                        onChanged: _isInputEnabled
                            ? (City? city) {
                                setState(() {
                                  selectedDestCity = city;
                                });
                              }
                            : null,
                      ),
                  const SizedBox(height: 24),

                  // Calculate Button
                  ElevatedButton(
                    onPressed: _isInputEnabled ? _calculateShippingCost : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isLoading ? 'Calculating...' : 'Hitung Estimasi Harga',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Results
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (shippingCosts != null)
                    ..._buildShippingCostResults(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildShippingCostResults() {
    return shippingCosts?.map((costs) {
          final cost = costs.cost?.first;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'R',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${costs.service} (${costs.description})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Biaya: Rp${cost?.value?.toString() ?? "0"}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Estimasi sampai: ${cost?.etd ?? "0"} hari',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList() ??
        [];
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }
}
